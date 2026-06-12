import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:keeauth/core/enums/view_mode.dart';

/// Secure storage service using flutter_secure_storage
/// Uses Android Keystore for secure key storage
class SecureStorageService {
  static const String _databasePasswordKey = 'database_password';
  static const String _backupPasswordKey = 'backup_password';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _autoLockTimeoutKey = 'auto_lock_timeout';
  static const String _lastActiveTimeKey = 'last_active_time';
  static const String _screenshotEnabledKey = 'screenshot_enabled';
  static const String _tapToRevealEnabledKey = 'tap_to_reveal_enabled';
  static const String _themeKey = 'app_theme';
  static const String _sortModeKey = 'sort_mode';
  static const String _autoBackupEnabledKey = 'auto_backup_enabled';
  static const String _autoBackupFrequencyKey = 'auto_backup_frequency';
  static const String _autoBackupUriKey = 'auto_backup_uri';
  static const String _hasSeenIntroKey = 'has_seen_intro';
  static const String _localeKey = 'app_locale';
  static const String _codeGroupSizeKey = 'code_group_size';
  static const String _passwordHashKey = 'app_password_hash';
  static const String _passwordSaltKey = 'app_password_salt';

  final FlutterSecureStorage _storage;

  SecureStorageService()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        );

  // Database password
  Future<String?> getDatabasePassword() async {
    return await _storage.read(key: _databasePasswordKey);
  }

  Future<void> setDatabasePassword(String password) async {
    await _storage.write(key: _databasePasswordKey, value: password);
  }

  Future<void> deleteDatabasePassword() async {
    await _storage.delete(key: _databasePasswordKey);
  }

  // Backup password
  Future<String?> getBackupPassword() async {
    return await _storage.read(key: _backupPasswordKey);
  }

  Future<void> setBackupPassword(String password) async {
    await _storage.write(key: _backupPasswordKey, value: password);
  }

  // Biometric
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  // Auto lock timeout (in seconds)
  // 0 means no auto-lock (default), user must enable it explicitly
  Future<int> getAutoLockTimeout() async {
    final value = await _storage.read(key: _autoLockTimeoutKey);
    return int.tryParse(value ?? '0') ?? 0;
  }

  Future<void> setAutoLockTimeout(int seconds) async {
    await _storage.write(key: _autoLockTimeoutKey, value: seconds.toString());
  }

  // Last active time
  Future<DateTime?> getLastActiveTime() async {
    final value = await _storage.read(key: _lastActiveTimeKey);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(int.tryParse(value) ?? 0);
  }

  Future<void> setLastActiveTime(DateTime time) async {
    await _storage.write(
      key: _lastActiveTimeKey,
      value: time.millisecondsSinceEpoch.toString(),
    );
  }

  // Screenshot
  Future<bool> isScreenshotEnabled() async {
    final value = await _storage.read(key: _screenshotEnabledKey);
    return value == 'true'; // Default to blocked unless explicitly allowed
  }

  Future<void> setScreenshotEnabled(bool enabled) async {
    await _storage.write(key: _screenshotEnabledKey, value: enabled.toString());
  }

  // Tap to reveal
  Future<bool> isTapToRevealEnabled() async {
    final value = await _storage.read(key: _tapToRevealEnabledKey);
    return value == 'true';
  }

  Future<void> setTapToRevealEnabled(bool enabled) async {
    await _storage.write(key: _tapToRevealEnabledKey, value: enabled.toString());
  }

  // Theme
  Future<String> getTheme() async {
    return await _storage.read(key: _themeKey) ?? 'system';
  }

  Future<void> setTheme(String theme) async {
    await _storage.write(key: _themeKey, value: theme);
  }

  // Sort mode
  Future<String> getSortMode() async {
    return await _storage.read(key: _sortModeKey) ?? 'manual';
  }

  Future<void> setSortMode(String mode) async {
    await _storage.write(key: _sortModeKey, value: mode);
  }

  // Auto backup
  Future<bool> isAutoBackupEnabled() async {
    final value = await _storage.read(key: _autoBackupEnabledKey);
    return value == 'true';
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    await _storage.write(key: _autoBackupEnabledKey, value: enabled.toString());
  }

  Future<int> getAutoBackupFrequency() async {
    final value = await _storage.read(key: _autoBackupFrequencyKey);
    return int.tryParse(value ?? '86400') ?? 86400; // Default 24 hours
  }

  Future<void> setAutoBackupFrequency(int seconds) async {
    await _storage.write(
      key: _autoBackupFrequencyKey,
      value: seconds.toString(),
    );
  }

  Future<String?> getAutoBackupUri() async {
    return await _storage.read(key: _autoBackupUriKey);
  }

  Future<void> setAutoBackupUri(String uri) async {
    await _storage.write(key: _autoBackupUriKey, value: uri);
  }

  // Has seen intro
  Future<bool> hasSeenIntro() async {
    final value = await _storage.read(key: _hasSeenIntroKey);
    return value == 'true';
  }

  Future<void> setHasSeenIntro(bool value) async {
    await _storage.write(key: _hasSeenIntroKey, value: value.toString());
  }

  // Locale (null means follow system)
  Future<String?> getLocale() async {
    return await _storage.read(key: _localeKey);
  }

  Future<void> setLocale(String? locale) async {
    if (locale == null) {
      await _storage.delete(key: _localeKey);
    } else {
      await _storage.write(key: _localeKey, value: locale);
    }
  }

  // View mode
  static const String _viewModeKey = 'view_mode';

  Future<ViewMode> getViewMode() async {
    final value = await _storage.read(key: _viewModeKey);
    switch (value) {
      case 'compact':
        return ViewMode.compact;
      case 'tile':
        return ViewMode.tile;
      default:
        return ViewMode.standard;
    }
  }

  Future<void> setViewMode(ViewMode mode) async {
    await _storage.write(key: _viewModeKey, value: mode.name);
  }

  // Code group size (default 3)
  Future<int> getCodeGroupSize() async {
    final value = await _storage.read(key: _codeGroupSizeKey);
    return int.tryParse(value ?? '3') ?? 3;
  }

  Future<void> setCodeGroupSize(int size) async {
    await _storage.write(key: _codeGroupSizeKey, value: size.toString());
  }

  // App password
  Future<bool> hasPassword() async {
    final hash = await _storage.read(key: _passwordHashKey);
    return hash != null;
  }

  Future<void> setPassword(String password) async {
    final salt = _generateSalt();
    final hash = _hashPassword(password, salt);
    await _storage.write(key: _passwordHashKey, value: hash);
    await _storage.write(key: _passwordSaltKey, value: salt);
  }

  Future<bool> verifyPassword(String password) async {
    final storedHash = await _storage.read(key: _passwordHashKey);
    final storedSalt = await _storage.read(key: _passwordSaltKey);
    if (storedHash == null || storedSalt == null) return false;
    return _hashPassword(password, storedSalt) == storedHash;
  }

  Future<void> removePassword() async {
    await _storage.delete(key: _passwordHashKey);
    await _storage.delete(key: _passwordSaltKey);
  }

  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$password$salt');
    return sha256.convert(bytes).toString();
  }

  // Clear all
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
