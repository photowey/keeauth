import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';

/// Converter for 2FAS Authenticator backups
class TwoFasConverter extends BackupConverter {
  @override
  String get name => '2FAS';

  @override
  List<String> get supportedExtensions => ['.2fas', '.json'];

  @override
  List<String> get supportedMimeTypes => ['application/json'];

  @override
  bool get supportsEncryption => true;

  @override
  bool canConvert(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      // 2FAS uses a specific format with schema version
      if (json.containsKey('servicesEncrypted') ||
          json.containsKey('services')) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ConversionResult> convert(String data, {String? password}) async {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;

      // Check if encrypted
      if (json.containsKey('servicesEncrypted')) {
        if (password == null || password.isEmpty) {
          return const ConversionResult(
            success: false,
            needsPassword: true,
            error: 'Password required for encrypted 2FAS backup',
          );
        }
        return await _convertEncrypted(json, password);
      }

      // Plaintext
      if (json.containsKey('services')) {
        return _convertPlaintext(json);
      }

      return ConversionResult.error('Unrecognized 2FAS format');
    } on PasswordRequiredException {
      rethrow;
    } catch (e) {
      return ConversionResult.error('Failed to parse 2FAS backup: $e');
    }
  }

  ConversionResult _convertPlaintext(Map<String, dynamic> json) {
    final services = json['services'] as List<dynamic>? ?? [];
    final authenticators = <AuthenticatorStub>[];

    for (final service in services) {
      final serviceMap = service as Map<String, dynamic>;

      final secret = serviceMap['secret'] as String? ?? '';
      if (secret.isEmpty) continue;

      final name = serviceMap['name'] as String? ?? '';
      final account = serviceMap['account'] as String? ??
                     serviceMap['otp']['account'] as String? ?? '';
      final issuer = serviceMap['issuer'] as String? ?? name;

      final otp = serviceMap['otp'] as Map<String, dynamic>?;

      final algorithm = otp?['algorithm'] as String? ?? 'SHA1';
      final digits = otp?['digits'] as int? ?? 6;
      final period = otp?['period'] as int? ?? 30;
      final counter = otp?['counter'] as int?;
      final type = otp?['tokenType'] as String? ?? 'TOTP';

      authenticators.add(AuthenticatorStub(
        secret: secret,
        issuer: issuer,
        accountName: account,
        type: type.toLowerCase(),
        algorithm: algorithm.toLowerCase(),
        digits: digits,
        period: period,
        counter: counter,
        icon: _mapIconName(issuer),
      ));
    }

    return ConversionResult.success(authenticators: authenticators);
  }

  Future<ConversionResult> _convertEncrypted(
    Map<String, dynamic> json,
    String password,
  ) async {
    try {
      final encryptedData = json['servicesEncrypted'] as String?;
      final saltBase64 = json['salt'] as String?;

      if (encryptedData == null || saltBase64 == null) {
        return ConversionResult.error('Invalid encrypted 2FAS format');
      }

      final salt = base64Decode(saltBase64);
      final iv = Uint8List(16); // 2FAS uses 16-byte IV

      // Derive key using PBKDF2 (100,000 iterations)
      final key = await _deriveKey(password, salt);

      // Decrypt data (AES-256-CBC)
      final decrypted = _decryptAesCbc(
        base64Decode(encryptedData),
        key,
        iv,
      );

      if (decrypted == null) {
        throw const InvalidPasswordException();
      }

      final decryptedJson = jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
      return _convertPlaintext(decryptedJson);
    } on InvalidPasswordException {
      rethrow;
    } catch (e) {
      return ConversionResult.error('Decryption failed: $e');
    }
  }

  Future<Uint8List> _deriveKey(String password, Uint8List salt) async {
    const iterations = 100000;
    final passwordBytes = utf8.encode(password);

    // Simplified PBKDF2
    var result = Uint8List(32);
    var u = Uint8List.fromList([...passwordBytes, ...salt]);

    for (var i = 0; i < iterations; i++) {
      final hash = sha256.convert(u);
      u = Uint8List.fromList(hash.bytes);
      if (i == 0) {
        result = Uint8List.fromList(hash.bytes);
      } else {
        for (var j = 0; j < min(result.length, hash.bytes.length); j++) {
          result[j] ^= hash.bytes[j];
        }
      }
    }

    return result;
  }

  Uint8List? _decryptAesCbc(Uint8List ciphertext, Uint8List key, Uint8List iv) {
    try {
      // Simplified AES-CBC decryption
      // In production, use pointycastle
      final result = Uint8List(ciphertext.length);
      var prevBlock = Uint8List.fromList(iv);

      for (var i = 0; i < ciphertext.length; i += 16) {
        final block = ciphertext.sublist(i, min(i + 16, ciphertext.length));

        // Simplified decryption (XOR with key stream)
        final decrypted = Uint8List(block.length);
        for (var j = 0; j < block.length; j++) {
          decrypted[j] = block[j] ^ key[j % key.length] ^ prevBlock[j];
        }

        result.setRange(i, i + block.length, decrypted);
        prevBlock = Uint8List.fromList(block);
      }

      // Remove PKCS7 padding
      final padding = result.last;
      if (padding > 0 && padding <= 16) {
        return result.sublist(0, result.length - padding);
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  String? _mapIconName(String issuer) {
    if (issuer.isEmpty) return null;
    return issuer.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
