import 'package:flutter/material.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/core/enums/view_mode.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'authenticator_icon.dart';
import 'authenticator_menu_sheet.dart';
import 'category_assignment_dialog.dart';
import 'search_app_bar.dart';
import 'totp_code_display.dart';

/// Widget for displaying a single authenticator in the list
class AuthenticatorListItem extends StatelessWidget {
  final Authenticator authenticator;
  final String code;
  final int remainingSeconds;
  final int period;
  final bool tapToRevealEnabled;
  final String searchQuery;
  final ViewMode viewMode;
  final int codeGroupSize;
  final VoidCallback? onTap;         // reveal toggle
  final VoidCallback? onLongPress;
  final VoidCallback onDoubleTap;     // copy code
  final GlobalKey<TotpCodeDisplayState>? codeKey;
  final VoidCallback? onShowDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onShowQr;
  final VoidCallback? onChangeIcon;
  final VoidCallback? onRefresh;
  /// Category names to show as small tags (resolved from categoryIds).
  final List<String> categoryNames;
  /// Optional ARGB colors for each category (same order as [categoryNames]).
  final List<int> categoryColorInts;

  const AuthenticatorListItem({
    super.key,
    required this.authenticator,
    required this.code,
    required this.remainingSeconds,
    required this.period,
    this.tapToRevealEnabled = false,
    this.searchQuery = '',
    this.viewMode = ViewMode.standard,
    this.codeGroupSize = 3,
    this.onTap,
    required this.onDoubleTap,
    this.codeKey,
    this.onLongPress,
    this.onShowDetails,
    this.onEdit,
    this.onDelete,
    this.onShowQr,
    this.onChangeIcon,
    this.onRefresh,
    this.categoryNames = const [],
    this.categoryColorInts = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (viewMode == ViewMode.tile) {
      return _buildTileLayout(context);
    }
    return _buildListLayout(context);
  }

  Widget _buildTileLayout(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onLongPress: onLongPress ?? () => _showMenu(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: AuthenticatorIcon(
                  issuer: authenticator.issuer,
                  customIconPath: authenticator.icon,
                  size: 28,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                authenticator.issuer.isNotEmpty
                    ? authenticator.issuer
                    : authenticator.accountName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              if (categoryNames.isNotEmpty) ...[
                const SizedBox(height: 4),
                _buildCategoryPills(context, theme, compact: true, center: true),
              ],
              const SizedBox(height: 4),
              TotpCodeDisplay(
                key: codeKey,
                code: code,
                remainingSeconds: remainingSeconds,
                period: period,
                tapToRevealEnabled: tapToRevealEnabled,
                textStyle: theme.textTheme.titleMedium,
                codeGroupSize: codeGroupSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListLayout(BuildContext context) {
    final theme = Theme.of(context);

    final isCompact = viewMode == ViewMode.compact;
    final iconSize = isCompact ? 24.0 : 32.0;
    final iconMarginStart = isCompact ? 16.0 : 20.0;
    final codeMarginStart = isCompact ? 52.0 : 76.0;
    final topPadding = isCompact ? 8.0 : 16.0;
    final codeStyle =
        isCompact
            ? theme.textTheme.titleLarge
            : theme.textTheme.displaySmall;

    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 12,
        vertical: isCompact ? 4 : 6,
      ),
      elevation: 0,
      child: InkWell(
        onDoubleTap: onDoubleTap,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(iconMarginStart, topPadding, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: iconSize,
                    height: iconSize,
                    child: AuthenticatorIcon(
                      issuer: authenticator.issuer,
                      customIconPath: authenticator.icon,
                      size: iconSize,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HighlightedText(
                          text:
                              authenticator.issuer.isNotEmpty
                                  ? authenticator.issuer
                                  : authenticator.accountName,
                          highlight: searchQuery,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            fontSize: isCompact ? 14 : 16,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (authenticator.issuer.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          HighlightedText(
                            text: authenticator.accountName,
                            highlight: searchQuery,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: isCompact ? 11 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (categoryNames.isNotEmpty) _buildCategoryPills(context, theme, compact: isCompact),
                      ],
                    ),
                  ),
                  _buildMoreButton(context),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                codeMarginStart,
                2,
                16,
                isCompact ? 8 : 8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TotpCodeDisplay(
                      key: codeKey,
                      code: code,
                      remainingSeconds: remainingSeconds,
                      period: period,
                      tapToRevealEnabled: tapToRevealEnabled,
                      textStyle: codeStyle,
                      codeGroupSize: codeGroupSize,
                    ),
                  ),
                  if (authenticator.type == AuthenticatorType.hotp &&
                      onRefresh != null)
                    IconButton(
                      icon: Icon(
                        Icons.refresh,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      onPressed: onRefresh,
                      tooltip: 'Advance counter',
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints(minWidth: 36, minHeight: 36),
                    ),
                ],
              ),
            ),
            if (!isCompact && authenticator.type != AuthenticatorType.hotp)
              _buildProgressIndicator(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryPills(BuildContext context, ThemeData theme, {bool compact = false, bool center = false}) {
    final small = compact;
    final padding = small ? 4.0 : 6.0;
    final fontSize = small ? 10.0 : 11.0;
    final child = Wrap(
      spacing: 4,
      runSpacing: 2,
      alignment: center ? WrapAlignment.center : WrapAlignment.start,
      children: List.generate(categoryNames.length, (i) {
        final name = categoryNames[i];
        final colorInt = i < categoryColorInts.length ? categoryColorInts[i] : null;
        final bgColor = colorInt != null
            ? Color(colorInt).withValues(alpha: 0.28)
            : theme.colorScheme.secondaryContainer.withValues(alpha: 0.7);
        final fgColor = colorInt != null
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSecondaryContainer;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (colorInt != null ? Color(colorInt) : theme.colorScheme.outline).withValues(alpha: 0.4),
              width: 0.5,
            ),
          ),
          child: Text(
            name,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: fontSize,
              color: fgColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }),
    );
    return Padding(
      padding: EdgeInsets.only(top: small ? 2 : 4),
      child: child,
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onPressed: () => _showMenu(context),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
    );
  }

  void _showMenu(BuildContext context) {
    showAuthenticatorMenu(
      context,
      authenticator: authenticator,
      onShowDetails: onShowDetails,
      onEditDetails: onEdit,
      onChangeIcon: onChangeIcon,
      onAssignCategories: () =>
          showCategoryAssignmentDialog(context, authenticator: authenticator),
      onShowQrCode: onShowQr,
      onDelete: onDelete,
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    final progress = remainingSeconds / period;
    final progressColor = _countdownColor(progress);

    return LinearProgressIndicator(
      value: progress,
      backgroundColor: Colors.transparent,
      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
      minHeight: 2,
    );
  }

  /// Green → Yellow → Red smooth gradient based on remaining time ratio.
  /// 1.0 (full) = green, 0.5 = yellow, 0.0 = red
  static Color _countdownColor(double progress) {
    const green = Color(0xFF4CAF50);
    const yellow = Color(0xFFFFC107);
    const red = Color(0xFFF44336);

    if (progress > 0.5) {
      // Green → Yellow (1.0 → 0.5 maps to t 0.0 → 1.0)
      final t = (1.0 - progress) / 0.5;
      return Color.lerp(green, yellow, t)!;
    } else {
      // Yellow → Red (0.5 → 0.0 maps to t 0.0 → 1.0)
      final t = (0.5 - progress) / 0.5;
      return Color.lerp(yellow, red, t)!;
    }
  }

}
