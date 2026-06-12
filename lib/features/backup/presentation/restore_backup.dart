import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pointycastle/pointycastle.dart';

import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/di/injection.dart';
import 'package:keeauth/features/backup/domain/backup_service.dart';
import 'package:keeauth/features/authenticator/domain/usecases/authenticator_service.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';

Future<void> restoreBackupFromFile(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final bloc = context.read<AuthenticatorBloc>();
  final messenger = ScaffoldMessenger.of(context);

  // 1. Pick file
  final result = await FilePicker.platform.pickFiles(type: FileType.any);
  if (result == null || result.files.isEmpty) return;
  final filePath = result.files.single.path;
  if (filePath == null) return;
  final data = await File(filePath).readAsBytes();

  // 2. Detect format
  final backupService = getIt<BackupService>();
  final format = backupService.detectFormat(data);
  if (format == null) {
    messenger.showSnackBar(SnackBar(content: Text(l10n?.couldNotDetectFormat ?? 'Could not detect format')));
    return;
  }

  // 3. Password dialog. On Restore click, content switches to spinner.
  //    The dialog is pushed once and popped once — no pop-then-push race.
  String? password;
  if (format == BackupFormat.keeauth) {
    password = await _passwordThenLoading(context, l10n);
    if (password == null || password.isEmpty) return;
  }

  // 4. Restore (dialog already shows spinner)
  try {
    final restoreResult = await backupService.restoreBackup(data: data, format: format, password: password);
    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.of(context, rootNavigator: true).pop(); // dismiss

    if (restoreResult.authenticators.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n?.noAuthenticators ?? 'No authenticators found')));
      return;
    }
    final service = getIt<AuthenticatorService>();
    int added = 0;
    final failed = <String>[];
    for (final auth in restoreResult.authenticators) {
      try {
        await service.add(secret: auth.secret, accountName: auth.accountName,
          issuer: auth.issuer, type: auth.type, algorithm: auth.algorithm,
          digits: auth.digits, period: auth.period, counter: auth.counter, pin: auth.pin);
        added++;
      } catch (_) {
        failed.add('${auth.issuer}: ${auth.accountName}');
      }
    }
    bloc.add(LoadAuthenticators());
    if (failed.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(l10n?.importedCount(added) ?? 'Imported $added')));
    } else {
      messenger.showSnackBar(SnackBar(
        content: Text('Imported $added/${restoreResult.authenticators.length}. Skipped: ${failed.join(", ")}'),
      ));
    }
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();
    final msg = e is InvalidCipherTextException
        ? (l10n?.incorrectPassword ?? 'Wrong password')
        : '${l10n?.error ?? 'Error'}: $e';
    messenger.showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// Show password dialog. On Restore, switch content to spinner IN PLACE.
/// Single push, single pop. No pop-then-push race on HarmonyOS.
Future<String?> _passwordThenLoading(BuildContext ctx, AppLocalizations? l10n) async {
  final controller = TextEditingController();
  final completer = Completer<String?>();
  var loading = false;

  showDialog(
    context: ctx,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (dCtx) {
      return StatefulBuilder(
        builder: (sCtx, setDialogState) {
          if (loading) {
            return AlertDialog(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 24),
                  Text(l10n?.restoringBackup ?? 'Restoring backup...'),
                ],
              ),
            );
          }
          return AlertDialog(
            title: Text(l10n?.enterBackupPassword ?? 'Enter Backup Password'),
            content: SizedBox(
              width: double.infinity,
              child: TextField(
                controller: controller, obscureText: true, autofocus: true,
                decoration: InputDecoration(
                  labelText: l10n?.password ?? 'Password',
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () { Navigator.pop(dCtx); completer.complete(null); },
                child: Text(l10n?.cancel ?? 'Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  setDialogState(() => loading = true);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => completer.complete(controller.text),
                  );
                },
                child: Text(l10n?.restore ?? 'Restore'),
              ),
            ],
          );
        },
      );
    },
  );
  return completer.future;
}
