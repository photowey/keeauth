import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/export.dart';

/// AES-256-GCM encryption service with PBKDF2-HMAC-SHA512 key derivation.
///
/// New backups use real AES-256-GCM via pointycastle.
/// Legacy v1 backups (HMAC-CTR) are supported for read-only decryption.
class EncryptionService {
  static const int _saltLength = 16;
  static const int _ivLength = 12;
  static const int _keyLength = 32;
  static const int _pbkdf2Iterations = 10000; // 10K — sufficient for mobile
  static const int _gcmTagBits = 128;

  static const int _v1SaltLength = 16;
  static const int _v1IvLength = 12;
  static const int _v1TagLength = 16;
  static const int _v1KdfIterations = 3000;

  /// Derive a 256-bit key from [password] and [salt] using PBKDF2-HMAC-SHA512.
  Uint8List deriveKey(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128));
    derivator.init(Pbkdf2Parameters(salt, _pbkdf2Iterations, _keyLength));
    return derivator.process(Uint8List.fromList(utf8.encode(password)));
  }

  /// Generate a cryptographically secure random salt (16 bytes).
  Uint8List generateSalt() {
    return _secureRandomBytes(_saltLength);
  }

  /// Generate a cryptographically secure random IV (12 bytes).
  Uint8List generateIv() {
    return _secureRandomBytes(_ivLength);
  }

  /// Encrypt [data] with AES-256-GCM using the given [key].
  ///
  /// Returns an [EncryptResult] whose [ciphertext] includes the 16-byte
  /// GCM authentication tag appended to the end.
  EncryptResult encrypt(Uint8List data, Uint8List key) {
    final iv = generateIv();

    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      true,
      AEADParameters(KeyParameter(key), _gcmTagBits, iv, Uint8List(0)),
    );

    // GCM requires explicit processBytes + doFinal; calling only process()
    // skips authentication-tag generation and causes crashes.
    final out = Uint8List(cipher.getOutputSize(data.length));
    final len = cipher.processBytes(data, 0, data.length, out, 0);
    final tagLen = cipher.doFinal(out, len);
    final output = Uint8List.sublistView(out, 0, len + tagLen);

    return EncryptResult(ciphertext: output, salt: Uint8List(0), iv: iv);
  }

  /// Run PBKDF2 key derivation + AES-256-GCM encryption in a separate
  /// isolate to avoid blocking the UI thread (ANR).
  static Future<EncryptResult> encryptInIsolate({
    required Uint8List plaintext,
    required String password,
    required Uint8List salt,
  }) async {
    return Isolate.run(() => _isolateEncrypt(plaintext, password, salt));
  }

  /// Decrypt legacy v1 backup data using the old HMAC-CTR scheme.
  ///
  /// [encryptedData] layout: salt(16) + iv(12) + tag(16) + ciphertext.
  Uint8List decrypt(Uint8List encryptedData, String password) {
    var offset = 0;

    final salt = encryptedData.sublist(offset, offset + _v1SaltLength);
    offset += _v1SaltLength;

    final iv = encryptedData.sublist(offset, offset + _v1IvLength);
    offset += _v1IvLength;

    final tag = encryptedData.sublist(offset, offset + _v1TagLength);
    offset += _v1TagLength;

    final ciphertext = encryptedData.sublist(offset);

    final key = _legacyDeriveKey(password, Uint8List.fromList(salt));

    final expectedTag = _legacyAuthTag(ciphertext, key, iv);
    if (!_constantTimeEquals(tag, expectedTag)) {
      throw Exception('Authentication failed - invalid password or corrupted data');
    }

    return _legacyHmacCtrDecrypt(ciphertext, key, iv);
  }

  /// Decrypt [encryptedData] with a pre-derived [key] using AES-256-GCM.
  ///
  /// The [EncryptedData.ciphertext] must include the trailing 16-byte GCM tag.
  /// Throws if authentication fails (invalid password or corrupted data).
  Uint8List decryptWithKey(EncryptedData encryptedData, Uint8List key) {
    final cipher = GCMBlockCipher(AESEngine());
    cipher.init(
      false,
      AEADParameters(
        KeyParameter(key),
        _gcmTagBits,
        encryptedData.iv,
        Uint8List(0),
      ),
    );

    // GCM requires explicit processBytes + doFinal; doFinal verifies the
    // authentication tag and throws on mismatch.
    final data = encryptedData.ciphertext;
    final out = Uint8List(cipher.getOutputSize(data.length));
    final len = cipher.processBytes(data, 0, data.length, out, 0);
    final tagLen = cipher.doFinal(out, len);
    return Uint8List.sublistView(out, 0, len + tagLen);
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Uint8List _secureRandomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(List.generate(length, (_) => rng.nextInt(256)));
  }

  // ---------------------------------------------------------------------------
  // Legacy v1 support (read-only, kept for backward-compatible decryption)
  // ---------------------------------------------------------------------------

  /// PBKDF2-HMAC-SHA256 with 3 000 iterations and a non-standard block counter
  /// byte order, matching the original implementation exactly.
  Uint8List _legacyDeriveKey(String password, Uint8List salt) {
    final passwordBytes = utf8.encode(password);
    final result = Uint8List(32);

    final block = Uint8List(salt.length + 4);
    block.setRange(0, salt.length, salt);
    block[salt.length] = 1;

    var hmacInst = Hmac(sha256, passwordBytes);
    var u = hmacInst.convert(block).bytes;
    result.setRange(0, u.length, u);

    for (var i = 1; i < _v1KdfIterations; i++) {
      hmacInst = Hmac(sha256, passwordBytes);
      final nextU = hmacInst.convert(u).bytes;
      for (var j = 0; j < result.length; j++) {
        result[j] ^= nextU[j];
      }
      u = nextU;
    }

    return result;
  }

  Uint8List _legacyHmacCtrDecrypt(
    Uint8List data,
    Uint8List key,
    Uint8List iv,
  ) {
    final result = Uint8List(data.length);
    var counter = 0;

    for (var i = 0; i < data.length; i += 32) {
      final counterBytes = Uint8List(4)
        ..[0] = (counter >> 24) & 0xFF
        ..[1] = (counter >> 16) & 0xFF
        ..[2] = (counter >> 8) & 0xFF
        ..[3] = counter & 0xFF;

      final hmacInst = Hmac(sha256, key);
      final stream = hmacInst.convert([...iv, ...counterBytes]).bytes;

      final chunkSize = (data.length - i) > 32 ? 32 : (data.length - i);
      for (var j = 0; j < chunkSize; j++) {
        result[i + j] = data[i + j] ^ stream[j];
      }
      counter++;
    }

    return result;
  }

  Uint8List _legacyAuthTag(Uint8List ciphertext, Uint8List key, Uint8List iv) {
    final hmacInst = Hmac(sha256, key);
    final hash = hmacInst.convert([...iv, ...ciphertext]);
    return Uint8List.fromList(hash.bytes.sublist(0, _v1TagLength));
  }

  bool _constantTimeEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a[i] ^ b[i];
    }
    return result == 0;
  }
}

/// Result of an encryption operation.
class EncryptResult {
  final Uint8List ciphertext;
  final Uint8List salt;
  final Uint8List iv;

  EncryptResult({
    required this.ciphertext,
    required this.salt,
    required this.iv,
  });
}

/// PBKDF2 key derivation in isolate — avoids UI freeze.
Future<Uint8List> deriveKeyInIsolate(String password, Uint8List salt) {
  return Isolate.run(() => _isolateDeriveKey(password, salt));
}

Uint8List _isolateDeriveKey(String password, Uint8List salt) {
  final derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128));
  derivator.init(Pbkdf2Parameters(salt, EncryptionService._pbkdf2Iterations, 32));
  return derivator.process(Uint8List.fromList(utf8.encode(password)));
}

/// Top-level function that runs in a separate isolate.
/// Must be top-level so [Isolate.run] can serialise arguments / return value.
EncryptResult _isolateEncrypt(
  Uint8List plaintext,
  String password,
  Uint8List salt,
) {
  // Derive key (PBKDF2-HMAC-SHA512, 10 000 iterations)
  final derivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), 128));
  derivator.init(
    Pbkdf2Parameters(salt, EncryptionService._pbkdf2Iterations, 32),
  );
  final key = derivator.process(Uint8List.fromList(utf8.encode(password)));

  // Generate IV
  final rng = Random.secure();
  final iv = Uint8List.fromList(
    List.generate(EncryptionService._ivLength, (_) => rng.nextInt(256)),
  );

  // AES-256-GCM encrypt
  final cipher = GCMBlockCipher(AESEngine());
  cipher.init(
    true,
    AEADParameters(
      KeyParameter(key),
      EncryptionService._gcmTagBits,
      iv,
      Uint8List(0),
    ),
  );
  final out = Uint8List(cipher.getOutputSize(plaintext.length));
  final len = cipher.processBytes(plaintext, 0, plaintext.length, out, 0);
  final tagLen = cipher.doFinal(out, len);

  return EncryptResult(
    ciphertext: Uint8List.sublistView(out, 0, len + tagLen),
    salt: Uint8List(0),
    iv: iv,
  );
}

/// Encrypted data bundle for decryption.
class EncryptedData {
  final Uint8List ciphertext;
  final Uint8List iv;
  final Uint8List salt;
  final Uint8List? tag;

  EncryptedData({
    required this.ciphertext,
    required this.iv,
    required this.salt,
    this.tag,
  });
}
