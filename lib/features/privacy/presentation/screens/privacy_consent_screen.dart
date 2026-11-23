import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/privacy/presentation/screens/privacy_detail_screen.dart';

/// Full-screen privacy consent dialog shown on first launch.
/// User must agree before using the app.
class PrivacyConsentScreen extends StatelessWidget {
  final VoidCallback onAccepted;

  const PrivacyConsentScreen({super.key, required this.onAccepted});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Icon(Icons.shield_outlined, size: 56, color: colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                l10n?.privacyPolicyTitle ?? 'Privacy Policy',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          l10n?.privacyPolicyContent ??
                              'KeeAuth values your privacy.\n\n'
                                  '• All data is stored exclusively on your device\n'
                                  '• No personal information is collected or transmitted\n'
                                  '• No advertising or analytics SDKs\n'
                                  '• Camera is used only for QR code scanning',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const _SensitiveInfoCard(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyDetailScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.article_outlined, size: 18),
                label: Text(
                  l10n?.privacyPolicyViewFull ?? 'View Full Privacy Policy',
                ),
              ),
              const SizedBox(height: 8),
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

/// Highlights sensitive personal information and its purpose / method / scope
/// on the first-launch consent screen.
class _SensitiveInfoCard extends StatelessWidget {
  const _SensitiveInfoCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.sensitiveInfoTitle ?? 'Sensitive Information',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SensitiveItem(
            label: l10n?.sensitiveCameraLabel ?? 'Camera',
            description:
                l10n?.sensitiveCameraDescription ??
                'Used only to scan QR codes when adding authenticators.',
          ),
          _SensitiveItem(
            label:
                l10n?.sensitiveBiometricLabel ??
                'Biometric data (fingerprint / face)',
            description:
                l10n?.sensitiveBiometricDescription ??
                'Used only to unlock the app.',
          ),
          _SensitiveItem(
            label: l10n?.sensitiveSecretLabel ?? '2FA secrets',
            description:
                l10n?.sensitiveSecretDescription ??
                'Used only to generate verification codes.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SensitiveItem extends StatelessWidget {
  final String label;
  final String description;
  final bool isLast;

  const _SensitiveItem({
    required this.label,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
