import 'package:get_it/get_it.dart';
import 'package:keeauth/core/storage/database_helper.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/core/crypto/encryption_service.dart';
import 'package:keeauth/core/auth/biometric_service.dart';
import 'package:keeauth/features/authenticator/data/repositories/authenticator_repository.dart';
import 'package:keeauth/features/authenticator/data/repositories/category_repository.dart';
import 'package:keeauth/features/authenticator/domain/usecases/authenticator_service.dart';
import 'package:keeauth/features/backup/domain/backup_service.dart';
import 'package:keeauth/features/backup/domain/auto_backup_service.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> configureDependencies() async {
  // Core
  getIt.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  getIt.registerLazySingleton<OtpGenerator>(() => OtpGenerator());
  getIt.registerLazySingleton<EncryptionService>(() => EncryptionService());
  getIt.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  getIt.registerLazySingleton<BiometricService>(() => BiometricService());

  // Repositories
  getIt.registerLazySingleton<AuthenticatorRepository>(
    () => AuthenticatorRepository(getIt<DatabaseHelper>()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<DatabaseHelper>()),
  );

  // Services
  getIt.registerLazySingleton<AuthenticatorService>(
    () => AuthenticatorService(
      getIt<AuthenticatorRepository>(),
      getIt<CategoryRepository>(),
      getIt<OtpGenerator>(),
    ),
  );

  getIt.registerLazySingleton<BackupService>(
    () => BackupService(getIt<EncryptionService>()),
  );

  getIt.registerLazySingleton<AutoBackupService>(
    () => AutoBackupService(
      getIt<SecureStorageService>(),
      getIt<AuthenticatorService>(),
      getIt<BackupService>(),
    ),
  );
}
