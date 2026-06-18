import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:keeauth/l10n/app_localizations.dart';

/// Full-screen privacy consent dialog shown on first launch.
/// User must agree before using the app.
class PrivacyConsentScreen extends StatelessWidget {
  final VoidCallback onAccepted;

  const PrivacyConsentScreen({super.key, required this.onAccepted});

  static const _baseUrl = 'https://github.com/photowey/keeauth/blob/main';

  static String _privacyUrl(Locale locale) {
    if (locale.languageCode == 'zh') {
      return locale.scriptCode == 'Hant'
          ? '$_baseUrl/PRIVACY.zh-Hant.md'
          : '$_baseUrl/PRIVACY.zh-CN.md';
    }
    return '$_baseUrl/PRIVACY.md';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Icon(Icons.shield_outlined, size: 64, color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                l10n?.privacyPolicyTitle ?? 'Privacy Policy',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n?.privacyPolicyContent ??
                      'KeeAuth values your privacy.\n\n'
                          '• All data is stored exclusively on your device\n'
                          '• No personal information is collected or transmitted\n'
                          '• No advertising or analytics SDKs\n'
                          '• Camera is used only for QR code scanning',
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final uri = Uri.parse(_privacyUrl(locale));
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l10n?.privacyPolicyViewFull ?? 'View Full Privacy Policy'),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onAccepted,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n?.privacyPolicyAgree ?? 'Agree and Continue',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => SystemNavigator.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n?.privacyPolicyDisagree ?? 'Disagree',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
