import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keeauth/core/utils/code_util.dart';
import 'package:keeauth/l10n/app_localizations.dart';

/// Widget for displaying OTP code with tap-to-reveal functionality
class TotpCodeDisplay extends StatefulWidget {
  final String code;
  final int remainingSeconds;
  final int period;
  final bool tapToRevealEnabled;
  final VoidCallback? onTap;
  final TextStyle? textStyle;
  final int codeGroupSize;

  const TotpCodeDisplay({
    super.key,
    required this.code,
    required this.remainingSeconds,
    required this.period,
    this.tapToRevealEnabled = false,
    this.onTap,
    this.textStyle,
    this.codeGroupSize = 3,
  });

  @override
  State<TotpCodeDisplay> createState() => TotpCodeDisplayState();
}

class TotpCodeDisplayState extends State<TotpCodeDisplay> {
  bool _isRevealed = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  /// Public toggle so the parent card can call it on tap.
  void toggle() {
    _handleTap();
  }

  void _handleTap() {
    if (widget.tapToRevealEnabled) {
      setState(() {
        _isRevealed = !_isRevealed;
      });

      if (_isRevealed) {
        // Auto-hide after 5 seconds
        _hideTimer?.cancel();
        _hideTimer = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _isRevealed = false);
          }
        });
      }
    }

    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final shouldShowCode = !widget.tapToRevealEnabled || _isRevealed;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Using displaySmall style which matches original textAppearanceDisplaySmall
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              shouldShowCode
                  ? CodeUtil.padCode(
                      widget.code, widget.code.length, widget.codeGroupSize)
                  : '••• •••',
              key: ValueKey(shouldShowCode),
              style: (widget.textStyle ?? theme.textTheme.displaySmall)
                  ?.copyWith(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                    color:
                        shouldShowCode
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ),

          // Tap to reveal hint
          if (widget.tapToRevealEnabled && !_isRevealed)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                l10n?.tapToRevealHint ?? 'Tap to reveal',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );
  }

}
