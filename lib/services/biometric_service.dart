import 'package:local_auth/local_auth.dart';

import 'biometric_exception.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isBiometricAvailable() async {
    final bool canCheck = await _auth.canCheckBiometrics;

    final bool isSupported = await _auth.isDeviceSupported();

    return canCheck && isSupported;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  Future<bool> authenticate({
    String reason = 'Silakan verifikasi identitas Anda',
  }) async {
    try {
      final available = await isBiometricAvailable();

      if (!available) {
        throw BiometricException(
          code: BiometricErrorCode.noBiometricHardware,
          userMessage: 'Biometrik tidak tersedia.',
        );
      }

      final biometrics = await getAvailableBiometrics();

      if (biometrics.isEmpty) {
        throw BiometricException(
          code: BiometricErrorCode.notEnrolled,
          userMessage: 'Belum ada biometrik terdaftar.',
        );
      }

      final result = await _auth.authenticate(
        localizedReason: reason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (!result) {
        throw BiometricException(
          code: BiometricErrorCode.userCanceled,
          userMessage: 'Autentikasi dibatalkan.',
        );
      }

      return result;
    } on LocalAuthException catch (e) {
      throw BiometricException.fromLocalAuthException(e);
    }
  }
}