import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:keeauth/core/crypto/encryption_service.dart';

void main() {
  late EncryptionService service;

  setUp(() {
    service = EncryptionService();
  });

  group('EncryptionService', () {
    group('generateSalt', () {
      test('returns 16 bytes', () {
        final salt = service.generateSalt();
        expect(salt.length, 16);
      });

      test('produces different results on successive calls', () {
        final salt1 = service.generateSalt();
        final salt2 = service.generateSalt();
        expect(salt1, isNot(equals(salt2)));
      });
    });

    group('generateIv', () {
      test('returns 12 bytes', () {
        final iv = service.generateIv();
        expect(iv.length, 12);
      });
    });

    group('deriveKey', () {
      test('returns same key for same password and salt', () {
        final salt = service.generateSalt();
        const password = 'testPassword123';

        final key1 = service.deriveKey(password, salt);
        final key2 = service.deriveKey(password, salt);

        expect(key1, equals(key2));
      });

      test('returns different keys for different passwords', () {
        final salt = service.generateSalt();

        final key1 = service.deriveKey('password1', salt);
        final key2 = service.deriveKey('password2', salt);

        expect(key1, isNot(equals(key2)));
      });
    });

    group('encryptInIsolate', () {
      test('round-trip via isolate encrypt → sync decrypt', () async {
        const password = 'isolateTest123!';
        final salt = service.generateSalt();
        final plaintext = Uint8List.fromList(utf8.encode('Isolate round-trip data'));

        final encrypted = await EncryptionService.encryptInIsolate(
          plaintext: plaintext, password: password, salt: salt,
        );
        final key = service.deriveKey(password, salt);

        final decrypted = service.decryptWithKey(
          EncryptedData(ciphertext: encrypted.ciphertext, iv: encrypted.iv, salt: salt),
          key,
        );
        expect(decrypted, equals(plaintext));
      });
    });

    group('encrypt / decryptWithKey', () {
      test('round-trip: decrypt recovers original plaintext', () {
        final salt = service.generateSalt();
        const password = 'securePassword!';
        final key = service.deriveKey(password, salt);

        final plaintext = Uint8List.fromList(utf8.encode('Hello, 2FA World!'));
        final encryptResult = service.encrypt(plaintext, key);

        final encryptedData = EncryptedData(
          ciphertext: encryptResult.ciphertext,
          iv: encryptResult.iv,
          salt: salt,
        );
        final decrypted = service.decryptWithKey(encryptedData, key);

        expect(decrypted, equals(plaintext));
      });

      test('ciphertext length equals plaintext length + 16 (GCM tag)', () {
        final salt = service.generateSalt();
        final key = service.deriveKey('password', salt);

        final plaintext = Uint8List.fromList(utf8.encode('Some test data'));
        final encryptResult = service.encrypt(plaintext, key);

        expect(encryptResult.ciphertext.length, plaintext.length + 16);
      });

      test('decryptWithKey throws on wrong key', () {
        final salt = service.generateSalt();
        final correctKey = service.deriveKey('correctPassword', salt);
        final wrongKey = service.deriveKey('wrongPassword', salt);

        final plaintext = Uint8List.fromList(utf8.encode('secret data'));
        final encryptResult = service.encrypt(plaintext, correctKey);

        final encryptedData = EncryptedData(
          ciphertext: encryptResult.ciphertext,
          iv: encryptResult.iv,
          salt: salt,
        );

        expect(
          () => service.decryptWithKey(encryptedData, wrongKey),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}
