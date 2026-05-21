import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:uts_kurban_1123150007/core/constants/api_constants.dart';
import 'package:uts_kurban_1123150007/core/constants/secure_storage.dart';
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

  AuthStatus _status = AuthStatus.initial;
  User? _firebaseUser;
  String? _backendToken;
  String? _errorMessage;
  bool _disposed = false;

  String? _tempEmail;
  String? _tempPassword;

  AuthStatus get status => _status;
  User? get firebaseUser => _firebaseUser;
  String? get backendToken => _backendToken;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _auth.authStateChanges().listen((user) async {
      _firebaseUser = user;

      if (user == null) {
        _status = AuthStatus.unauthenticated;
        await SecureStorageService.clearAll();
      } else if (!user.emailVerified) {
        _status = AuthStatus.emailNotVerified;
      }
      // ⚠️ Jangan set authenticated di sini
      // biar login method yang handle setelah verify ke backend

      _safeNotify();
    });
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
      // 1. Ambil Firebase ID Token
      final firebaseIdToken = await user.getIdToken(true);
      debugPrint('[AUTH] Firebase ID Token didapat');

      // 2. Kirim ke backend dengan field "firebase_token"
      final response = await DioClient.instance.post(
        ApiConstants.verifyToken,
        data: {'firebase_token': firebaseIdToken},
      );

      debugPrint('[AUTH] Backend response: ${response.data}');

      // 3. Ambil JWT dari response.data.access_token
      final backendJwt = response.data['data']?['access_token'];

      if (backendJwt == null) {
        debugPrint('[AUTH] access_token tidak ditemukan di response');
        _setError('Token backend tidak ditemukan');
        return false;
      }

      // 4. Simpan JWT backend ke SecureStorage
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

  // ================= REGISTER =================
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

  // ================= LOGIN EMAIL =================
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

      // 🔥 Verify ke backend dan simpan JWT
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

  // ================= LOGIN GOOGLE =================
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

      // 🔥 Verify ke backend dan simpan JWT
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

  // ================= RESEND EMAIL =================
  Future<void> resendVerificationEmail() async {
    try {
      await _firebaseUser?.sendEmailVerification();
    } catch (e) {
      _setError('Gagal kirim ulang email');
    }
  }

  // ================= CHECK VERIFY =================
  Future<bool> checkEmailVerified() async {
    try {
      await _firebaseUser?.reload();
      _firebaseUser = _auth.currentUser;

      if (_firebaseUser?.emailVerified ?? false) {
        // 🔥 Verify ke backend setelah email verified
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

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
    await googleSignIn.signOut();
    await SecureStorageService.clearAll();

    _firebaseUser = null;
    _backendToken = null;
    _status = AuthStatus.unauthenticated;

    _safeNotify();
  }

  // ================= ERROR MAPPER =================
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