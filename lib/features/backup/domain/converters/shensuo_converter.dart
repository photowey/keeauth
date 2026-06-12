import 'dart:convert';

import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';

/// Converter for ShenSuo (神锁) backup format.
///
/// ShenSuo exports a JSON array of vault entries. Each entry contains a
/// "fields" array; we look for the field with `type == "OneTimePassword"`
/// whose `value` holds a standard `otpauth://` URI.
class ShenSuoConverter extends BackupConverter {
  @override
  String get name => 'ShenSuo (神锁)';

  @override
  List<String> get supportedExtensions => ['.json'];

  @override
  List<String> get supportedMimeTypes => ['application/json', 'text/plain'];

  @override
  bool get supportsEncryption => false;

  @override
  bool canConvert(String data) {
    try {
      final list = jsonDecode(data);
      if (list is! List || list.isEmpty) return false;
      // Look for the OneTimePassword field pattern
      for (final entry in list) {
        if (entry is! Map) continue;
        final fields = entry['fields'];
        if (fields is! List) continue;
        for (final field in fields) {
          if (field is Map && field['type'] == 'OneTimePassword') {
            final value = field['value'] as String?;
            if (value != null && value.startsWith('otpauth://')) {
              return true;
            }
          }
        }
      }
    } catch (_) {}
    return false;
  }

  @override
  Future<ConversionResult> convert(String data, {String? password}) async {
    try {
      final list = jsonDecode(data);
      if (list is! List) {
        return ConversionResult.error('Expected JSON array');
      }

      final authenticators = <AuthenticatorStub>[];
      for (final entry in list) {
        if (entry is! Map) continue;
        final fields = entry['fields'];
        if (fields is! List) continue;

        for (final field in fields) {
          if (field is! Map || field['type'] != 'OneTimePassword') continue;

          final value = field['value'] as String?;
          if (value == null || value.isEmpty) continue;
          if (!value.startsWith('otpauth://')) continue;

          final result = OtpUriParser.parse(value);
          if (result.success && result.params != null) {
            final params = result.params!;
            authenticators.add(AuthenticatorStub(
              secret: params.secret,
              issuer: result.issuer ?? '',
              accountName: result.accountName ?? '',
              type: params.type.name,
              algorithm: params.algorithm.name,
              digits: params.digits,
              period: params.period,
              counter: params.counter,
            ));
          }
        }
      }

      if (authenticators.isEmpty) {
        return ConversionResult.error('No valid otpauth URIs found');
      }
      return ConversionResult.success(authenticators: authenticators);
    } catch (e) {
      return ConversionResult.error('Failed to parse ShenSuo export: $e');
    }
  }
}
