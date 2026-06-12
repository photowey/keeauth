import 'package:local_auth/local_auth.dart';

/// Biometric authentication service
class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Check if device supports biometric authentication.
  ///
  /// Tries multiple detection paths because some OEM ROMs (HarmonyOS, EMUI)
  /// report differently from stock Android.
  Future<bool> isSupported() async {
    try { if (await _localAuth.isDeviceSupported()) return true; } catch (_) {}
    try { if (await _localAuth.canCheckBiometrics) return true; } catch (_) {}
    try { return (await _localAuth.getAvailableBiometrics()).isNotEmpty; } catch (_) {}
    return false;
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if fingerprint is available

  /// Check if face recognition is available

  /// Authenticate with biometrics — strict security for password-protected app.
  Future<bool> authenticate({
    String reason = "Please authenticate to access the app",
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Cancel ongoing authentication
  Future<bool> cancelAuthentication() async {
    try {
      return await _localAuth.stopAuthentication();
    } catch (e) {
      return false;
    }
  }
}
