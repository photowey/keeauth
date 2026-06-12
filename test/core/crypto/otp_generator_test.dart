import 'package:flutter_test/flutter_test.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';

void main() {
  late OtpGenerator generator;

  setUp(() {
    generator = OtpGenerator();
  });

  group('OtpGenerator', () {
    group('HOTP', () {
      // RFC 4226 test vectors
      // Secret: "12345678901234567890" (ASCII)
      // Base32: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ"
      const base32Secret = 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ';

      final rfc4226Expected = <int, String>{
        0: '755224',
        1: '287082',
        2: '359152',
        3: '969429',
        4: '338314',
        5: '254676',
        6: '287922',
        7: '162583',
        8: '399871',
        9: '520489',
      };

      for (final entry in rfc4226Expected.entries) {
        test('RFC 4226 vector: counter=${entry.key} -> ${entry.value}', () {
          final params = OtpGeneratorParams(
            secret: base32Secret,
            type: AuthenticatorType.hotp,
            algorithm: OtpHashAlgorithm.sha1,
            digits: 6,
            counter: entry.key,
          );
          final code = generator.generateHotp(params);
          expect(code, entry.value);
        });
      }

      test('generates correct length code', () {
        final params = OtpGeneratorParams(
          secret: base32Secret,
          type: AuthenticatorType.hotp,
          algorithm: OtpHashAlgorithm.sha1,
          digits: 6,
          counter: 0,
        );
        final code = generator.generateHotp(params);
        expect(code.length, 6);
        expect(int.tryParse(code), isNotNull);
      });
    });

    group('TOTP', () {
      test('generates code with correct length and numeric digits', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.totp,
          algorithm: OtpHashAlgorithm.sha1,
          digits: 6,
          period: 30,
        );
        final code = generator.generateTotp(params);
        expect(code.length, 6);
        expect(int.tryParse(code), isNotNull);
      });

      test('same params produce same code within the same time step', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.totp,
          algorithm: OtpHashAlgorithm.sha1,
          digits: 6,
          period: 30,
        );
        final code1 = generator.generateTotp(params);
        final code2 = generator.generateTotp(params);
        expect(code1, code2);
      });
    });

    group('Steam OTP', () {
      test('generates 5-character code from correct alphabet', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.steam,
          digits: 5,
          period: 30,
        );
        final code = generator.generateSteamOtp(params);
        expect(code.length, 5);
        const alphabet = '23456789BCDFGHJKMNPQRTVWXY';
        for (final char in code.split('')) {
          expect(alphabet.contains(char), isTrue,
              reason: 'Invalid char: $char');
        }
      });

      test('alphabet has 26 characters and does not contain L', () {
        const alphabet = '23456789BCDFGHJKMNPQRTVWXY';
        expect(alphabet.contains('L'), isFalse);
        expect(alphabet.length, 26);
      });
    });

    group('mOTP', () {
      test('generates 6-character hex code', () {
        final params = OtpGeneratorParams(
          secret: 'abcdef1234',
          type: AuthenticatorType.motp,
          pin: '1234',
          period: 10,
        );
        final code = generator.generateMotp(params);
        expect(code.length, 6);
        expect(RegExp(r'^[0-9a-f]{6}$').hasMatch(code), isTrue);
      });

      test('different pins produce different codes', () {
        final params1 = OtpGeneratorParams(
          secret: 'abcdef1234',
          type: AuthenticatorType.motp,
          pin: '1234',
          period: 10,
        );
        final params2 = OtpGeneratorParams(
          secret: 'abcdef1234',
          type: AuthenticatorType.motp,
          pin: '5678',
          period: 10,
        );
        final code1 = generator.generateMotp(params1);
        final code2 = generator.generateMotp(params2);
        expect(code1, isNot(equals(code2)));
      });
    });

    group('Yandex OTP', () {
      test('generates 8-character code from custom alphabet', () {
        final params = OtpGeneratorParams(
          secret: 'JBSWY3DPEHPK3PXP',
          type: AuthenticatorType.yandex,
          pin: 'mypin',
          digits: 8,
          period: 30,
        );
        final code = generator.generateYandexOtp(params);
        expect(code.length, 8);
        const alphabet = 'abcdefghijklmnopqrstuvwxyz234567';
        for (final char in code.split('')) {
          expect(alphabet.contains(char), isTrue,
              reason: 'Invalid char: $char');
        }
      });
    });

    group('generate (dispatcher)', () {
      test('dispatches to generateHotp for HOTP type', () {
        final params = OtpGeneratorParams(
          secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
          type: AuthenticatorType.hotp,
          algorithm: OtpHashAlgorithm.sha1,
          digits: 6,
          counter: 0,
        );
        final fromGenerate = generator.generate(params);
        final fromHotp = generator.generateHotp(params);
        expect(fromGenerate, fromHotp);
      });
    });
  });
}
