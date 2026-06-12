import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'package:keeauth/di/injection.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'package:keeauth/features/backup/domain/backup_service.dart';

/// Shared export-backup dialog, callable from any screen.
///
/// Offers three formats: encrypted (.keebaup), HTML, and plain URI list.
/// Restore counterpart is the "Restore" button in [AddAuthenticatorSheet].
///
/// Usage:
/// ```dart
/// showExportBackupDialog(context);
/// ```
void showExportBackupDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n?.exportBackup ?? 'Export Backup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(l10n?.encryptedBackupFile ?? 'Encrypted Backup (.keebaup)'),
            subtitle: Text(
              l10n?.passwordProtectedFile ?? 'Password-protected encrypted file',
            ),
            onTap: () {
              Navigator.pop(ctx);
              _exportEncrypted(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.html),
            title: Text(l10n?.htmlFile ?? 'HTML File'),
            subtitle: Text(
              l10n?.humanReadableHtml ?? 'Human-readable HTML table',
            ),
            onTap: () {
              Navigator.pop(ctx);
              _exportHtml(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: Text(l10n?.uriList ?? 'URI List'),
            subtitle: Text(
              l10n?.plainTextUris ?? 'Plain text otpauth:// URIs',
            ),
            onTap: () {
              Navigator.pop(ctx);
              _exportUriList(context);
            },
          ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Export implementations
// ---------------------------------------------------------------------------

Future<void> _exportEncrypted(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final password = await _askPassword(context);
  if (password == null || password.isEmpty) return;

  final file = await _withLoading(
    context,
    l10n?.creatingBackup ?? 'Creating backup...',
    () async {
      final state = context.read<AuthenticatorBloc>().state;
      final backupService = getIt<BackupService>();
      final data = await backupService.createBackup(
        authenticators: state.authenticators,
        format: BackupFormat.keeauth,
        password: password,
        categories: state.categories,
        authenticatorCategories: _categoryMap(state.authenticators),
      );
      return _writeFile(data, 'keebaup');
    },
  );
  if (file == null) return;

  _showResult(context, l10n, file.path);
}

Future<void> _exportHtml(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final file = await _withLoading(
    context,
    l10n?.creatingBackup ?? 'Creating backup...',
    () async {
      final state = context.read<AuthenticatorBloc>().state;
      final backupService = getIt<BackupService>();
      final data = await backupService.createBackup(
        authenticators: state.authenticators,
        format: BackupFormat.html,
      );
      return _writeFile(data, 'html');
    },
  );
  if (file == null) return;

  _showResult(context, l10n, file.path);
}

Future<void> _exportUriList(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final file = await _withLoading(
    context,
    l10n?.creatingBackup ?? 'Creating backup...',
    () async {
      final state = context.read<AuthenticatorBloc>().state;
      final backupService = getIt<BackupService>();
      final data = await backupService.createBackup(
        authenticators: state.authenticators,
        format: BackupFormat.uriList,
      );
      return _writeFile(data, 'txt');
    },
  );
  if (file == null) return;

  _showResult(context, l10n, file.path);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Future<File> _writeFile(Uint8List data, String ext) async {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final fileName = 'keeauth_backup_$timestamp.$ext';

  // 1. Try public Downloads paths (user-visible in file manager)
  for (final p in ['/storage/emulated/0/Download', '/sdcard/Download']) {
    try {
      final dir = Directory(p);
      if (await dir.exists()) {
        final file = File('$p/$fileName');
        await file.writeAsBytes(data);
        return file;
      }
    } catch (_) {}
  }

  // 2. path_provider's Downloads API
  try {
    final dl = await getDownloadsDirectory();
    if (dl != null) {
      final file = File('${dl.path}/$fileName');
      await file.writeAsBytes(data);
      return file;
    }
  } catch (_) {}

  // 3. App external storage
  try {
    final extDir = await getExternalStorageDirectory();
    if (extDir != null) {
      final backupDir = Directory('${extDir.path}/backups');
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }
      final file = File('${backupDir.path}/$fileName');
      await file.writeAsBytes(data);
      return file;
    }
  } catch (_) {}

  // 4. App documents (sandbox)
  final docDir = await getApplicationDocumentsDirectory();
  final backupDir = Directory('${docDir.path}/backups');
  if (!await backupDir.exists()) {
    await backupDir.create(recursive: true);
  }
  final file = File('${backupDir.path}/$fileName');
  await file.writeAsBytes(data);
  return file;
}

Future<String?> _askPassword(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController();
  final confirmController = TextEditingController();
  String? error;
  return showDialog<String>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(l10n?.backupPassword ?? 'Backup Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n?.enterPasswordEncrypt ?? 'Enter a password to encrypt'),
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
              decoration: InputDecoration(
                labelText: l10n?.confirmPassword ?? 'Confirm Password',
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  error!,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isEmpty) {
                setDialogState(
                  () => error = l10n?.passwordCannotBeEmpty ?? 'Password cannot be empty',
                );
                return;
              }
              if (controller.text != confirmController.text) {
                setDialogState(
                  () => error = l10n?.passwordsDoNotMatch ?? 'Passwords do not match',
                );
                return;
              }
              Navigator.pop(ctx, controller.text);
            },
            child: Text(l10n?.export ?? 'Export'),
          ),
        ],
      ),
    ),
  );
}

Map<String, List<String>> _categoryMap(List<Authenticator> authenticators) {
  final map = <String, List<String>>{};
  for (final auth in authenticators) {
    if (auth.categoryIds.isNotEmpty) {
      map[auth.secret] = List<String>.from(auth.categoryIds);
    }
  }
  return map;
}

void _showResult(BuildContext context, AppLocalizations? l10n, String path) {
  if (!context.mounted) return;

  final fileName = path.split('/').last;
  final dir = path.substring(0, path.length - fileName.length - 1);

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
      title: Text(l10n?.exportedTo ?? 'Backup saved'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n?.exportedTo ?? 'Saved to:'),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$dir/\n$fileName',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n?.done ?? 'Done'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            Share.shareXFiles([XFile(path)], subject: 'keeauth Backup');
          },
          icon: const Icon(Icons.share),
          label: Text(l10n?.share ?? 'Share'),
        ),
      ],
    ),
  );
}

void _showError(BuildContext context, AppLocalizations? l10n, Object e) {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l10n?.exportFailed ?? 'Export failed'}: $e')),
    );
  }
}

/// Show a non-dismissible loading dialog, run [task], dismiss, return result.
Future<T?> _withLoading<T>(
  BuildContext context,
  String message,
  Future<T> Function() task,
) async {
  // ignore: use_build_context_synchronously
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => PopScope(
      canPop: false,
      child: AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 24),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    ),
  );

  T? result;
  try {
    result = await task();
  } catch (e) {
    final l10n = AppLocalizations.of(context);
    _showError(context, l10n, e);
  }

  if (context.mounted) {
    Navigator.of(context).pop(); // dismiss loading
  }
  return result;
}
