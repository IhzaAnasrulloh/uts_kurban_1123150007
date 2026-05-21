import 'package:local_auth/local_auth.dart';

enum BiometricErrorCode {
  noBiometricHardware,
  notEnrolled,
  temporaryLockout,
  biometricLockout,
  userCanceled,
  systemCanceled,
  unknown,
}

class BiometricException implements Exception {
  final BiometricErrorCode code;
  final String message;
  final String userMessage;

  BiometricException({
    required this.code,
    required this.userMessage,
    this.message = '',
  });

  factory BiometricException.fromLocalAuthException(
    LocalAuthException e,
  ) {
    switch (e.code) {
      case LocalAuthExceptionCode.noBiometricHardware:
        return BiometricException(
          code: BiometricErrorCode.noBiometricHardware,
          userMessage: 'Perangkat tidak memiliki sensor biometrik.',
        );

      case LocalAuthExceptionCode.noBiometricsEnrolled:
        return BiometricException(
          code: BiometricErrorCode.notEnrolled,
          userMessage: 'Belum ada sidik jari/wajah terdaftar.',
        );

      case LocalAuthExceptionCode.temporaryLockout:
        return BiometricException(
          code: BiometricErrorCode.temporaryLockout,
          userMessage: 'Terlalu banyak percobaan gagal.',
        );

      case LocalAuthExceptionCode.biometricLockout:
        return BiometricException(
          code: BiometricErrorCode.biometricLockout,
          userMessage: 'Biometrik terkunci sementara.',
        );

      case LocalAuthExceptionCode.userCanceled:
        return BiometricException(
          code: BiometricErrorCode.userCanceled,
          userMessage: 'Autentikasi dibatalkan pengguna.',
        );

      case LocalAuthExceptionCode.systemCanceled:
        return BiometricException(
          code: BiometricErrorCode.systemCanceled,
          userMessage: 'Autentikasi dibatalkan sistem.',
        );

      default:
        return BiometricException(
          code: BiometricErrorCode.unknown,
          userMessage: 'Terjadi kesalahan biometrik.',
        );
    }
  }

  // Tampilkan tombol "Coba Lagi"?
  bool get isRetryable =>
      code == BiometricErrorCode.userCanceled ||
      code == BiometricErrorCode.systemCanceled ||
      code == BiometricErrorCode.unknown;

  // Tampilkan tombol "Buka Pengaturan"?
  bool get requiresSettings =>
      code == BiometricErrorCode.notEnrolled;

  // Otomatis pindah ke login password?
  bool get requiresFallback =>
      code == BiometricErrorCode.noBiometricHardware ||
      code == BiometricErrorCode.biometricLockout;

  @override
  String toString() => userMessage;
}