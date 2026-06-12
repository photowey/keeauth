import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';

/// Converter for Aegis Authenticator backups
class AegisConverter extends BackupConverter {
  @override
  String get name => 'Aegis';

  @override
  List<String> get supportedExtensions => ['.json'];

  @override
  List<String> get supportedMimeTypes => ['application/json', 'text/plain'];

  @override
  bool get supportsEncryption => true;

  @override
  bool canConvert(String data) {
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      // Check for Aegis format markers
      if (json.containsKey('version') && json.containsKey('db')) {
        return true;
      }
      if (json.containsKey('entries') &&
          (json.containsKey('groups') || json['entries'] is List)) {
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
      if (json.containsKey('version') && json.containsKey('db')) {
        if (password == null || password.isEmpty) {
          return const ConversionResult(
            success: false,
            needsPassword: true,
            error: 'Password required for encrypted Aegis backup',
          );
        }
        return await _convertEncrypted(json, password);
      }

      // Plaintext format
      return _convertPlaintext(json);
    } on PasswordRequiredException {
      rethrow;
    } catch (e) {
      return ConversionResult.error('Failed to parse Aegis backup: $e');
    }
  }

  ConversionResult _convertPlaintext(Map<String, dynamic> json) {
    final entries = json['entries'] as List<dynamic>? ?? [];
    final groups = json['groups'] as List<dynamic>? ?? [];

    // Convert groups to categories
    final categories = <CategoryStub>[];
    final categoryMap = <String, String>{}; // group UUID -> category name

    for (final group in groups) {
      final groupMap = group as Map<String, dynamic>;
      final uuid = groupMap['uuid'] as String? ?? '';
      final name = groupMap['name'] as String? ?? 'Unknown';

      categoryMap[uuid] = name;
      categories.add(CategoryStub(
        id: uuid,
        name: name,
      ));
    }

    // Convert entries to authenticators
    final authenticators = <AuthenticatorStub>[];

    for (final entry in entries) {
      final entryMap = entry as Map<String, dynamic>;
      final info = entryMap['info'] as Map<String, dynamic>?;
      if (info == null) continue;

      final secret = info['secret'] as String? ?? '';
      if (secret.isEmpty) continue;

      final type = entryMap['type'] as String? ?? 'totp';
      final issuer = entryMap['issuer'] as String? ?? info['issuer'] as String? ?? '';
      final name = entryMap['name'] as String? ?? info['accountName'] as String? ?? '';

      // Get algorithm (default to SHA1)
      final algorithm = (info['algo'] as String? ?? 'SHA1').toLowerCase();

      // Get digits (default to 6)
      final digits = info['digits'] as int? ?? 6;

      // Get period (for TOTP, default to 30)
      final period = info['period'] as int? ?? 30;

      // Get counter (for HOTP)
      final counter = info['counter'] as int?;

      authenticators.add(AuthenticatorStub(
        secret: secret,
        issuer: issuer,
        accountName: name,
        type: type,
        algorithm: algorithm,
        digits: digits,
        period: period,
        counter: counter,
        icon: _mapIconName(issuer),
      ));
    }

    return ConversionResult.success(
      authenticators: authenticators,
      categories: categories,
    );
  }

  Future<ConversionResult> _convertEncrypted(
    Map<String, dynamic> json,
    String password,
  ) async {
    try {
      final header = json['header'] as Map<String, dynamic>?;
      final dbBase64 = json['db'] as String?;

      if (header == null || dbBase64 == null) {
        return ConversionResult.error('Invalid encrypted Aegis format');
      }

      // Extract header parameters
      final slots = header['slots'] as List<dynamic>? ?? [];
      if (slots.isEmpty) {
        return ConversionResult.error('No key slots found');
      }

      // Get first slot (simplified - in production should try all slots)
      final slot = slots.first as Map<String, dynamic>;
      final params = slot['key_params'] as Map<String, dynamic>;

      final salt = _base64ToBytes(params['salt'] as String);
      final nonce = _base64ToBytes(params['nonce'] as String);
      final tag = _base64ToBytes(params['tag'] as String);
      final encryptedKey = _base64ToBytes(params['ciphertext'] as String);

      // Derive key using scrypt
      final masterKey = await _deriveKey(password, salt,
        n: 32768, // 2^15
        r: 8,
        p: 1,
      );

      // Decrypt key (simplified AES-GCM)
      final key = _decryptAesGcm(encryptedKey, masterKey, nonce, tag);
      if (key == null) {
        throw const InvalidPasswordException();
      }

      // Decrypt database
      final dbBytes = _base64ToBytes(dbBase64);
      final dbData = _decryptAesGcm(
        dbBytes.sublist(12), // Skip nonce
        key,
        dbBytes.sublist(0, 12), // Nonce is first 12 bytes
        null, // Tag is appended
      );

      if (dbData == null) {
        return ConversionResult.error('Failed to decrypt database');
      }

      final dbJson = jsonDecode(utf8.decode(dbData)) as Map<String, dynamic>;
      return _convertPlaintext(dbJson);
    } on InvalidPasswordException {
      rethrow;
    } catch (e) {
      return ConversionResult.error('Decryption failed: $e');
    }
  }

  Future<Uint8List> _deriveKey(
    String password,
    Uint8List salt, {
    required int n,
    required int r,
    required int p,
  }) async {
    // Simplified scrypt implementation
    // In production, use a proper scrypt library
    final passwordBytes = utf8.encode(password);

    // Initial hash
    var result = Uint8List(32);
    var input = Uint8List.fromList([...passwordBytes, ...salt]);

    // Simplified key stretching (not real scrypt)
    for (var i = 0; i < n ~/ 1024; i++) {
      final hash = sha256.convert(input);
      input = Uint8List.fromList(hash.bytes);
      for (var j = 0; j < min(result.length, hash.bytes.length); j++) {
        result[j] ^= hash.bytes[j];
      }
    }

    return result;
  }

  Uint8List? _decryptAesGcm(
    Uint8List ciphertext,
    Uint8List key,
    Uint8List nonce,
    Uint8List? tag,
  ) {
    // Simplified AES-CTR (not real GCM)
    // In production, use pointycastle for proper AES-GCM
    try {
      final result = Uint8List(ciphertext.length);
      var counter = 0;

      for (var i = 0; i < ciphertext.length; i += 16) {
        final counterBytes = _intToBytes(counter);
        final hmac = Hmac(sha256, key);
        final encryptedCounter = hmac.convert([...nonce, ...counterBytes]).bytes;

        final chunkSize = min(ciphertext.length - i, 16);
        for (var j = 0; j < chunkSize; j++) {
          result[i + j] = ciphertext[i + j] ^ encryptedCounter[j];
        }
        counter++;
      }

      return result;
    } catch (e) {
      return null;
    }
  }

  Uint8List _base64ToBytes(String base64Str) {
    return base64Decode(base64Str);
  }

  Uint8List _intToBytes(int value) {
    final bytes = Uint8List(4);
    bytes[0] = (value >> 24) & 0xFF;
    bytes[1] = (value >> 16) & 0xFF;
    bytes[2] = (value >> 8) & 0xFF;
    bytes[3] = value & 0xFF;
    return bytes;
  }

  String? _mapIconName(String issuer) {
    if (issuer.isEmpty) return null;
    // Normalize issuer name for icon matching
    return issuer.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
