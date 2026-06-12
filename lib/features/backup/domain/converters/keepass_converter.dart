import 'dart:convert';
import 'package:xml/xml.dart';
import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';

/// Converter for KeePass XML exports
class KeePassConverter extends BackupConverter {
  @override
  String get name => 'KeePass';

  @override
  List<String> get supportedExtensions => ['.xml'];

  @override
  List<String> get supportedMimeTypes => ['application/xml', 'text/xml'];

  @override
  bool get supportsEncryption => false;

  @override
  bool canConvert(String data) {
    try {
      final document = XmlDocument.parse(data);
      // Check for KeePass XML structure
      final root = document.rootElement;
      return root.name.local == 'KeePassFile' ||
             (root.name.local == 'Database' &&
              root.findAllElements('Entry').isNotEmpty);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<ConversionResult> convert(String data, {String? password}) async {
    try {
      final document = XmlDocument.parse(data);
      final authenticators = <AuthenticatorStub>[];

      // Find all entries
      final entries = document.findAllElements('Entry');

      for (final entry in entries) {
        final stub = _parseEntry(entry);
        if (stub != null) {
          authenticators.add(stub);
        }
      }

      if (authenticators.isEmpty) {
        return ConversionResult.error('No TOTP entries found in KeePass file');
      }

      return ConversionResult.success(authenticators: authenticators);
    } catch (e) {
      return ConversionResult.error('Failed to parse KeePass file: $e');
    }
  }

  AuthenticatorStub? _parseEntry(XmlElement entry) {
    try {
      // Get all string fields
      final strings = entry.findAllElements('String');

      String? title;
      String? username;
      String? secret;
      String? otpSettings;

      for (final string in strings) {
        final key = string.getElement('Key')?.text;
        final value = string.getElement('Value')?.text;

        if (key == null || value == null) continue;

        switch (key.toLowerCase()) {
          case 'title':
            title = value;
            break;
          case 'username':
          case 'user name':
            username = value;
            break;
          case 'secret':
          case 'seed':
          case 'key':
            secret = value;
            break;
          case 'otp':
          case 'totp':
          case 'otp settings':
            otpSettings = value;
            break;
        }
      }

      // Try to extract from OTP settings if available
      if (otpSettings != null && otpSettings.isNotEmpty) {
        return _parseOtpSettings(otpSettings, title, username);
      }

      // If no OTP settings, check if there's a secret field
      if (secret != null && secret.isNotEmpty) {
        return AuthenticatorStub(
          secret: secret.replaceAll(' ', ''),
          issuer: title ?? '',
          accountName: username ?? '',
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  AuthenticatorStub? _parseOtpSettings(
    String settings,
    String? title,
    String? username,
  ) {
    try {
      // Parse otpauth:// URI if present
      if (settings.startsWith('otpauth://')) {
        final uri = Uri.parse(settings);
        final secret = uri.queryParameters['secret'];
        if (secret == null || secret.isEmpty) return null;

        return AuthenticatorStub(
          secret: secret,
          issuer: uri.queryParameters['issuer'] ?? title ?? '',
          accountName: username ?? '',
          type: uri.host == 'hotp' ? 'hotp' : 'totp',
          algorithm: uri.queryParameters['algorithm']?.toLowerCase() ?? 'sha1',
          digits: int.tryParse(uri.queryParameters['digits'] ?? '') ?? 6,
          period: int.tryParse(uri.queryParameters['period'] ?? '') ?? 30,
          counter: int.tryParse(uri.queryParameters['counter'] ?? '') ?? 0,
        );
      }

      // Try to parse as JSON
      if (settings.startsWith('{')) {
        final json = jsonDecode(settings) as Map<String, dynamic>;
        final secret = json['secret'] as String?;
        if (secret == null || secret.isEmpty) return null;

        return AuthenticatorStub(
          secret: secret,
          issuer: title ?? '',
          accountName: username ?? '',
          type: json['type'] as String? ?? 'totp',
          algorithm: (json['algo'] as String? ?? 'SHA1').toLowerCase(),
          digits: json['digits'] as int? ?? 6,
          period: json['period'] as int? ?? 30,
        );
      }

      // Try to parse as key=value pairs
      final pairs = <String, String>{};
      for (final line in settings.split('\n')) {
        final parts = line.split('=');
        if (parts.length == 2) {
          pairs[parts[0].trim().toLowerCase()] = parts[1].trim();
        }
      }

      final secret = pairs['secret'] ?? pairs['seed'] ?? pairs['key'];
      if (secret == null || secret.isEmpty) return null;

      return AuthenticatorStub(
        secret: secret,
        issuer: title ?? '',
        accountName: username ?? '',
        type: pairs['type'] ?? 'totp',
        algorithm: (pairs['algo'] ?? 'SHA1').toLowerCase(),
        digits: int.tryParse(pairs['digits'] ?? '') ?? 6,
        period: int.tryParse(pairs['period'] ?? '') ?? 30,
      );
    } catch (e) {
      return null;
    }
  }
}
