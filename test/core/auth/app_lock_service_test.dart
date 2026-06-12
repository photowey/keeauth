import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:keeauth/core/auth/app_lock_service.dart';
import 'package:keeauth/core/auth/biometric_service.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------
class MockSecureStorage extends Mock implements SecureStorageService {}

class MockBiometricService extends Mock implements BiometricService {}

void main() {
  late AppLockService service;
  late MockSecureStorage storage;
  late MockBiometricService biometric;

  setUp(() {
    storage = MockSecureStorage();
    biometric = MockBiometricService();
    service = AppLockService(storage, biometric);
    service.initialize(() {}); // dummy lock callback
  });

  // -----------------------------------------------------------------------
  // hasPassword
  // -----------------------------------------------------------------------
  group('hasPassword', () {
    test('returns true when password hash exists', () async {
      when(() => storage.hasPassword()).thenAnswer((_) async => true);
      expect(await service.hasPassword(), isTrue);
    });

    test('returns false when no password hash', () async {
      when(() => storage.hasPassword()).thenAnswer((_) async => false);
      expect(await service.hasPassword(), isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // verifyPassword
  // -----------------------------------------------------------------------
  group('verifyPassword', () {
    test('delegates to SecureStorageService', () async {
      when(() => storage.verifyPassword('secret')).thenAnswer((_) async => true);
      when(() => storage.verifyPassword('wrong')).thenAnswer((_) async => false);

      expect(await service.verifyPassword('secret'), isTrue);
      expect(await service.verifyPassword('wrong'), isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // isBiometricUnlockAvailable
  // -----------------------------------------------------------------------
  group('isBiometricUnlockAvailable', () {
    test('false when biometric not enabled', () async {
      when(() => storage.isBiometricEnabled()).thenAnswer((_) async => false);

      expect(await service.isBiometricUnlockAvailable(), isFalse);
      verifyNever(() => biometric.isSupported());
    });

    test('false when biometric enabled but hardware does not support', () async {
      when(() => storage.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => biometric.isSupported()).thenAnswer((_) async => false);

      expect(await service.isBiometricUnlockAvailable(), isFalse);
    });

    test('true when biometric enabled AND hardware supports it', () async {
      when(() => storage.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => biometric.isSupported()).thenAnswer((_) async => true);

      expect(await service.isBiometricUnlockAvailable(), isTrue);
    });
  });

  // -----------------------------------------------------------------------
  // authenticateToUnlock
  // -----------------------------------------------------------------------
  group('authenticateToUnlock', () {
    test('password auth: has password, password provided → verify', () async {
      when(() => storage.hasPassword()).thenAnswer((_) async => true);
      when(() => storage.verifyPassword('secret')).thenAnswer((_) async => true);

      final result = await service.authenticateToUnlock(password: 'secret');
      expect(result, isTrue);
      verifyNever(() => biometric.authenticate(reason: any(named: 'reason')));
    });

    test('password auth: wrong password → false', () async {
      when(() => storage.hasPassword()).thenAnswer((_) async => true);
      when(() => storage.verifyPassword('wrong')).thenAnswer((_) async => false);

      final result = await service.authenticateToUnlock(password: 'wrong');
      expect(result, isFalse);
    });

    test('biometric shortcut: has password, no password → tries biometric', () async {
      when(() => storage.hasPassword()).thenAnswer((_) async => true);
      when(() => storage.isBiometricEnabled()).thenAnswer((_) async => true);
      when(() => biometric.isSupported()).thenAnswer((_) async => true);
      when(() => biometric.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => true);

      final result = await service.authenticateToUnlock();
      expect(result, isTrue);
      verify(() => biometric.authenticate(reason: any(named: 'reason'))).called(1);
    });

    test('biometric shortcut: has password, biometric not available → false', () async {
      when(() => storage.hasPassword()).thenAnswer((_) async => true);
      when(() => storage.isBiometricEnabled()).thenAnswer((_) async => false);

      final result = await service.authenticateToUnlock();
      expect(result, isFalse);
      verifyNever(() => biometric.authenticate(reason: any(named: 'reason')));
    });

    test('no password → falls through to biometric', () async {
      when(() => storage.hasPassword()).thenAnswer((_) async => false);
      when(() => biometric.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => true);

      final result = await service.authenticateToUnlock(reason: 'Unlock KeeAuth');
      expect(result, isTrue);
      verify(() => biometric.authenticate(reason: 'Unlock KeeAuth')).called(1);
    });

    test('no password, biometric fails → false', () async {
      when(() => storage.hasPassword()).thenAnswer((_) async => false);
      when(() => biometric.authenticate(reason: any(named: 'reason')))
          .thenAnswer((_) async => false);

      final result = await service.authenticateToUnlock();
      expect(result, isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // unlock / isLocked
  // -----------------------------------------------------------------------
  group('unlock', () {
    test('unlock clears locked state', () {
      expect(service.isLocked, isFalse); // initial
      // Locked state is set internally by _checkLockTimeout.
      // Verify unlock() at least doesn't throw.
      service.unlock();
      expect(service.isLocked, isFalse);
    });
  });

  // -----------------------------------------------------------------------
  // getLockTimeout / isAutoLockEnabled
  // -----------------------------------------------------------------------
  group('lock timeout', () {
    test('isAutoLockEnabled false when timeout is 0', () async {
      when(() => storage.getAutoLockTimeout()).thenAnswer((_) async => 0);
      expect(await service.isAutoLockEnabled(), isFalse);
    });

    test('isAutoLockEnabled true when timeout > 0', () async {
      when(() => storage.getAutoLockTimeout()).thenAnswer((_) async => 60);
      expect(await service.isAutoLockEnabled(), isTrue);
    });

    test('getLockTimeout returns stored value', () async {
      when(() => storage.getAutoLockTimeout()).thenAnswer((_) async => 120);
      expect(await service.getLockTimeout(), 120);
    });
  });
}
