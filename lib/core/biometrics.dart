import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

class Biometrics {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      final list = await _auth.getAvailableBiometrics();

      debugPrint("BIO canCheckBiometrics = $canCheck");
      debugPrint("BIO isDeviceSupported  = $isSupported");
      debugPrint("BIO available          = $list");

      return isSupported && (canCheck || list.isNotEmpty);
    } catch (e) {
      debugPrint("BIO isAvailable error: $e");
      return false;
    }
  }

  static Future<bool> authenticate({required String reason}) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      debugPrint("BIO authenticate result = $ok");
      return ok;
    } catch (e) {
      debugPrint("BIO authenticate error: $e");
      return false;
    }
  }
}