import 'dart:convert';
import 'dart:typed_data';

import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';

/// Converter for Google Authenticator migration
class GoogleAuthConverter extends BackupConverter {
  @override
  String get name => 'Google Authenticator';

  @override
  List<String> get supportedExtensions => ['.txt', '.uri'];

  @override
  List<String> get supportedMimeTypes => ['text/plain'];

  @override
  bool get supportsEncryption => false;

  @override
  bool canConvert(String data) {
    // Check for otpauth-migration format
    if (data.contains('otpauth-migration://')) {
      return true;
    }
    // Check for plain otpauth URIs
    if (data.contains('otpauth://')) {
      return true;
    }
    return false;
  }

  @override
  Future<ConversionResult> convert(String data, {String? password}) async {
    try {
      final authenticators = <AuthenticatorStub>[];
      final lines = data.split('\n');

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        // Handle migration format
        if (trimmed.startsWith('otpauth-migration://')) {
          final stubs = await _parseMigrationUri(trimmed);
          authenticators.addAll(stubs);
        }
        // Handle standard otpauth format
        else if (trimmed.startsWith('otpauth://')) {
          final stub = _parseOtpAuthUri(trimmed);
          if (stub != null) {
            authenticators.add(stub);
          }
        }
      }

      if (authenticators.isEmpty) {
        return ConversionResult.error('No valid authenticators found');
      }

      return ConversionResult.success(authenticators: authenticators);
    } catch (e) {
      return ConversionResult.error('Failed to parse Google Auth backup: $e');
    }
  }

  Future<List<AuthenticatorStub>> _parseMigrationUri(String uri) async {
    final stubs = <AuthenticatorStub>[];

    try {
      // Extract data parameter from migration URI
      final uriObj = Uri.parse(uri);
      final data = uriObj.queryParameters['data'];

      if (data == null || data.isEmpty) {
        return stubs;
      }

      // Decode base64
      final decoded = base64Decode(data);

      // Parse protobuf-like structure (simplified)
      // Google Auth uses a custom protobuf format
      // This is a simplified parser for common cases
      stubs.addAll(_parseMigrationData(decoded));
    } catch (e) {
      // Ignore parsing errors for individual URIs
    }

    return stubs;
  }

  List<AuthenticatorStub> _parseMigrationData(Uint8List data) {
    final stubs = <AuthenticatorStub>[];

    try {
      // Simplified protobuf parser for Google Auth migration
      // The actual format is more complex, this handles basic cases

      var offset = 0;
      while (offset < data.length) {
        // Look for otp_parameters messages (field 1)
        if (offset + 1 < data.length && data[offset] == 0x0A) {
          // Field 1, wire type 2 (length-delimited)

          final length = data[offset + 1];
          offset += 2;

          if (offset + length <= data.length) {
            final paramData = data.sublist(offset, offset + length);
            final stub = _parseOtpParameters(paramData);
            if (stub != null) {
              stubs.add(stub);
            }
            offset += length;
          } else {
            break;
          }
        } else {
          offset++;
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }

    return stubs;
  }

  AuthenticatorStub? _parseOtpParameters(Uint8List data) {
    try {
      String? secret;
      String? issuer;
      String? accountName;
      var type = 'totp';
      var algorithm = 'sha1';
      var digits = 6;
      var counter = 0;

      var offset = 0;
      while (offset < data.length) {
        if (offset >= data.length) break;

        final tag = data[offset];
        final fieldNum = tag >> 3;
        final wireType = tag & 0x07;
        offset++;

        if (wireType == 2) {
          // Length-delimited
          if (offset >= data.length) break;
          final length = data[offset];
          offset++;

          if (offset + length > data.length) break;
          final len = length;
          final value = data.sublist(offset, offset + len);
          offset += len;

          switch (fieldNum) {
            case 1: // secret
              secret = base32Encode(value);
              break;
            case 2: // account name
              accountName = utf8.decode(value);
              break;
            case 3: // issuer
              issuer = utf8.decode(value);
              break;
          }
        } else if (wireType == 0) {
          // Varint
          var value = 0;
          var shift = 0;
          while (offset < data.length) {
            final byte = data[offset];
            offset++;
            value |= (byte & 0x7F) << shift;
            if ((byte & 0x80) == 0) break;
            shift += 7;
          }

          switch (fieldNum) {
            case 4: // algorithm
              algorithm = _mapAlgorithm(value);
              break;
            case 5: // digits
              digits = value == 1 ? 8 : 6;
              break;
            case 6: // type
              type = value == 1 ? 'hotp' : 'totp';
              break;
            case 7: // counter (for HOTP)
              counter = value;
              break;
          }
        }
      }

      if (secret == null || secret.isEmpty) {
        return null;
      }

      return AuthenticatorStub(
        secret: secret,
        issuer: issuer ?? '',
        accountName: accountName ?? '',
        type: type,
        algorithm: algorithm,
        digits: digits,
        counter: counter,
      );
    } catch (e) {
      return null;
    }
  }

  String _mapAlgorithm(int value) {
    switch (value) {
      case 1:
        return 'sha256';
      case 2:
        return 'sha512';
      case 0:
      default:
        return 'sha1';
    }
  }

  String base32Encode(Uint8List data) {
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

  AuthenticatorStub? _parseOtpAuthUri(String uri) {
    final result = OtpUriParser.parse(uri);
    if (!result.success || result.params == null) {
      return null;
    }

    final params = result.params!;
    return AuthenticatorStub(
      secret: params.secret,
      issuer: result.issuer ?? '',
      accountName: result.accountName ?? '',
      type: params.type.name,
      algorithm: params.algorithm.name,
      digits: params.digits,
      period: params.period,
      counter: params.counter,
    );
  }
}
