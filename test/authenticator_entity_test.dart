import 'package:flutter_test/flutter_test.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';

void main() {
  group('Authenticator Entity', () {
    final now = DateTime.now();

    test('should create authenticator with required fields', () {
      final authenticator = Authenticator(
        secret: 'JBSWY3DPEHPK3PXP',
        issuer: 'Google',
        accountName: 'user@gmail.com',
        createdAt: now,
        updatedAt: now,
      );

      expect(authenticator.secret, equals('JBSWY3DPEHPK3PXP'));
      expect(authenticator.issuer, equals('Google'));
      expect(authenticator.accountName, equals('user@gmail.com'));
    });

    test('should have correct default values', () {
      final authenticator = Authenticator(
        secret: 'TEST',
        issuer: 'Test',
        accountName: 'test@test.com',
        createdAt: now,
        updatedAt: now,
      );

      expect(authenticator.type, equals(AuthenticatorType.totp));
      expect(authenticator.algorithm, equals(OtpHashAlgorithm.sha1));
      expect(authenticator.digits, equals(6));
      expect(authenticator.period, equals(30));
      expect(authenticator.counter, equals(0));
      expect(authenticator.ranking, equals(0));
    });

    test('should convert to map correctly', () {
      final authenticator = Authenticator(
        secret: 'JBSWY3DPEHPK3PXP',
        issuer: 'GitHub',
        accountName: 'developer@example.com',
        algorithm: OtpHashAlgorithm.sha256,
        digits: 6,
        period: 30,
        type: AuthenticatorType.totp,
        createdAt: now,
        updatedAt: now,
      );

      final map = authenticator.toMap();

      expect(map['secret'], equals('JBSWY3DPEHPK3PXP'));
      expect(map['issuer'], equals('GitHub'));
      expect(map['accountName'], equals('developer@example.com'));
      expect(map['algorithm'], equals('sha256'));
      expect(map['type'], equals('totp'));
    });

    test('should create from map correctly', () {
      final map = {
        'secret': 'JBSWY3DPEHPK3PXP',
        'issuer': 'Google',
        'accountName': 'user@gmail.com',
        'algorithm': 'SHA1',
        'digits': 6,
        'counter': 0,
        'type': 'TOTP',
        'period': 30,
        'ranking': 0,
        'createdAt': now.millisecondsSinceEpoch,
        'updatedAt': now.millisecondsSinceEpoch,
      };

      final authenticator = Authenticator.fromMap(map);

      expect(authenticator.secret, equals('JBSWY3DPEHPK3PXP'));
      expect(authenticator.issuer, equals('Google'));
      expect(authenticator.algorithm, equals(OtpHashAlgorithm.sha1));
    });

    test('should copy with new values', () {
      final original = Authenticator(
        secret: 'ORIGINAL',
        issuer: 'Original',
        accountName: 'original@test.com',
        createdAt: now,
        updatedAt: now,
      );

      final modified = original.copyWith(issuer: 'Modified');

      expect(modified.issuer, equals('Modified'));
      expect(modified.secret, equals('ORIGINAL'));
      expect(modified.accountName, equals('original@test.com'));
    });

    test('should return correct display name', () {
      final withIssuer = Authenticator(
        secret: 'TEST',
        issuer: 'Google',
        accountName: 'user@gmail.com',
        createdAt: now,
        updatedAt: now,
      );

      final withoutIssuer = Authenticator(
        secret: 'TEST',
        issuer: '',
        accountName: 'user@gmail.com',
        createdAt: now,
        updatedAt: now,
      );

      expect(withIssuer.displayName, equals('Google (user@gmail.com)'));
      expect(withoutIssuer.displayName, equals('user@gmail.com'));
    });
  });
}
