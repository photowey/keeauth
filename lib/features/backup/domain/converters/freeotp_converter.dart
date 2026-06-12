import 'dart:convert';
import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';

/// Converter for FreeOTP/FreeOTP+ backups
class FreeOtpConverter extends BackupConverter {
  @override
  String get name => 'FreeOTP+';

  @override
  List<String> get supportedExtensions => ['.json'];

  @override
  List<String> get supportedMimeTypes => ['application/json'];

  @override
  bool get supportsEncryption => false;

  @override
  bool canConvert(String data) {
    try {
      final json = jsonDecode(data);
      if (json is List) {
        // FreeOTP+ exports an array of tokens
        if (json.isNotEmpty && json.first is Map<String, dynamic>) {
          final first = json.first as Map<String, dynamic>;
          return first.containsKey('secret') || first.containsKey('algo');
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ConversionResult> convert(String data, {String? password}) async {
    try {
      final json = jsonDecode(data) as List<dynamic>;
      final authenticators = <AuthenticatorStub>[];

      for (final item in json) {
        final itemMap = item as Map<String, dynamic>;

        // Extract secret
        final secretBytes = _parseSecret(itemMap['secret']);
        if (secretBytes == null || secretBytes.isEmpty) {
          continue;
        }

        final secret = base32Encode(secretBytes);

        // Extract other fields
        final issuer = itemMap['issuer'] as String? ?? '';
        final account = itemMap['label'] as String? ??
                       itemMap['account'] as String? ?? '';
        final algorithm = itemMap['algo'] as String? ?? 'SHA1';
        final digits = itemMap['digits'] as int? ?? 6;
        final period = itemMap['period'] as int? ?? 30;
        final counter = itemMap['counter'] as int?;

        // Determine type
        final type = itemMap['type'] as String? ?? 'TOTP';

        authenticators.add(AuthenticatorStub(
          secret: secret,
          issuer: issuer,
          accountName: account,
          type: type.toLowerCase(),
          algorithm: algorithm.toLowerCase(),
          digits: digits,
          period: period,
          counter: counter,
        ));
      }

      return ConversionResult.success(authenticators: authenticators);
    } catch (e) {
      return ConversionResult.error('Failed to parse FreeOTP+ backup: $e');
    }
  }

  List<int>? _parseSecret(dynamic secret) {
    if (secret == null) return null;

    if (secret is List) {
      return secret.cast<int>();
    }

    if (secret is String) {
      // Try base64
      try {
        return base64Decode(secret);
      } catch (e) {
        // Try hex
        if (secret.length % 2 == 0) {
          try {
            final result = <int>[];
            for (var i = 0; i < secret.length; i += 2) {
              result.add(int.parse(secret.substring(i, i + 2), radix: 16));
            }
            return result;
          } catch (e) {
            // Fall through
          }
        }
      }
    }

    return null;
  }

  String base32Encode(List<int> data) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final result = StringBuffer();

    var bits = 0;
    var value = 0;

    for (final byte in data) {
      value = (value << 8) | byte;
      bits += 8;

      while (bits >= 5) {
        result.write(alphabet[(value >> (bits - 5)) & 31]);
        bits -= 5;
      }
    }

    if (bits > 0) {
      result.write(alphabet[(value << (5 - bits)) & 31]);
    }

    return result.toString();
  }
}
