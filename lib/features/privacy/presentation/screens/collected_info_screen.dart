import 'package:flutter/material.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/privacy/domain/collected_info_content.dart';
import 'package:keeauth/features/privacy/presentation/widgets/compliance_widgets.dart';

/// "Collected Personal Information" list.
///
/// Reachable from Settings → Privacy & Compliance. Each card documents one
/// information type and its purpose, method, scope, retention and deletion.
class CollectedInfoScreen extends StatelessWidget {
  const CollectedInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final items = CollectedInfoContent.forLocale(
      locale.languageCode,
      locale.scriptCode,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.collectedInfoList ?? 'Collected Personal Information',
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return ComplianceNoteCard(
              text:
                  l10n?.collectedInfoNote ??
                  'All information below is processed and stored only on your device.',
            );
          }
          return _InfoCard(item: items[index - 1]);
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final CollectedInfoItem item;

  const _InfoCard({required this.item});

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
              item.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            ComplianceField(
              label: l10n?.collectPurpose ?? 'Purpose',
              value: item.purpose,
            ),
            ComplianceField(
              label: l10n?.collectMethod ?? 'Collection method',
              value: item.method,
            ),
            ComplianceField(
              label: l10n?.usageScope ?? 'Usage scope',
              value: item.scope,
            ),
            ComplianceField(
              label: l10n?.retentionPeriod ?? 'Retention',
              value: item.retention,
            ),
            ComplianceField(
              label: l10n?.deletionMethod ?? 'Deletion',
              value: item.deletion,
            ),
          ],
        ),
      ),
    );
  }
}
