import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/l10n/app_localizations.dart';

/// Dialog to display QR code for an authenticator
class AuthenticatorQrDialog extends StatelessWidget {
  final String issuer;
  final String accountName;
  final String secret;
  final String type;
  final String algorithm;
  final int digits;
  final int period;
  final int counter;

  const AuthenticatorQrDialog({
    super.key,
    required this.issuer,
    required this.accountName,
    required this.secret,
    this.type = 'totp',
    this.algorithm = 'SHA1',
    this.digits = 6,
    this.period = 30,
    this.counter = 0,
  });

  @override
  Widget build(BuildContext context) {
    final uri = OtpUriParser.generate(
      secret: secret,
      issuer: issuer,
      accountName: accountName,
      type: _parseType(type),
      algorithm: _parseAlgorithm(algorithm),
      digits: digits,
      period: period,
      counter: counter,
    );
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(issuer.isNotEmpty ? issuer : accountName),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (accountName.isNotEmpty && issuer.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                accountName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: uri,
              version: QrVersions.auto,
              size: 250,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.scanHelpText ?? 'Scan this QR code to transfer',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.close ?? 'Close'),
        ),
      ],
    );
  }

  AuthenticatorType _parseType(String type) {
    switch (type.toLowerCase()) {
      case 'hotp':
        return AuthenticatorType.hotp;
      case 'steam':
        return AuthenticatorType.steam;
      case 'motp':
        return AuthenticatorType.motp;
      case 'yandex':
        return AuthenticatorType.yandex;
      default:
        return AuthenticatorType.totp;
    }
  }

  OtpHashAlgorithm _parseAlgorithm(String algo) {
    switch (algo.toUpperCase()) {
      case 'SHA256':
        return OtpHashAlgorithm.sha256;
      case 'SHA512':
        return OtpHashAlgorithm.sha512;
      default:
        return OtpHashAlgorithm.sha1;
    }
  }
}

/// Show QR dialog helper
Future<void> showAuthenticatorQr(
  BuildContext context, {
  required String issuer,
  required String accountName,
  required String secret,
  String type = 'totp',
  String algorithm = 'SHA1',
  int digits = 6,
  int period = 30,
  int counter = 0,
}) {
  return showDialog(
    context: context,
    builder:
        (context) => AuthenticatorQrDialog(
          issuer: issuer,
          accountName: accountName,
          secret: secret,
          type: type,
          algorithm: algorithm,
          digits: digits,
          period: period,
          counter: counter,
        ),
  );
}
