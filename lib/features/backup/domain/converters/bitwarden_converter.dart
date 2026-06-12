import 'dart:convert';

import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';

/// Converter for Bitwarden exports
class BitwardenConverter extends BackupConverter {
  @override
  String get name => 'Bitwarden';

  @override
  List<String> get supportedExtensions => ['.json', '.csv'];

  @override
  List<String> get supportedMimeTypes => ['application/json', 'text/csv'];

  @override
  bool get supportsEncryption => false;

  @override
  bool canConvert(String data) {
    try {
      final json = jsonDecode(data);

      // Check for Bitwarden format markers
      if (json is Map<String, dynamic>) {
        // Bitwarden encrypted export
        if (json.containsKey('encrypted') && json.containsKey('data')) {
          return true;
        }
        // Bitwarden items array
        if (json.containsKey('items') && json['items'] is List) {
          return true;
        }
      }

      // Check for CSV format
      if (data.contains('name,username,password,totp') ||
          data.contains('folder,favorite,type,name')) {
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
      // Try JSON first
      if (data.trim().startsWith('{')) {
        final json = jsonDecode(data) as Map<String, dynamic>;
        return _convertJson(json);
      }

      // Try CSV
      if (data.contains(',')) {
        return _convertCsv(data);
      }

      return ConversionResult.error('Unrecognized Bitwarden format');
    } catch (e) {
      return ConversionResult.error('Failed to parse Bitwarden backup: $e');
    }
  }

  ConversionResult _convertJson(Map<String, dynamic> json) {
    final items = json['items'] as List<dynamic>? ?? [];
    final authenticators = <AuthenticatorStub>[];

    for (final item in items) {
      final itemMap = item as Map<String, dynamic>;

      // Check if item has TOTP
      final login = itemMap['login'] as Map<String, dynamic>?;
      if (login == null) continue;

      final totp = login['totp'] as String?;
      if (totp == null || totp.isEmpty) continue;

      // Parse TOTP URI or secret
      AuthenticatorStub? stub;
      if (totp.startsWith('otpauth://')) {
        stub = _parseOtpAuthUri(totp);
      } else {
        // Raw secret
        stub = AuthenticatorStub(
          secret: totp.replaceAll(' ', ''),
          issuer: itemMap['name'] as String? ?? '',
          accountName: login['username'] as String? ?? '',
        );
      }

      if (stub != null) {
        authenticators.add(stub);
      }
    }

    return ConversionResult.success(authenticators: authenticators);
  }

  ConversionResult _convertCsv(String data) {
    final authenticators = <AuthenticatorStub>[];
    final lines = data.split('\n');

    if (lines.isEmpty) {
      return ConversionResult.error('Empty CSV file');
    }

    // Parse header
    final header = lines.first.split(',');
    final totpIndex = header.indexOf('totp');
    final nameIndex = header.indexOf('name');
    final usernameIndex = header.indexOf('username');

    if (totpIndex == -1) {
      return ConversionResult.error('CSV missing totp column');
    }

    // Parse rows
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCsvLine(line);
      if (values.length <= totpIndex) continue;

      final totp = values[totpIndex].trim();
      if (totp.isEmpty) continue;

      final name =
          nameIndex >= 0 && nameIndex < values.length ? values[nameIndex] : '';
      final username =
          usernameIndex >= 0 && usernameIndex < values.length
              ? values[usernameIndex]
              : '';

      AuthenticatorStub? stub;
      if (totp.startsWith('otpauth://')) {
        stub = _parseOtpAuthUri(totp);
      } else {
        stub = AuthenticatorStub(
          secret: totp.replaceAll(' ', ''),
          issuer: name,
          accountName: username,
        );
      }

      if (stub != null) {
        authenticators.add(stub);
      }
    }

    return ConversionResult.success(authenticators: authenticators);
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
