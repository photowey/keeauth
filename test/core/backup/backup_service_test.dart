import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/core/crypto/encryption_service.dart';
import 'package:keeauth/features/backup/domain/backup_service.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';

void main() {
  late BackupService service;
  late List<Authenticator> testAuthenticators;

  setUp(() {
    service = BackupService(EncryptionService());
    testAuthenticators = [
      Authenticator(
        secret: 'JBSWY3DPEHPK3PXP',
        issuer: 'Google',
        accountName: 'user@gmail.com',
        type: AuthenticatorType.totp,
        algorithm: OtpHashAlgorithm.sha1,
        digits: 6,
        period: 30,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
      Authenticator(
        secret: 'MFRGGZDFMZTWQ2LK',
        issuer: 'GitHub',
        accountName: 'dev',
        type: AuthenticatorType.totp,
        algorithm: OtpHashAlgorithm.sha256,
        digits: 6,
        period: 30,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    ];
  });

  group('BackupService', () {
    group('detectFormat', () {
      test('detects keeauth encrypted format', () async {
        final data = await service.createBackup(
          authenticators: testAuthenticators,
          format: BackupFormat.keeauth,
          password: 'test123',
        );
        final format = service.detectFormat(data);
        expect(format, BackupFormat.keeauth);
      });

      test('detects HTML format', () async {
        final data = await service.createBackup(
          authenticators: testAuthenticators,
          format: BackupFormat.html,
        );
        final format = service.detectFormat(data);
        expect(format, BackupFormat.html);
      });

      test('detects URI list format', () async {
        final data = await service.createBackup(
          authenticators: testAuthenticators,
          format: BackupFormat.uriList,
        );
        final format = service.detectFormat(data);
        expect(format, BackupFormat.uriList);
      });

      test('returns null for random bytes', () {
        final format = service.detectFormat(
          Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]),
        );
        expect(format, isNull);
      });
    });

    group('createBackup → restoreBackup round-trip', () {
      test('encrypted (keeauth) format', () async {
        const password = 'roundtripPW!';
        final data = await service.createBackup(
          authenticators: testAuthenticators,
          format: BackupFormat.keeauth,
          password: password,
        );
        final result = await service.restoreBackup(
          data: data, format: BackupFormat.keeauth, password: password,
        );

        expect(result.authenticators.length, 2);
        expect(result.authenticators[0].secret, 'JBSWY3DPEHPK3PXP');
        expect(result.authenticators[0].issuer, 'Google');
        expect(result.authenticators[1].secret, 'MFRGGZDFMZTWQ2LK');
      });

      test('wrong password throws', () async {
        final data = await service.createBackup(
          authenticators: testAuthenticators,
          format: BackupFormat.keeauth,
          password: 'correctPW',
        );
        expect(
          () => service.restoreBackup(data: data, format: BackupFormat.keeauth, password: 'wrongPW'),
          throwsA(anything),
        );
      });

      test('preserves all fields', () async {
        const password = 'fieldTest123';
        final steam = Authenticator(
          secret: 'STEAMSEEDDATA',
          issuer: 'Steam',
          accountName: 'gamer',
          type: AuthenticatorType.steam,
          algorithm: OtpHashAlgorithm.sha1,
          digits: 5,
          period: 30,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        );
        final data = await service.createBackup(
          authenticators: [steam],
          format: BackupFormat.keeauth,
          password: password,
        );
        final result = await service.restoreBackup(
          data: data, format: BackupFormat.keeauth, password: password,
        );

        final restored = result.authenticators.first;
        expect(restored.type, AuthenticatorType.steam);
        expect(restored.digits, 5);
        expect(restored.secret, 'STEAMSEEDDATA');
      });

      test('preserves categories in backup', () async {
        const password = 'categoryPW';
        final cat = Category(id: 'CAT001', name: 'Social', ranking: 0,
          createdAt: DateTime(2026), updatedAt: DateTime(2026), color: 0xFF4CAF50);
        final data = await service.createBackup(
          authenticators: testAuthenticators,
          format: BackupFormat.keeauth,
          password: password,
          categories: [cat],
          authenticatorCategories: {testAuthenticators[0].secret: ['CAT001']},
        );
        final result = await service.restoreBackup(
          data: data, format: BackupFormat.keeauth, password: password,
        );

        expect(result.categories, isNotNull);
        expect(result.categories!.length, 1);
        expect(result.categories!.first.name, 'Social');
        expect(result.authenticatorCategories, isNotNull);
        expect(result.authenticatorCategories!.length, 1);
      });
    });
  });
}
