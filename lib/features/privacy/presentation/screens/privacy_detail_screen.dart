import 'package:flutter/material.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/privacy/domain/privacy_policy_content.dart';

/// Full privacy policy page — works offline.
///
/// Sensitive personal information and its purpose / method / scope are wrapped
/// in `**...**` in [PrivacyPolicyContent] and rendered here with bold text,
/// accent colour and a slightly larger font size, so that they are visibly
/// highlighted (compliance review requirement 5.2「未见明示」).
class PrivacyDetailScreen extends StatelessWidget {
  const PrivacyDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context);
    final doc = PrivacyPolicyContent.forLocale(
      locale.languageCode,
      locale.scriptCode,
    );

    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(height: 1.7);

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.privacyPolicyTitle ?? 'Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Text(
            doc.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            doc.lastUpdated,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          _RichParagraph(text: doc.intro, style: bodyStyle),
          for (final section in doc.sections) ...[
            const SizedBox(height: 20),
            Text(
              section.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            for (final paragraph in section.paragraphs)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RichParagraph(text: paragraph, style: bodyStyle),
              ),
          ],
        ],
      ),
    );
  }
}

/// Renders a paragraph, turning `**emphasised**` spans into bold, accent-coloured
/// text with a slightly larger font size.
class _RichParagraph extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _RichParagraph({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyMedium;

    return SelectableText.rich(
      TextSpan(children: _parseEmphasis(text, base, theme.colorScheme.primary)),
    );
  }

  List<InlineSpan> _parseEmphasis(
    String source,
    TextStyle? base,
    Color accent,
  ) {
    final spans = <InlineSpan>[];
    final pattern = RegExp(r'\*\*(.+?)\*\*');
    var cursor = 0;

    for (final match in pattern.allMatches(source)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(text: source.substring(cursor, match.start), style: base),
        );
      }
      final baseSize = base?.fontSize ?? 14;
      spans.add(
        TextSpan(
          text: match.group(1),
          style: base?.copyWith(
            fontWeight: FontWeight.bold,
            color: accent,
            fontSize: baseSize + 1,
          ),
        ),
      );
      cursor = match.end;
    }

    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor), style: base));
    }
    return spans;
  }
}
