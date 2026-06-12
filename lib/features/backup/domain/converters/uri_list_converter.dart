import 'backup_converter.dart';
import 'package:keeauth/features/backup/domain/import_models.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';

/// Converter for plain URI list format
class UriListConverter extends BackupConverter {
  @override
  String get name => 'URI List';

  @override
  List<String> get supportedExtensions => ['.txt', '.uri'];

  @override
  List<String> get supportedMimeTypes => ['text/plain'];

  @override
  bool get supportsEncryption => false;

  @override
  bool canConvert(String data) {
    final lines = data.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isNotEmpty && trimmed.startsWith('otpauth://')) {
        return true;
      }
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
        if (!trimmed.startsWith('otpauth://')) continue;

        final result = OtpUriParser.parse(trimmed);
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

      if (authenticators.isEmpty) {
        return ConversionResult.error('No valid otpauth URIs found');
      }

      return ConversionResult.success(authenticators: authenticators);
    } catch (e) {
      return ConversionResult.error('Failed to parse URI list: $e');
    }
  }
}
