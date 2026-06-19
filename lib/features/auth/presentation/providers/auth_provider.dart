import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:uts_kurban_1123150007/core/constants/api_constants.dart';
import 'package:uts_kurban_1123150007/core/constants/secure_storage.dart';
import 'package:uts_kurban_1123150007/core/services/biometric_exception.dart';
import 'package:uts_kurban_1123150007/core/services/biometric_service.dart'; // 🔥 TAMBAH INI
import 'package:uts_kurban_1123150007/core/services/dio_client.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailNotVerified,
  error,
}

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final BiometricService _biometricService = BiometricService(); // 🔥 TAMBAH INI

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;
  bool _disposed = false;
  bool _biometricAvailable = false;

  String? _tempEmail;
  String? _tempPassword;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get biometricAvailable => _biometricAvailable; 

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _firebaseUser = user;

      if (user == null) {
        _status = AuthStatus.unauthenticated;
        await SecureStorageService.clearAll();
      } else if (!user.emailVerified) {
        _status = AuthStatus.emailNotVerified;
      } else {
        // Automatically verify token and restore session on cold start
        final success = await _verifyTokenToBackend(user);
        if (success) {
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.error;
        }
      }

      _safeNotify();
    });

    _checkBiometricAvailability(); // 🔥 TAMBAH INI
  }

  // 🔥 TAMBAH METHOD INI
  Future<void> _checkBiometricAvailability() async {
    _biometricAvailable = await _biometricService.isBiometricAvailable();
    _safeNotify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _safeNotify();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    _safeNotify();
  }

  // ================= 🔥 VERIFY TOKEN KE BACKEND =================
  Future<bool> _verifyTokenToBackend(User user) async {
    try {
      final firebaseIdToken = await user.getIdToken(true);
      debugPrint('[AUTH] Firebase ID Token didapat');

      final response = await DioClient.instance.post(
        ApiConstants.verifyToken,
        data: {'firebase_token': firebaseIdToken},
      );

      debugPrint('[AUTH] Backend response: ${response.data}');

      final backendJwt = response.data['data']?['access_token'];

      if (backendJwt == null) {
        debugPrint('[AUTH] access_token tidak ditemukan di response');
        _setError('Token backend tidak ditemukan');
        return false;
      }

      await SecureStorageService.saveToken(backendJwt);
      _backendToken = backendJwt;
      debugPrint('[AUTH] Backend JWT tersimpan!');

      return true;
    } on DioException catch (e) {
      debugPrint('[AUTH] Gagal verify token: ${e.response?.data}');
      _setError('Gagal autentikasi ke server');
      return false;
    } catch (e) {
      debugPrint('[AUTH] Error tidak terduga: $e');
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  // ================= 🔥 LOGIN BIOMETRIC (METHOD BARU) =================
  Future<bool> loginWithBiometric() async {
    _setLoading();
    try {
      await _biometricService.authenticate(
        reason: 'Masuk ke Dashboard Kurban',
      );

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        _setError('Tidak ada sesi login sebelumnya. Silakan login terlebih dahulu.');
        return false;
      }

      _firebaseUser = currentUser;

      final success = await _verifyTokenToBackend(currentUser);
      if (!success) return false;

      _status = AuthStatus.authenticated;
      _safeNotify();

      return true;
    } on BiometricException catch (e) {
      _setError(e.userMessage);
      return false;
    } catch (e) {
      _setError('Gagal autentikasi biometrik');
      return false;
    }
  }

  // ================= REGISTER (TIDAK BERUBAH) =================
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;

      await _firebaseUser?.updateDisplayName(name);
      await _firebaseUser?.sendEmailVerification();

      _tempEmail = email;
      _tempPassword = password;

      _status = AuthStatus.emailNotVerified;
      _safeNotify();

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  // ================= LOGIN EMAIL (TIDAK BERUBAH) =================
  Future<bool> loginWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading();
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firebaseUser = credential.user;

      if (!(_firebaseUser?.emailVerified ?? false)) {
        _status = AuthStatus.emailNotVerified;
        _safeNotify();
        return false;
      }

      final success = await _verifyTokenToBackend(_firebaseUser!);
      if (!success) return false;

      _status = AuthStatus.authenticated;
      _safeNotify();

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapFirebaseError(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan tidak terduga');
      return false;
    }
  }

  // ================= LOGIN GOOGLE (TIDAK BERUBAH) =================
  Future<bool> loginWithGoogle() async {
    _setLoading();
    try {
      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        _setError('Login Google dibatalkan');
        return false;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      _firebaseUser = userCred.user;

      final success = await _verifyTokenToBackend(_firebaseUser!);
      if (!success) return false;

      _status = AuthStatus.authenticated;
      _safeNotify();

      return true;
    } catch (e) {
      _setError('Gagal login Google: $e');
      return false;
    }
  }

  // ================= RESEND EMAIL (TIDAK BERUBAH) =================
  Future<void> resendVerificationEmail() async {
    try {
      await _firebaseUser?.sendEmailVerification();
    } catch (e) {
      _setError('Gagal kirim ulang email');
    }
  }

  // ================= CHECK VERIFY (TIDAK BERUBAH) =================
  Future<bool> checkEmailVerified() async {
    try {
      await _firebaseUser?.reload();
      _firebaseUser = _auth.currentUser;

      if (_firebaseUser?.emailVerified ?? false) {
        final success = await _verifyTokenToBackend(_firebaseUser!);
        if (!success) return false;

        _status = AuthStatus.authenticated;
        _safeNotify();
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  // ================= LOGOUT (TIDAK BERUBAH) =================
  Future<void> logout() async {
    await _auth.signOut();
    await googleSignIn.signOut();
    await SecureStorageService.clearAll();

    _firebaseUser = null;
    _backendToken = null;
    _status = AuthStatus.unauthenticated;

    _safeNotify();
  }

  // ================= ERROR MAPPER (TIDAK BERUBAH) =================
  String _mapFirebaseError(String code) => switch (code) {
        'email-already-in-use' => 'Email sudah terdaftar.',
        'user-not-found' => 'Akun tidak ditemukan.',
        'wrong-password' => 'Password salah.',
        'invalid-email' => 'Format email tidak valid.',
        'weak-password' => 'Password terlalu lemah.',
        'network-request-failed' => 'Tidak ada koneksi internet.',
        'too-many-requests' => 'Terlalu banyak percobaan.',
        'user-disabled' => 'Akun dinonaktifkan.',
        _ => 'Terjadi kesalahan.',
      };
}