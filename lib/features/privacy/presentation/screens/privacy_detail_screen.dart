import 'package:flutter/material.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/privacy/domain/privacy_policy_content.dart';

/// Full privacy policy page — works offline.
class PrivacyDetailScreen extends StatelessWidget {
  const PrivacyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final content = PrivacyPolicyContent.forLocale(
      locale.languageCode,
      locale.scriptCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.privacyPolicyTitle ?? 'Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(content, style: theme.textTheme.bodyMedium?.copyWith(height: 1.8)),
      ),
    );
  }
}
