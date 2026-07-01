import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:keeauth/core/storage/secure_storage_service.dart';
import 'package:keeauth/core/auth/biometric_service.dart';
import 'package:keeauth/core/android/screenshot_service.dart';
import 'package:keeauth/core/theme/theme_bloc.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/backup/domain/auto_backup_service.dart';
import 'package:keeauth/features/backup/presentation/export_backup.dart';
import 'package:keeauth/features/backup/presentation/screens/import_screen.dart';
import 'package:keeauth/di/injection.dart';

/// Settings screen
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SecureStorageService _secureStorage = SecureStorageService();
  final BiometricService _biometricService = BiometricService();


  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  int _autoLockTimeout = 60;
  bool _tapToReveal = false;
  bool _screenshotEnabled = false;
  String _sortMode = 'manual';
  bool _autoBackupEnabled = false;
  int _autoBackupFrequency = 86400; // seconds, default 24h
  int _codeGroupSize = 3;
  bool _hasPassword = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }


  Future<void> _loadSettings() async {
    final biometricEnabled = await _secureStorage.isBiometricEnabled();
    final biometricAvailable = await _biometricService.isSupported();
    final autoLockTimeout = await _secureStorage.getAutoLockTimeout();
    final tapToReveal = await _secureStorage.isTapToRevealEnabled();
    final screenshotEnabled = await _secureStorage.isScreenshotEnabled();
    final sortMode = await _secureStorage.getSortMode();
    final autoBackupEnabled = await _secureStorage.isAutoBackupEnabled();
    final autoBackupFrequency = await _secureStorage.getAutoBackupFrequency();
    final codeGroupSize = await _secureStorage.getCodeGroupSize();
    final hasPassword = await _secureStorage.hasPassword();


    setState(() {
      _autoBackupEnabled = autoBackupEnabled;
      _autoBackupFrequency = autoBackupFrequency;
      _biometricEnabled = biometricEnabled;
      _biometricAvailable = biometricAvailable;
      _autoLockTimeout = autoLockTimeout;
      _tapToReveal = tapToReveal;
      _screenshotEnabled = screenshotEnabled;
      _sortMode = sortMode;
      _codeGroupSize = codeGroupSize;
      _hasPassword = hasPassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settings ?? 'Settings')),
      body: ListView(
        children: [
          _buildSectionHeader(l10n?.security ?? 'Security'),
          _buildPasswordTile(),
          _buildBiometricTile(),
          _buildAutoLockTile(),
          _buildScreenshotTile(),
          _buildTapToRevealTile(),
          const Divider(),
          _buildSectionHeader(l10n?.data ?? 'Data'),
          _buildImportTile(),
          _buildExportTile(),
          _buildBackupTile(),
          const Divider(),
          _buildSectionHeader(l10n?.display ?? 'Display'),
          _buildThemeTile(),
          _buildSortModeTile(),
          _buildCodeGroupSizeTile(),
          const Divider(),
          _buildSectionHeader(l10n?.about ?? 'About'),
          _buildAboutTile(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBiometricTile() {
    final l10n = AppLocalizations.of(context);
    final canEnableBiometric = _hasPassword && _biometricAvailable;
    final String subtitle;
    if (!_hasPassword) {
      subtitle = l10n?.biometricRequiresPassword ?? 'Set app password first';
    } else if (!_biometricAvailable) {
      subtitle = l10n?.biometricNotAvailable ?? 'Biometric not supported on this device';
    } else {
      subtitle = l10n?.biometricDescription ?? 'Use fingerprint to unlock';
    }
    return SwitchListTile(
      title: Text(l10n?.biometricUnlock ?? 'Biometric Unlock'),
      subtitle: Text(subtitle),
      value: _biometricEnabled,
      onChanged:
          canEnableBiometric
              ? (value) async {
                if (value) {
                  final authenticated = await _biometricService.authenticate(
                    reason:
                        l10n?.verifyToEnableBiometric ??
                        'Verify to enable biometric unlock',
                  );
                  if (authenticated) {
                    await _secureStorage.setBiometricEnabled(true);
                    setState(() => _biometricEnabled = true);
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n?.biometricNotAvailable ??
                                'Biometric not available on this device',
                          ),
                        ),
                      );
                    }
                  }
                } else {
                  await _secureStorage.setBiometricEnabled(false);
                  setState(() => _biometricEnabled = false);
                }
              }
              : (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      l10n?.biometricRequiresPassword ??
                          'Set app password first to enable biometric unlock',
                    ),
                  ),
                );
              },
        );
  }

  Widget _buildAutoLockTile() {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      title: Text(l10n?.autoLockTimeout ?? 'Auto-lock Timeout'),
      subtitle: Text(_autoLockTimeoutText()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showAutoLockDialog(),
    );
  }

  String _autoLockTimeoutText() {
    final l10n = AppLocalizations.of(context);
    if (_autoLockTimeout == 0) return l10n?.immediately ?? 'Immediately';
    if (_autoLockTimeout < 60) return l10n?.secondsCount(_autoLockTimeout) ?? '$_autoLockTimeout seconds';
    return l10n?.minutesCount(_autoLockTimeout ~/ 60) ?? '${_autoLockTimeout ~/ 60} minute(s)';
  }

  void _showAutoLockDialog() {
    final l10n = AppLocalizations.of(context);
    final options = [0, 30, 60, 120, 300, 600];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n?.autoLockTimeout ?? 'Auto-lock Timeout'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  options.map((seconds) {
                    return RadioListTile<int>(
                      title: Text(_formatTimeout(seconds)),
                      value: seconds,
                      groupValue: _autoLockTimeout,
                      onChanged: (value) async {
                        if (value != null) {
                          await _secureStorage.setAutoLockTimeout(value);
                          setState(() => _autoLockTimeout = value);
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  String _formatTimeout(int seconds) {
    final l10n = AppLocalizations.of(context);
    if (seconds == 0) return l10n?.immediately ?? 'Immediately';
    if (seconds < 60) return l10n?.secondsCount(seconds) ?? '$seconds seconds';
    return l10n?.minutesCount(seconds ~/ 60) ?? '${seconds ~/ 60} minute(s)';
  }

  Widget _buildScreenshotTile() {
    final l10n = AppLocalizations.of(context);
    return SwitchListTile(
      title: Text(l10n?.allowScreenshots ?? 'Allow Screenshots'),
      subtitle: Text(
        l10n?.screenshotsDescription ??
            'When disabled, screenshots are blocked',
      ),
      value: _screenshotEnabled,
      onChanged: (value) async {
        await ScreenshotService.setSecure(!value);
        await _secureStorage.setScreenshotEnabled(value);
        setState(() => _screenshotEnabled = value);
      },
    );
  }

  Widget _buildTapToRevealTile() {
    final l10n = AppLocalizations.of(context);
    return SwitchListTile(
      title: Text(l10n?.tapToReveal ?? 'Tap to Reveal'),
      subtitle: Text(
        l10n?.tapToRevealDescription ?? 'Hide codes by default, tap to show',
      ),
      value: _tapToReveal,
      onChanged: (value) async {
        await _secureStorage.setTapToRevealEnabled(value);
        setState(() => _tapToReveal = value);
      },
    );
  }

  Widget _buildImportTile() {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.download),
      title: Text(l10n?.importAuthenticators ?? 'Import Authenticators'),
      subtitle: Text(l10n?.importFromOtherApps ?? 'Import from other 2FA apps'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ImportScreen()),
        );
      },
    );
  }

  Widget _buildExportTile() {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.upload),
      title: Text(l10n?.exportBackup ?? 'Export Backup'),
      subtitle: Text(
        l10n?.exportYourAuthenticators ?? 'Export your authenticators',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showExportBackupDialog(context);
      },
    );
  }

  Future<String?> _showExportPasswordDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    String error = '';
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(l10n?.backupPassword ?? 'Backup Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n?.enterPasswordEncrypt ?? 'Enter a password to encrypt the backup'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: InputDecoration(labelText: l10n?.password ?? 'Password'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration:
                      InputDecoration(labelText: l10n?.confirmPassword ?? 'Confirm Password'),
                ),
                if (error.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (controller.text.isEmpty) {
                    setDialogState(() => error = l10n?.passwordCannotBeEmpty ?? 'Password cannot be empty');
                    return;
                  }
                  if (controller.text != confirmController.text) {
                    setDialogState(() => error = l10n?.passwordsDoNotMatch ?? 'Passwords do not match');
                    return;
                  }
                  Navigator.pop(context, controller.text);
                },
                child: Text(l10n?.export ?? 'Export'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBackupTile() {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.backup),
      title: Text(l10n?.autoBackup ?? 'Auto Backup'),
      subtitle: Text(
        l10n?.configureAutomaticBackups ?? 'Configure automatic backups',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _showAutoBackupDialog();
      },
    );
  }

  void _showAutoBackupDialog() {
    final l10n = AppLocalizations.of(context);
    final autoBackupService = getIt<AutoBackupService>();

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: Text(l10n?.autoBackup ?? 'Auto Backup'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SwitchListTile(
                        title: Text(
                          l10n?.enableAutoBackup ?? 'Enable Auto Backup',
                        ),
                        subtitle: Text(
                          _autoBackupEnabled
                              ? (l10n?.autoBackupEnabled ?? 'Automatic backups are active')
                              : (l10n?.autoBackupDisabled ?? 'Automatic backups are off'),
                        ),
                        value: _autoBackupEnabled,
                        onChanged: (value) async {
                          await _secureStorage.setAutoBackupEnabled(value);
                          setDialogState(() {
                            _autoBackupEnabled = value;
                          });
                          setState(() {});

                          if (value) {
                            await autoBackupService.scheduleAutoBackup();
                          } else {
                            await autoBackupService.cancelAutoBackup();
                          }
                        },
                      ),
                      const Divider(),
                      ListTile(
                        title: Text(
                          l10n?.backupFrequency ?? 'Backup Frequency',
                        ),
                        subtitle: Text(_frequencyLabel(_autoBackupFrequency, l10n)),
                        trailing: const Icon(Icons.chevron_right),
                        enabled: _autoBackupEnabled,
                        onTap: _autoBackupEnabled
                            ? () {
                                Navigator.pop(context);
                                _showFrequencyPicker();
                              }
                            : null,
                      ),
                      ListTile(
                        title: Text(
                          l10n?.backupPassword ?? 'Backup Password',
                        ),
                        subtitle: Text(
                          l10n?.setBackupPasswordDescription ??
                              'Set a password for automatic backups',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        enabled: _autoBackupEnabled,
                        onTap: _autoBackupEnabled
                            ? () async {
                                final password = await _showExportPasswordDialog(context);
                                if (password != null && mounted) {
                                  await _secureStorage.setBackupPassword(password);
                                }
                              }
                            : null,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n?.close ?? 'Close'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showFrequencyPicker() {
    final l10n = AppLocalizations.of(context);
    final options = [
      (3600, l10n?.everyHour ?? 'Every hour'),
      (21600, l10n?.every6Hours ?? 'Every 6 hours'),
      (43200, l10n?.every12Hours ?? 'Every 12 hours'),
      (86400, l10n?.daily ?? 'Daily'),
      (172800, l10n?.every2Days ?? 'Every 2 days'),
      (604800, l10n?.weekly ?? 'Weekly'),
    ];

    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n?.backupFrequency ?? 'Backup Frequency'),
        children: options.map((opt) {
          return RadioListTile<int>(
            title: Text(opt.$2),
            value: opt.$1,
            groupValue: _autoBackupFrequency,
            onChanged: (value) async {
              if (value != null) {
                await _secureStorage.setAutoBackupFrequency(value);
                setState(() => _autoBackupFrequency = value);
                Navigator.pop(context);

                // Reschedule with new frequency
                final autoBackupService = getIt<AutoBackupService>();
                await autoBackupService.scheduleAutoBackup();
              }
            },
          );
        }).toList(),
      ),
    );
  }

  String _frequencyLabel(int seconds, AppLocalizations? l10n) {
    switch (seconds) {
      case 3600:
        return l10n?.everyHour ?? 'Every hour';
      case 21600:
        return l10n?.every6Hours ?? 'Every 6 hours';
      case 43200:
        return l10n?.every12Hours ?? 'Every 12 hours';
      case 86400:
        return l10n?.daily ?? 'Daily';
      case 172800:
        return l10n?.every2Days ?? 'Every 2 days';
      case 604800:
        return l10n?.weekly ?? 'Weekly';
      default:
        return '${seconds ~/ 3600}h';
    }
  }

  Widget _buildThemeTile() {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context);
        return ListTile(
          leading: const Icon(Icons.palette),
          title: Text(l10n?.theme ?? 'Theme'),
          subtitle: Text(_themeModeText(state.mode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(),
        );
      },
    );
  }

  String _themeModeText(ThemeMode mode) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case ThemeMode.light:
        return l10n?.light ?? 'Light';
      case ThemeMode.dark:
        return l10n?.dark ?? 'Dark';
      case ThemeMode.system:
        return l10n?.systemDefault ?? 'System default';
    }
  }

  void _showThemeDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n?.theme ?? 'Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  ThemeMode.values.map((mode) {
                    return RadioListTile<ThemeMode>(
                      title: Text(_themeModeText(mode)),
                      value: mode,
                      groupValue: context.read<ThemeBloc>().state.mode,
                      onChanged: (value) {
                        if (value != null) {
                          context.read<ThemeBloc>().add(SetThemeMode(value));
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  Widget _buildSortModeTile() {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.sort),
      title: Text(l10n?.sortMode ?? 'Sort Mode'),
      subtitle: Text(_sortModeText()),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showSortModeDialog(),
    );
  }

  String _sortModeText() {
    return _sortModeTextFor(_sortMode);
  }

  void _showSortModeDialog() {
    final options = ['manual', 'name', 'mostUsed', 'dateAdded'];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(AppLocalizations.of(context)?.sortMode ?? 'Sort Mode'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  options.map((mode) {
                    return RadioListTile<String>(
                      title: Text(_sortModeTextFor(mode)),
                      value: mode,
                      groupValue: _sortMode,
                      onChanged: (value) async {
                        if (value != null) {
                          await _secureStorage.setSortMode(value);
                          setState(() => _sortMode = value);
                          Navigator.pop(context);
                        }
                      },
                    );
                  }).toList(),
            ),
          ),
    );
  }

  String _sortModeTextFor(String mode) {
    final l10n = AppLocalizations.of(context);
    switch (mode) {
      case 'manual':
        return l10n?.manual ?? 'Manual (drag to reorder)';
      case 'name':
        return l10n?.byName ?? 'By name';
      case 'mostUsed':
        return l10n?.mostUsed ?? 'Most used';
      case 'dateAdded':
        return l10n?.dateAdded ?? 'Date added';
      default:
        return mode;
    }
  }

  // --- Password management ---

  Widget _buildPasswordTile() {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.lock_outline),
      title: Text(_hasPassword
          ? (l10n?.changePassword ?? 'Change Password')
          : (l10n?.setPassword ?? 'Set Password')),
      subtitle: Text(
        _hasPassword
            ? (l10n?.changeOrRemovePassword ?? 'Change or remove your app password')
            : (l10n?.protectWithPassword ?? 'Protect your app with a password'),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _hasPassword ? _showPasswordOptions() : _showSetPasswordDialog(),
    );
  }

  void _showPasswordOptions() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.password ?? 'Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n?.changePassword ?? 'Change Password'),
              onTap: () {
                Navigator.pop(context);
                _showChangePasswordDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(l10n?.removePassword ?? 'Remove Password'),
              onTap: () {
                Navigator.pop(context);
                _showRemovePasswordDialog();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }

  void _showSetPasswordDialog() {
    final l10n = AppLocalizations.of(context);
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n?.setPassword ?? 'Set Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n?.newPassword ?? 'New Password'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n?.confirmPassword ?? 'Confirm Password'),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (newCtrl.text.isEmpty) {
                  setDialogState(() => error = l10n?.passwordCannotBeEmpty ?? 'Password cannot be empty');
                  return;
                }
                if (newCtrl.text.length < 4) {
                  setDialogState(() => error = l10n?.passwordMinLength ?? 'Password must be at least 4 characters');
                  return;
                }
                if (newCtrl.text != confirmCtrl.text) {
                  setDialogState(() => error = l10n?.passwordsDoNotMatch ?? 'Passwords do not match');
                  return;
                }
                await _secureStorage.setPassword(newCtrl.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  await _loadSettings();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n?.passwordSetSuccess ?? 'Password set successfully')),
                    );
                  }
                }
              },
              child: Text(l10n?.save ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final l10n = AppLocalizations.of(context);
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n?.changePassword ?? 'Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n?.currentPassword ?? 'Current Password'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: newCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n?.newPassword ?? 'New Password'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n?.confirmNewPassword ?? 'Confirm New Password'),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final verified = await _secureStorage.verifyPassword(currentCtrl.text);
                if (!verified) {
                  setDialogState(() => error = l10n?.currentPasswordIncorrect ?? 'Current password is incorrect');
                  return;
                }
                if (newCtrl.text.isEmpty) {
                  setDialogState(() => error = l10n?.newPasswordCannotBeEmpty ?? 'New password cannot be empty');
                  return;
                }
                if (newCtrl.text.length < 4) {
                  setDialogState(() => error = l10n?.passwordMinLength ?? 'Password must be at least 4 characters');
                  return;
                }
                if (newCtrl.text != confirmCtrl.text) {
                  setDialogState(() => error = l10n?.passwordsDoNotMatch ?? 'Passwords do not match');
                  return;
                }
                await _secureStorage.setPassword(newCtrl.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  await _loadSettings();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n?.passwordChangedSuccess ?? 'Password changed successfully')),
                    );
                  }
                }
              },
              child: Text(l10n?.save ?? 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemovePasswordDialog() {
    final l10n = AppLocalizations.of(context);
    final currentCtrl = TextEditingController();
    String? error;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n?.removePassword ?? 'Remove Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n?.confirmRemovePassword ?? 'Enter your current password to confirm removal.'),
              const SizedBox(height: 8),
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n?.currentPassword ?? 'Current Password'),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final verified = await _secureStorage.verifyPassword(currentCtrl.text);
                if (!verified) {
                  setDialogState(() => error = l10n?.passwordIncorrect ?? 'Password is incorrect');
                  return;
                }
                await _secureStorage.removePassword();
                await _secureStorage.setBiometricEnabled(false);
                if (context.mounted) {
                  Navigator.pop(context);
                  await _loadSettings();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n?.passwordRemoved ?? 'Password removed')),
                    );
                  }
                }
              },
              child: Text(l10n?.remove ?? 'Remove'),
            ),
          ],
        ),
      ),
    );
  }

  // --- Code group size ---

  Widget _buildCodeGroupSizeTile() {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.grid_view),
      title: Text(l10n?.codeGroupSize ?? 'Code Group Size'),
      subtitle: Text(l10n?.digitsPerGroup(_codeGroupSize) ?? '$_codeGroupSize digits per group'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showCodeGroupSizeDialog(),
    );
  }

  void _showCodeGroupSizeDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.codeGroupSize ?? 'Code Group Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [3, 4].map((size) {
            return RadioListTile<int>(
              title: Text(l10n?.digitsPerGroup(size) ?? '$size digits per group'),
              value: size,
              groupValue: _codeGroupSize,
              onChanged: (value) async {
                if (value != null) {
                  await _secureStorage.setCodeGroupSize(value);
                  setState(() => _codeGroupSize = value);
                  if (context.mounted) Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _openExternalLink(Uri uri) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.externalLinkTitle ?? 'External Link'),
        content: Text(
          l10n?.externalLinkContent('${uri.host}${uri.path}') ??
              'You are about to open an external link.\n\n${uri.host}${uri.path}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.externalLinkCancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.externalLinkConfirm ?? 'Open'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      _copyAndHint(uri);
      return;
    }

    if (!await canLaunchUrl(uri)) {
      _copyAndHint(uri);
      return;
    }
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      _copyAndHint(uri);
    }
  }

  void _copyAndHint(Uri uri) {
    Clipboard.setData(ClipboardData(text: uri.toString()));
    if (mounted) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.linkCopied ?? 'Link copied — please open in browser',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildAboutTile() {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(l10n?.about ?? 'About'),
      subtitle: Text('${l10n?.version ?? 'Version'} 1.0.0'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        showAboutDialog(
          context: context,
          applicationName: 'KeeAuth',
          applicationVersion: '1.0.0',
          applicationLegalese:
              '© 2025-present photowey\n\nLicensed under the GNU GPL v3.0.',
          applicationIcon: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.security, color: Colors.white),
          ),
          children: [
            ListTile(
              leading: const Icon(Icons.code),
              title: Text(l10n?.github ?? 'GitHub'),
              subtitle: const Text('github.com/photowey/keeauth'),
              onTap: () => _openExternalLink(Uri.parse('https://github.com/photowey/keeauth')),
            ),
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: Text(l10n?.reportIssue ?? 'Report Issue'),
              subtitle: Text(l10n?.helpUsImprove ?? 'Help us improve'),
              onTap: () => _openExternalLink(Uri.parse('https://github.com/photowey/keeauth/issues')),
            ),
          ],
        );
      },
    );
  }
}
