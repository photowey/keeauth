import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:keeauth/core/crypto/otp_uri_parser.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/l10n/app_localizations.dart';

/// Bottom sheet for displaying QR code
class AuthenticatorQrSheet extends StatelessWidget {
  final String issuer;
  final String accountName;
  final String secret;
  final String type;
  final String algorithm;
  final int digits;
  final int period;
  final int counter;

  const AuthenticatorQrSheet({
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

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                issuer.isNotEmpty ? issuer : accountName,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 24),

            // QR Code
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: uri,
                  version: QrVersions.auto,
                  size: 280,
                  backgroundColor: Colors.white,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Help text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n?.scanHelpText ??
                    'Scan this QR code with another authenticator app to transfer this account.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: uri));
                      final l10n = AppLocalizations.of(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            l10n?.uriCopied ?? 'URI copied to clipboard',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Text(l10n?.copyUri ?? 'Copy URI'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n?.ok ?? 'OK'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
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

/// Show QR code bottom sheet
Future<void> showAuthenticatorQrSheet(
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
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => AuthenticatorQrSheet(
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
