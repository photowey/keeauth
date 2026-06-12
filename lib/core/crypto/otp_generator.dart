import 'dart:convert';
import 'dart:typed_data';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart' as crypto;

/// Hash algorithm type
enum OtpHashAlgorithm {
  sha1,
  sha256,
  sha512;

  String get displayName {
    switch (this) {
      case OtpHashAlgorithm.sha1:
        return 'SHA1';
      case OtpHashAlgorithm.sha256:
        return 'SHA256';
      case OtpHashAlgorithm.sha512:
        return 'SHA512';
    }
  }

  static OtpHashAlgorithm fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'SHA256':
        return OtpHashAlgorithm.sha256;
      case 'SHA512':
        return OtpHashAlgorithm.sha512;
      default:
        return OtpHashAlgorithm.sha1;
    }
  }

  crypto.Hash get hashAlgorithm {
    switch (this) {
      case OtpHashAlgorithm.sha1:
        return crypto.sha1;
      case OtpHashAlgorithm.sha256:
        return crypto.sha256;
      case OtpHashAlgorithm.sha512:
        return crypto.sha512;
    }
  }
}

/// Authenticator type enumeration
enum AuthenticatorType {
  totp,
  hotp,
  steam,
  motp,
  yandex;

  static AuthenticatorType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'hotp':
        return AuthenticatorType.hotp;
      case 'steam':
        return AuthenticatorType.steam;
      case 'motp':
        return AuthenticatorType.motp;
      case 'yaotp':
      case 'yandex':
        return AuthenticatorType.yandex;
      default:
        return AuthenticatorType.totp;
    }
  }
}

/// OTP generator parameters
class OtpGeneratorParams {
  final String secret;
  final AuthenticatorType type;
  final OtpHashAlgorithm algorithm;
  final int digits;
  final int period;
  final int counter; // For HOTP
  final String? pin; // For mOTP/Yandex

  const OtpGeneratorParams({
    required this.secret,
    this.type = AuthenticatorType.totp,
    this.algorithm = OtpHashAlgorithm.sha1,
    this.digits = 6,
    this.period = 30,
    this.counter = 0,
    this.pin,
  });

  OtpGeneratorParams copyWith({
    String? secret,
    AuthenticatorType? type,
    OtpHashAlgorithm? algorithm,
    int? digits,
    int? period,
    int? counter,
    String? pin,
  }) {
    return OtpGeneratorParams(
      secret: secret ?? this.secret,
      type: type ?? this.type,
      algorithm: algorithm ?? this.algorithm,
      digits: digits ?? this.digits,
      period: period ?? this.period,
      counter: counter ?? this.counter,
      pin: pin ?? this.pin,
    );
  }
}

/// Main OTP generator class
class OtpGenerator {
  /// Generate TOTP code
  String generateTotp(OtpGeneratorParams params) {
    final counter = _getTimeCounter(params.period);
    return _generateHOTP(params.copyWith(counter: counter));
  }

  /// Generate HOTP code
  String generateHotp(OtpGeneratorParams params) {
    return _generateHOTP(params);
  }

  /// Generate Steam OTP (5 alphanumeric characters)
  String generateSteamOtp(OtpGeneratorParams params) {
    final counter = _getTimeCounter(params.period);
    final paddedCounter = _padCounter(counter);
    final secretBytes = _getSecretBytes(params.secret);

    final hmac = crypto.Hmac(crypto.sha1, secretBytes);
    final signature = Uint8List.fromList(hmac.convert(paddedCounter).bytes);

    final offset = signature[signature.length - 1] & 0x0F;
    var code = _bytesToUint32(signature, offset);

    const steamAlphabet = '23456789BCDFGHJKMNPQRTVWXY';
    final result = StringBuffer();

    for (var i = 0; i < 5; i++) {
      result.write(steamAlphabet[code % steamAlphabet.length]);
      code = code ~/ steamAlphabet.length;
    }

    return result.toString();
  }

  /// Generate mOTP code
  String generateMotp(OtpGeneratorParams params) {
    final epoch = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final counter = epoch ~/ 10;
    final pin = params.pin ?? '0000';
    final input = '$counter${params.secret}$pin';
    final hash = crypto.md5.convert(utf8.encode(input));
    return hash.toString().substring(0, 6);
  }

  /// Generate Yandex OTP (8 characters, custom alphabet)
  String generateYandexOtp(OtpGeneratorParams params) {
    final counter = _getTimeCounter(params.period);
    final paddedCounter = _padCounter(counter);
    final secretBytes = _getSecretBytes(params.secret);
    final pin = params.pin ?? '';

    final pinBytes = utf8.encode(pin);
    final keyInput = Uint8List(pinBytes.length + secretBytes.length);
    keyInput.setRange(0, pinBytes.length, pinBytes);
    keyInput.setRange(pinBytes.length, keyInput.length, secretBytes);
    final hmacKey = crypto.sha256.convert(keyInput).bytes;

    final hmac = crypto.Hmac(crypto.sha256, hmacKey);
    final signature = Uint8List.fromList(hmac.convert(paddedCounter).bytes);

    final offset = signature[signature.length - 1] & 0x0F;
    var code = _bytesToUint32(signature, offset);

    const alphabet = 'abcdefghijklmnopqrstuvwxyz234567';
    final result = StringBuffer();
    for (var i = 0; i < 8; i++) {
      result.write(alphabet[code % alphabet.length]);
      code = code ~/ alphabet.length;
    }
    return result.toString();
  }

  /// Generate code based on type
  String generate(OtpGeneratorParams params) {
    switch (params.type) {
      case AuthenticatorType.totp:
        return generateTotp(params);
      case AuthenticatorType.hotp:
        return generateHotp(params);
      case AuthenticatorType.steam:
        return generateSteamOtp(params);
      case AuthenticatorType.motp:
        return generateMotp(params);
      case AuthenticatorType.yandex:
        return generateYandexOtp(params);
    }
  }

  /// Get remaining seconds until next code
  int getRemainingSeconds(int period) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return period - (now % period);
  }

  int _getTimeCounter(int period) {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return now ~/ period;
  }

  Uint8List _padCounter(int counter) {
    final bytes = Uint8List(8);
    for (var i = 7; i >= 0; i--) {
      bytes[i] = counter & 0xFF;
      counter >>= 8;
    }
    return bytes;
  }

  Uint8List _getSecretBytes(String secret) {
    // Clean and decode secret
    final cleanSecret = secret.replaceAll(RegExp(r'\s'), '').toUpperCase();
    return base32.decode(cleanSecret);
  }

  int _bytesToUint32(Uint8List bytes, int offset) {
    return ((bytes[offset] & 0x7F) << 24) |
        ((bytes[offset + 1] & 0xFF) << 16) |
        ((bytes[offset + 2] & 0xFF) << 8) |
        (bytes[offset + 3] & 0xFF);
  }

  String _generateHOTP(OtpGeneratorParams params) {
    final paddedCounter = _padCounter(params.counter);
    final secretBytes = _getSecretBytes(params.secret);

    final hmac = crypto.Hmac(params.algorithm.hashAlgorithm, secretBytes);
    final signature = Uint8List.fromList(hmac.convert(paddedCounter).bytes);

    final offset = signature[signature.length - 1] & 0x0F;
    final code = _bytesToUint32(signature, offset);

    return (code % _pow10(params.digits)).toString().padLeft(params.digits, '0');
  }

  int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }
}
