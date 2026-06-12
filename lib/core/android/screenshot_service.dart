import 'package:flutter/services.dart';

/// Service for controlling Android-specific features like screenshot blocking
class ScreenshotService {
  static const MethodChannel _channel = MethodChannel('keeauth/security');

  /// Enable or disable screenshot blocking.
  /// Pass [enabled]=true to block screenshots, false to allow them.
  static Future<void> setSecure(bool enabled) async {
    await _channel.invokeMethod('setSecure', {'enabled': enabled});
  }

  /// Check if the app is currently in secure mode
  static Future<bool> isSecure() async {
    try {
      final result = await _channel.invokeMethod<bool>('isSecure');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
