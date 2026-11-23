import 'package:flutter/material.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/privacy/domain/sdk_list_content.dart';
import 'package:keeauth/features/privacy/presentation/widgets/compliance_widgets.dart';

/// "Third-Party SDK List".
///
/// Reachable from Settings → Privacy & Compliance. Follows the components
/// actually shipped in the release APK; none of them perform advertising,
/// analytics, or tracking.
class SdkListScreen extends StatelessWidget {
  const SdkListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final items = SdkListContent.forLocale(
      locale.languageCode,
      locale.scriptCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.sdkSharedList ?? 'Third-Party SDK List'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ComplianceNoteCard(
              text:
                  l10n?.sdkListNote ??
                  'All SDKs below run only on your device and contain no advertising, analytics, or tracking functionality.',
            );
          }
          return _SdkCard(item: items[index - 1]);
        },
      ),
    );
  }
}

class _SdkCard extends StatelessWidget {
  final SdkInfoItem item;

  const _SdkCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ComplianceField(
              label: l10n?.sdkProvider ?? 'Provider',
              value: item.provider,
            ),
            ComplianceField(
              label: l10n?.sdkPurpose ?? 'Purpose',
              value: item.purpose,
            ),
            ComplianceField(
              label: l10n?.sdkInfoCollected ?? 'Personal information involved',
              value: item.infoCollected,
            ),
            ComplianceField(
              label: l10n?.sdkSharing ?? 'Sharing',
              value: item.sharing,
            ),
            if (item.privacyUrl.isNotEmpty)
              ComplianceField(
                label: l10n?.sdkPrivacyPolicy ?? 'Privacy policy',
                value: item.privacyUrl,
              ),
          ],
        ),
      ),
    );
  }
}
