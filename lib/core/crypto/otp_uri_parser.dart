import 'otp_generator.dart';

/// Result of parsing an OTP URI
class OtpUriParseResult {
  final bool success;
  final String? error;
  final OtpGeneratorParams? params;
  final String? issuer;
  final String? accountName;

  const OtpUriParseResult({
    required this.success,
    this.error,
    this.params,
    this.issuer,
    this.accountName,
  });

  factory OtpUriParseResult.success({
    required OtpGeneratorParams params,
    String? issuer,
    String? accountName,
  }) {
    return OtpUriParseResult(
      success: true,
      params: params,
      issuer: issuer,
      accountName: accountName,
    );
  }

  factory OtpUriParseResult.failure(String error) {
    return OtpUriParseResult(
      success: false,
      error: error,
    );
  }
}

/// Parser for otpauth:// URIs
class OtpUriParser {
  /// Parse an otpauth:// URI
  static OtpUriParseResult parse(String uri) {
    try {
      if (!uri.startsWith('otpauth://')) {
        return OtpUriParseResult.failure('Invalid URI scheme');
      }

      final parsed = Uri.parse(uri);
      if (parsed.host.isEmpty) {
        return OtpUriParseResult.failure('Missing OTP type');
      }

      final type = _parseType(parsed.host);
      final path = parsed.path;
      String? issuer;
      String? accountName;

      // Parse path (can be /issuer:account or just /account)
      if (path.isNotEmpty) {
        final pathContent = Uri.decodeComponent(path.substring(1));
        if (pathContent.contains(':')) {
          final parts = pathContent.split(':');
          issuer = parts[0];
          accountName = parts.sublist(1).join(':');
        } else {
          accountName = pathContent;
        }
      }

      // Parse query parameters
      final params = parsed.queryParameters;
      final secret = params['secret'];
      if (secret == null || secret.isEmpty) {
        return OtpUriParseResult.failure('Missing secret parameter');
      }

      // Get issuer from query params if not in path
      issuer ??= params['issuer'];

      // Parse algorithm
      final algorithm = OtpHashAlgorithm.fromString(params['algorithm']);

      // Parse digits
      final digits = int.tryParse(params['digits'] ?? '6') ?? 6;

      // Parse period (for TOTP)
      final period = int.tryParse(params['period'] ?? '30') ?? 30;

      // Parse counter (for HOTP)
      final counter = int.tryParse(params['counter'] ?? '0') ?? 0;

      // Parse PIN (for mOTP/Yandex)
      final pin = params['pin'];

      // Validate digits (Steam uses 5, standard is 6–10)
      final minDigits = type == AuthenticatorType.steam ? 5 : 6;
      if (digits < minDigits || digits > 10) {
        return OtpUriParseResult.failure('Digits must be between $minDigits and 10');
      }

      final generatorParams = OtpGeneratorParams(
        secret: secret,
        type: type,
        algorithm: algorithm,
        digits: digits,
        period: period,
        counter: counter,
        pin: pin,
      );

      return OtpUriParseResult.success(
        params: generatorParams,
        issuer: issuer,
        accountName: accountName,
      );
    } catch (e) {
      return OtpUriParseResult.failure('Parse error: $e');
    }
  }

  /// Generate otpauth:// URI from parameters
  static String generate({
    required String secret,
    required AuthenticatorType type,
    String? issuer,
    String? accountName,
    OtpHashAlgorithm algorithm = OtpHashAlgorithm.sha1,
    int digits = 6,
    int period = 30,
    int counter = 0,
    String? pin,
  }) {
    final buffer = StringBuffer();
    buffer.write('otpauth://');
    buffer.write(_typeToString(type));
    buffer.write('/');

    if (issuer != null && issuer.isNotEmpty) {
      buffer.write(Uri.encodeComponent('$issuer:'));
    }
    if (accountName != null && accountName.isNotEmpty) {
      buffer.write(Uri.encodeComponent(accountName));
    }

    buffer.write('?secret=${secret.replaceAll(' ', '')}');

    if (issuer != null && issuer.isNotEmpty) {
      buffer.write('&issuer=${Uri.encodeComponent(issuer)}');
    }

    if (algorithm != OtpHashAlgorithm.sha1) {
      buffer.write('&algorithm=${algorithm.name.toUpperCase()}');
    }

    if (digits != 6) {
      buffer.write('&digits=$digits');
    }

    if (type == AuthenticatorType.totp && period != 30) {
      buffer.write('&period=$period');
    }

    if (type == AuthenticatorType.hotp) {
      buffer.write('&counter=$counter');
    }

    if (pin != null && pin.isNotEmpty) {
      buffer.write('&pin=$pin');
    }

    return buffer.toString();
  }

  static AuthenticatorType _parseType(String host) {
    switch (host.toLowerCase()) {
      case 'hotp':
        return AuthenticatorType.hotp;
      case 'steam':
        return AuthenticatorType.steam;
      case 'motp':
        return AuthenticatorType.motp;
      case 'yaotp':
        return AuthenticatorType.yandex;
      default:
        return AuthenticatorType.totp;
    }
  }

  static String _typeToString(AuthenticatorType type) {
    switch (type) {
      case AuthenticatorType.totp:
        return 'totp';
      case AuthenticatorType.hotp:
        return 'hotp';
      case AuthenticatorType.steam:
        return 'steam';
      case AuthenticatorType.motp:
        return 'motp';
      case AuthenticatorType.yandex:
        return 'yaotp';
    }
  }
}
