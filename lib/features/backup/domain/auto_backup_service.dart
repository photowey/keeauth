import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

import 'package:keeauth/core/storage/database_helper.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';
import 'package:keeauth/core/crypto/encryption_service.dart';
import 'backup_service.dart';
import 'package:keeauth/features/authenticator/data/repositories/authenticator_repository.dart';
import 'package:keeauth/features/authenticator/domain/usecases/authenticator_service.dart';
import 'package:keeauth/features/authenticator/data/repositories/category_repository.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';

const String autoBackupTask = 'autoBackupTask';
const String autoBackupDirName = 'keeauth_backups';
const int maxBackupFiles = 5;

/// Background service for automatic encrypted backups.
///
/// Schedules periodic backup tasks via [Workmanager] and writes AES-256-GCM
/// encrypted backup files to the app's documents directory.
class AutoBackupService {
  final SecureStorageService _secureStorage;
  final AuthenticatorService _authenticatorService;
  final BackupService _backupService;

  AutoBackupService(
    this._secureStorage,
    this._authenticatorService,
    this._backupService,
  );

  /// Initialize workmanager for background task scheduling.
  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  /// Schedule periodic auto-backup based on stored preferences.
  ///
  /// If auto-backup is disabled this is a no-op.
  Future<void> scheduleAutoBackup() async {
    final enabled = await _secureStorage.isAutoBackupEnabled();
    if (!enabled) return;

    final frequency = await _secureStorage.getAutoBackupFrequency();

    await Workmanager().registerPeriodicTask(
      autoBackupTask,
      autoBackupTask,
      frequency: Duration(seconds: frequency),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  /// Cancel all scheduled auto-backup tasks.
  Future<void> cancelAutoBackup() async {
    await Workmanager().cancelByUniqueName(autoBackupTask);
  }

  /// Perform an auto-backup: fetch all authenticators, encrypt with stored
  /// password, and write to the backups directory.
  ///
  /// Returns the path of the created backup file, or `null` on failure.
  Future<String?> performBackup() async {
    try {
      final enabled = await _secureStorage.isAutoBackupEnabled();
      if (!enabled) {
    // log removed
        return null;
      }

      final backupPassword = await _secureStorage.getBackupPassword();
      if (backupPassword == null || backupPassword.isEmpty) {
    // log removed
        return null;
      }

      final authenticators = await _authenticatorService.getAll();
      if (authenticators.isEmpty) {
    // log removed
        return null;
      }

      final categories = await _authenticatorService.getAllCategories();

      // Build category mapping: secret → category IDs
      final authenticatorCategories = <String, List<String>>{};
      for (final auth in authenticators) {
        if (auth.categoryIds.isNotEmpty) {
          authenticatorCategories[auth.secret] = auth.categoryIds;
        }
      }

      final backupData = await _backupService.createBackup(
        authenticators: authenticators,
        format: BackupFormat.keeauth,
        password: backupPassword,
        categories: categories,
        authenticatorCategories: authenticatorCategories,
      );

      final backupDir = await _getBackupDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final fileName = 'keeauth_auto_$timestamp.keebaup';
      final file = File('${backupDir.path}/$fileName');

      await file.writeAsBytes(backupData, flush: true);
    // log removed

      await _rotateOldBackups(backupDir);
      return file.path;
    } catch (e) {
    // log removed
    // log removed
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  /// Resolve (and create if needed) the backup directory.
  Future<Directory> _getBackupDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${documentsDir.path}/$autoBackupDirName');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Keep only the [maxBackupFiles] most recent backup files.
  Future<void> _rotateOldBackups(Directory backupDir) async {
    final files = await backupDir
        .list()
        .where((e) => e is File && e.path.endsWith('.keebaup'))
        .toList();

    if (files.length <= maxBackupFiles) return;

    // Sort by modification time, newest first
    final sorted = List<FileSystemEntity>.from(files)
      ..sort((a, b) {
        final aStat = a.statSync();
        final bStat = b.statSync();
        return bStat.modified.compareTo(aStat.modified);
      });

    // Delete oldest files beyond the limit
    for (var i = maxBackupFiles; i < sorted.length; i++) {
      final file = sorted[i] as File;
      try {
        await file.delete();
    // log removed
      } catch (_) {
        // Best-effort cleanup
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Background callback dispatcher
// ---------------------------------------------------------------------------

/// Top-level entry point for Workmanager background execution.
///
/// Runs in a separate isolate.  Initialises a minimal set of services
/// (database, crypto, storage) so it can produce a fresh encrypted backup
/// without relying on the foreground DI container.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task != autoBackupTask) return false;

      // Minimal service wiring for the background isolate
      final secureStorage = SecureStorageService();
      final dbHelper = DatabaseHelper();
      final otpGenerator = OtpGenerator();
      final encryptionService = EncryptionService();

      final authRepo = AuthenticatorRepository(dbHelper);
      final catRepo = CategoryRepository(dbHelper);
      final authService = AuthenticatorService(authRepo, catRepo, otpGenerator);
      final backupService = BackupService(encryptionService);

      final autoBackupService = AutoBackupService(
        secureStorage,
        authService,
        backupService,
      );

      final path = await autoBackupService.performBackup();
      if (path != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  });
}
