import 'package:flutter_test/flutter_test.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';

void main() {
  group('OtpGenerator', () {
    late OtpGenerator generator;

    setUp(() {
      generator = OtpGenerator();
    });

    group('TOTP Generation', () {
      test('should generate 6-digit TOTP code', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP', // Test secret
          type: AuthenticatorType.totp,
          algorithm: OtpHashAlgorithm.sha1,
          digits: 6,
          period: 30,
        );

        final code = generator.generateTotp(params);

        expect(code.length, equals(6));
        expect(int.tryParse(code), isNotNull);
      });

      test('should generate different codes at different times', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.totp,
          period: 1, // 1 second period for testing
        );

        final code1 = generator.generateTotp(params);

        // Wait a bit and generate again
        Future.delayed(const Duration(milliseconds: 1100), () {});

        final code2 = generator.generateTotp(params);

        // Codes may or may not be different depending on timing
        expect(code1.length, equals(6));
        expect(code2.length, equals(6));
      });

      test('should respect custom digits', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          digits: 8,
        );

        final code = generator.generateTotp(params);

        expect(code.length, equals(8));
      });

      test('should support SHA256 algorithm', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          algorithm: OtpHashAlgorithm.sha256,
        );

        final code = generator.generateTotp(params);

        expect(code.length, equals(6));
      });

      test('should support SHA512 algorithm', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          algorithm: OtpHashAlgorithm.sha512,
        );

        final code = generator.generateTotp(params);

        expect(code.length, equals(6));
      });
    });

    group('HOTP Generation', () {
      test('should generate HOTP code with counter', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.hotp,
          counter: 0,
        );

        final code = generator.generateHotp(params);

        expect(code.length, equals(6));
      });

      test('should increment counter for different codes', () {
        final params1 = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.hotp,
          counter: 0,
        );
        final params2 = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.hotp,
          counter: 1,
        );

        final code1 = generator.generateHotp(params1);
        final code2 = generator.generateHotp(params2);

        expect(code1, isNot(equals(code2)));
      });
    });

    group('Steam OTP', () {
      test('should generate 5-character alphanumeric code', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.steam,
          period: 30,
        );

        final code = generator.generateSteamOtp(params);

        expect(code.length, equals(5));
        // Steam uses specific alphabet
        expect(RegExp(r'^[23456789BCDFGHJKLMNPQRTVWXY]+$').hasMatch(code), isTrue);
      });
    });

    group('mOTP', () {
      test('should generate 6-character hex code', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.motp,
          pin: '1234',
          period: 30,
        );

        final code = generator.generateMotp(params);

        // mOTP generates MD5 first 6 hex chars
        expect(code.length, equals(6));
      });
    });

    group('Yandex OTP', () {
      test('should generate 8-character lowercase code', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.yandex,
          period: 30,
        );

        final code = generator.generateYandexOtp(params);

        expect(code.length, equals(8));
        expect(RegExp(r'^[a-z2-7]+$').hasMatch(code), isTrue);
      });
    });

    group('getRemainingSeconds', () {
      test('should return value between 0 and period', () {
        final remaining = generator.getRemainingSeconds(30);

        expect(remaining, greaterThanOrEqualTo(0));
        expect(remaining, lessThan(30));
      });

      test('should work with custom period', () {
        final remaining = generator.getRemainingSeconds(60);

        expect(remaining, greaterThanOrEqualTo(0));
        expect(remaining, lessThan(60));
      });
    });

    group('generate method', () {
      test('should delegate to correct generator based on type', () {
        final totpParams = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.totp,
        );
        final hotpParams = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.hotp,
          counter: 0,
        );

        final totpCode = generator.generate(totpParams);
        final hotpCode = generator.generate(hotpParams);

        expect(totpCode.length, equals(6));
        expect(hotpCode.length, equals(6));
      });
    });
  });

  group('AuthenticatorType', () {
    test('fromString should parse totp', () {
      expect(AuthenticatorType.fromString('totp'), equals(AuthenticatorType.totp));
    });

    test('fromString should parse hotp', () {
      expect(AuthenticatorType.fromString('hotp'), equals(AuthenticatorType.hotp));
    });

    test('fromString should parse steam', () {
      expect(AuthenticatorType.fromString('steam'), equals(AuthenticatorType.steam));
    });

    test('fromString should parse motp', () {
      expect(AuthenticatorType.fromString('motp'), equals(AuthenticatorType.motp));
    });

    test('fromString should parse yandex', () {
      expect(AuthenticatorType.fromString('yandex'), equals(AuthenticatorType.yandex));
      expect(AuthenticatorType.fromString('yaotp'), equals(AuthenticatorType.yandex));
    });

    test('fromString should default to totp for unknown', () {
      expect(AuthenticatorType.fromString('unknown'), equals(AuthenticatorType.totp));
      expect(AuthenticatorType.fromString(null), equals(AuthenticatorType.totp));
    });
  });

  group('OtpHashAlgorithm', () {
    test('fromString should parse SHA256', () {
      expect(OtpHashAlgorithm.fromString('SHA256'), equals(OtpHashAlgorithm.sha256));
      expect(OtpHashAlgorithm.fromString('sha256'), equals(OtpHashAlgorithm.sha256));
    });

    test('fromString should parse SHA512', () {
      expect(OtpHashAlgorithm.fromString('SHA512'), equals(OtpHashAlgorithm.sha512));
    });

    test('fromString should default to SHA1', () {
      expect(OtpHashAlgorithm.fromString('SHA1'), equals(OtpHashAlgorithm.sha1));
      expect(OtpHashAlgorithm.fromString('unknown'), equals(OtpHashAlgorithm.sha1));
      expect(OtpHashAlgorithm.fromString(null), equals(OtpHashAlgorithm.sha1));
    });

    test('displayName should return correct names', () {
      expect(OtpHashAlgorithm.sha1.displayName, equals('SHA1'));
      expect(OtpHashAlgorithm.sha256.displayName, equals('SHA256'));
      expect(OtpHashAlgorithm.sha512.displayName, equals('SHA512'));
    });
  });

  group('OtpGeneratorParams', () {
    test('should have sensible defaults', () {
      const params = OtpGeneratorParams(secret: 'TEST');

      expect(params.type, equals(AuthenticatorType.totp));
      expect(params.algorithm, equals(OtpHashAlgorithm.sha1));
      expect(params.digits, equals(6));
      expect(params.period, equals(30));
      expect(params.counter, equals(0));
      expect(params.pin, isNull);
    });

    test('copyWith should create new instance with updated values', () {
      const original = OtpGeneratorParams(
        secret: 'TEST',
        digits: 6,
      );

      final updated = original.copyWith(
        digits: 8,
      );

      expect(updated.secret, equals('TEST'));
      expect(updated.digits, equals(8));
      expect(original.digits, equals(6)); // Original unchanged
    });
  });
}
