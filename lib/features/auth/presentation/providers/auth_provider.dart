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

  // 🔥 LISTENER (PENTING BANGET)
  AuthProvider() {
    _auth.authStateChanges().listen((user) {
      _firebaseUser = user;

      if (user == null) {
        _status = AuthStatus.unauthenticated;
      } else if (!user.emailVerified) {
        _status = AuthStatus.emailNotVerified;
      } else {
        _status = AuthStatus.authenticated;
      }

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

      _status = AuthStatus.authenticated;
      _safeNotify();

      return true; // 🔥 jangan tunggu backend dulu
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

  // ================= CHECK VERIFY (🔥 PALING PENTING) =================
  Future<bool> checkEmailVerified() async {
    try {
      await _firebaseUser?.reload(); // 🔥 WAJIB
      _firebaseUser = _auth.currentUser;

      if (_firebaseUser?.emailVerified ?? false) {
        _status = AuthStatus.authenticated; // 🔥 WAJIB
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