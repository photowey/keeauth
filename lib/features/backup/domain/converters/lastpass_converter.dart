import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';

/// Converter for LastPass CSV exports
class LastPassConverter extends BackupConverter {
  @override
  String get name => 'LastPass';

  @override
  List<String> get supportedExtensions => ['.csv'];

  @override
  List<String> get supportedMimeTypes => ['text/csv'];

  @override
  bool get supportsEncryption => false;

  @override
  bool canConvert(String data) {
    // Check for LastPass CSV headers
    final firstLine = data.split('\n').first.toLowerCase();
    return firstLine.contains('url') &&
        firstLine.contains('username') &&
        firstLine.contains('password');
  }

  @override
  Future<ConversionResult> convert(String data, {String? password}) async {
    try {
      final authenticators = <AuthenticatorStub>[];
      final lines = data.split('\n');

      if (lines.isEmpty) {
        return ConversionResult.error('Empty CSV file');
      }

      // Parse header
      final headers = _parseCsvLine(lines.first);
      final urlIndex = headers.indexWhere((h) => h.toLowerCase() == 'url');
      final usernameIndex = headers.indexWhere(
        (h) => h.toLowerCase() == 'username',
      );
      final nameIndex = headers.indexWhere((h) => h.toLowerCase() == 'name');
      final extraIndex = headers.indexWhere((h) => h.toLowerCase() == 'extra');

      if (urlIndex == -1) {
        return ConversionResult.error('CSV missing URL column');
      }

      // Parse rows
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;

        final values = _parseCsvLine(line);
        if (values.length <= urlIndex) continue;

        final url = values[urlIndex].trim();

        // Check if this is a TOTP entry
        // LastPass stores TOTP in various formats
        AuthenticatorStub? stub;

        // Try to parse otpauth URL
        if (url.startsWith('otpauth://')) {
          stub = _parseOtpauthUrl(url);
        }
        // Check extra field for TOTP secret
        else if (extraIndex != -1 && extraIndex < values.length) {
          final extra = values[extraIndex];
          if (extra.isNotEmpty) {
            stub = _parseExtraField(
              extra,
              nameIndex >= 0 && nameIndex < values.length
                  ? values[nameIndex]
                  : '',
            );
          }
        }

        // If still no TOTP, check if URL contains otpauth
        if (stub == null && url.contains('otpauth://')) {
          final otpauthMatch = RegExp(r'otpauth://[^\s,]+').firstMatch(url);
          if (otpauthMatch != null) {
            stub = _parseOtpauthUrl(otpauthMatch.group(0)!);
          }
        }

        if (stub != null) {
          // Enhance with username if available
          if (usernameIndex >= 0 && usernameIndex < values.length) {
            final username = values[usernameIndex];
            if (username.isNotEmpty && stub.accountName.isEmpty) {
              stub = AuthenticatorStub(
                secret: stub.secret,
                issuer: stub.issuer,
                accountName: username,
                type: stub.type,
                algorithm: stub.algorithm,
                digits: stub.digits,
                period: stub.period,
                counter: stub.counter,
              );
            }
          }
          authenticators.add(stub);
        }
      }

      if (authenticators.isEmpty) {
        return ConversionResult.error(
          'No TOTP entries found in LastPass export',
        );
      }

      return ConversionResult.success(authenticators: authenticators);
    } catch (e) {
      return ConversionResult.error('Failed to parse LastPass file: $e');
    }
  }

  AuthenticatorStub? _parseOtpauthUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final secret = uri.queryParameters['secret'];
      if (secret == null || secret.isEmpty) return null;

      // Parse label (issuer:account)
      final label = uri.path.substring(1); // Remove leading /
      final labelParts = label.split(':');
      final issuer = labelParts.length > 1 ? labelParts[0] : '';
      final account = labelParts.length > 1 ? labelParts[1] : label;

      return AuthenticatorStub(
        secret: secret,
        issuer: uri.queryParameters['issuer'] ?? issuer,
        accountName: account,
        type: uri.host == 'hotp' ? 'hotp' : 'totp',
        algorithm: uri.queryParameters['algorithm']?.toLowerCase() ?? 'sha1',
        digits: int.tryParse(uri.queryParameters['digits'] ?? '') ?? 6,
        period: int.tryParse(uri.queryParameters['period'] ?? '') ?? 30,
        counter: int.tryParse(uri.queryParameters['counter'] ?? '') ?? 0,
      );
    } catch (e) {
      return null;
    }
  }

  AuthenticatorStub? _parseExtraField(String extra, String fallbackName) {
    try {
      // LastPass sometimes stores TOTP secret in the extra field
      // Format can be:
      // - Plain secret: ABCDEF123456
      // - Secret: ABCDEF123456
      // - otpauth://... URI

      // Try to find otpauth URI
      if (extra.contains('otpauth://')) {
        final match = RegExp(r'otpauth://[^\s]+').firstMatch(extra);
        if (match != null) {
          return _parseOtpauthUrl(match.group(0)!);
        }
      }

      // Try to find secret in various formats
      final patterns = [
        RegExp(r'[Ss]ecret[:\s]+([A-Z2-7\s]+)'),
        RegExp(r'[Kk]ey[:\s]+([A-Z2-7\s]+)'),
        RegExp(r'[Ss]eed[:\s]+([A-Z2-7\s]+)'),
        RegExp(r'TOTP[:\s]+([A-Z2-7\s]+)'),
      ];

      for (final pattern in patterns) {
        final match = pattern.firstMatch(extra);
        if (match != null) {
          final secret = match.group(1)?.replaceAll(' ', '');
          if (secret != null && secret.isNotEmpty) {
            return AuthenticatorStub(
              secret: secret,
              issuer: fallbackName,
              accountName: '',
            );
          }
        }
      }

      // If extra looks like a base32 secret itself (16+ chars, only base32 chars)
      final cleanExtra = extra.replaceAll(' ', '');
      if (cleanExtra.length >= 16 &&
          RegExp(r'^[A-Z2-7]+$').hasMatch(cleanExtra.toUpperCase())) {
        return AuthenticatorStub(
          secret: cleanExtra.toUpperCase(),
          issuer: fallbackName,
          accountName: '',
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }

    result.add(current.toString());
    return result;
  }
}
