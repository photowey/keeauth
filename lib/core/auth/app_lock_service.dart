import 'package:flutter/material.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';
import 'biometric_service.dart';

/// Service for managing app lock functionality
class AppLockService {
  final SecureStorageService _secureStorage;
  final BiometricService _biometricService;

  DateTime? _pausedTime;
  bool _isLocked = false;
  VoidCallback? _onLockCallback;
  bool _isInitialized = false;

  AppLockService(this._secureStorage, this._biometricService);

  /// Initialize app lock observer
  void initialize(VoidCallback onLock) {
    _onLockCallback = onLock;
    _isInitialized = true;
  }

  /// Handle app lifecycle change
  void onAppLifecycleStateChanged(AppLifecycleState state) {
    if (!_isInitialized) return;

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _pausedTime = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        if (_pausedTime != null && !_isLocked) {
          _checkLockTimeout();
        }
        _pausedTime = null;
        break;
      default:
        break;
    }
  }

  Future<void> _checkLockTimeout() async {
    final timeout = await _secureStorage.getAutoLockTimeout();
    if (timeout > 0 && _pausedTime != null) {
      final elapsed = DateTime.now().difference(_pausedTime!).inSeconds;
      if (elapsed >= timeout) {
        _isLocked = true;
        _onLockCallback?.call();
      }
    }
  }

  /// Unlock the app
  void unlock() {
    _isLocked = false;
  }

  /// Check if app should be locked
  bool get isLocked => _isLocked;

  /// Check if auto-lock is enabled
  Future<bool> isAutoLockEnabled() async {
    final timeout = await _secureStorage.getAutoLockTimeout();
    return timeout > 0;
  }

  /// Get current lock timeout
  Future<int> getLockTimeout() async {
    return await _secureStorage.getAutoLockTimeout();
  }

  /// Whether an app password has been configured
  Future<bool> hasPassword() async {
    return await _secureStorage.hasPassword();
  }

  /// Verify the given password against the stored hash
  Future<bool> verifyPassword(String password) async {
    return await _secureStorage.verifyPassword(password);
  }

  /// Whether biometric unlock is available and enabled
  Future<bool> isBiometricUnlockAvailable() async {
    final biometricEnabled = await _secureStorage.isBiometricEnabled();
    if (!biometricEnabled) return false;
    return await _biometricService.isSupported();
  }

  /// Authenticate to unlock – tries password first, with biometric shortcut.
  Future<bool> authenticateToUnlock({String? password, String? reason}) async {
    final prompt = reason ?? 'Authenticate to unlock';
    final hasPass = await _secureStorage.hasPassword();

    if (hasPass && password != null) {
      return await _secureStorage.verifyPassword(password);
    }

    if (hasPass && password == null) {
      final biometricAvailable = await isBiometricUnlockAvailable();
      if (biometricAvailable) {
        return await _biometricService.authenticate(reason: prompt);
      }
      return false;
    }

    return await _biometricService.authenticate(reason: prompt);
  }

  /// Dispose
  void dispose() {
    _isInitialized = false;
  }
}
