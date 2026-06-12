import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keeauth/l10n/app_localizations.dart';

import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/authenticator_icon.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/authenticator_qr_sheet.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/edit_authenticator_sheet.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/icon_picker_sheet.dart';
import 'category_filter_sheet.dart';

/// Bottom sheet for displaying authenticator details
class AuthenticatorDetailsSheet extends StatefulWidget {
  final Authenticator authenticator;
  final String code;
  final int remainingSeconds;

  const AuthenticatorDetailsSheet({
    super.key,
    required this.authenticator,
    required this.code,
    required this.remainingSeconds,
  });

  @override
  State<AuthenticatorDetailsSheet> createState() =>
      _AuthenticatorDetailsSheetState();
}

class _AuthenticatorDetailsSheetState extends State<AuthenticatorDetailsSheet> {
  bool _showSecret = false;
  Timer? _hideSecretTimer;

  @override
  void dispose() {
    _hideSecretTimer?.cancel();
    super.dispose();
  }

  void _toggleSecret() {
    setState(() {
      _showSecret = !_showSecret;
    });

    if (_showSecret) {
      // Auto-hide after 5 seconds
      _hideSecretTimer?.cancel();
      _hideSecretTimer = Timer(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _showSecret = false;
          });
        }
      });
    }
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.code.replaceAll(' ', '')));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)?.codeCopied ?? 'Code copied',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _copySecret(BuildContext context) {
    Clipboard.setData(ClipboardData(text: widget.authenticator.secret));
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.secretCopied ?? 'Secret copied'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Fixed header: drag handle + close button
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 20, right: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                      tooltip: l10n?.close ?? 'Close',
                    ),
                  ],
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Header with icon and name (use BLoC state so icon/name update in-place)
                        BlocBuilder<AuthenticatorBloc, AuthenticatorState>(
                          buildWhen: (prev, curr) =>
                              prev.authenticators != curr.authenticators,
                          builder: (context, state) {
                            final current = state.authenticators.firstWhere(
                              (a) => a.secret == widget.authenticator.secret,
                              orElse: () => widget.authenticator,
                            );
                            return Row(
                              children: [
                                AuthenticatorIcon(
                                  issuer: current.issuer,
                                  customIconPath: current.icon,
                                  size: 56,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        current.issuer.isNotEmpty
                                            ? current.issuer
                                            : current.accountName,
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (current.issuer.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          current.accountName,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                      _buildCategoryChips(context),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        // TOTP Code section - live updating
                        BlocBuilder<AuthenticatorBloc, AuthenticatorState>(
                          builder: (context, state) {
                            final liveCode =
                                state.codes[widget.authenticator.secret] ?? widget.code;
                            final liveRemaining = state.remainingSeconds;
                            return _buildCodeSection(context, l10n, liveCode, liveRemaining);
                          },
                        ),
                        const SizedBox(height: 24),

                        _buildSecretSection(context, l10n),
                        const SizedBox(height: 24),

                        _buildTechnicalDetails(context, l10n),
                        const SizedBox(height: 24),

                        _buildActionButtons(context, l10n),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCodeSection(
    BuildContext context,
    AppLocalizations? l10n,
    String code,
    int remainingSeconds,
  ) {
    final period = widget.authenticator.period;
    final progress = period > 0 ? remainingSeconds / period : 0.0;

    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code.replaceAll(' ', '')));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.codeCopied ?? 'Code copied'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              l10n?.currentCode ?? 'Current Code',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _formatCode(code),
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                letterSpacing: 4,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _countdownColor(progress),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${remainingSeconds}s',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecretSection(BuildContext context, AppLocalizations? l10n) {
    final maskedSecret =
        widget.authenticator.secret.length > 8
            ? '${widget.authenticator.secret.substring(0, 4)}****${widget.authenticator.secret.substring(widget.authenticator.secret.length - 4)}'
            : '****';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.secretKey ?? 'Secret Key',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _toggleSecret,
          onLongPress: () => _copySecret(context),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(
                  _showSecret ? Icons.visibility_off : Icons.visibility,
                  size: 18,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _showSecret ? widget.authenticator.secret : maskedSecret,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      color: _showSecret ? Colors.black : Colors.grey[600],
                      letterSpacing: _showSecret ? 1 : 0,
                    ),
                  ),
                ),
                if (_showSecret)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copySecret(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),
        if (!_showSecret)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              l10n?.tapToReveal ?? 'Tap to reveal',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ),
      ],
    );
  }

  Widget _buildTechnicalDetails(BuildContext context, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.technicalDetails ?? 'Technical Details',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDetailChip(
              icon: Icons.alternate_email,
              label: l10n?.type ?? 'Type',
              value: widget.authenticator.type.name.toUpperCase(),
            ),
            _buildDetailChip(
              icon: Icons.fingerprint,
              label: l10n?.algorithm ?? 'Algorithm',
              value: widget.authenticator.algorithm.displayName,
            ),
            _buildDetailChip(
              icon: Icons.format_list_numbered,
              label: l10n?.digits ?? 'Digits',
              value: widget.authenticator.digits.toString(),
            ),
            _buildDetailChip(
              icon: Icons.timer,
              label: l10n?.period ?? 'Period',
              value: '${widget.authenticator.period}s',
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '${l10n?.createdAt ?? 'Created'}: ${_formatDate(widget.authenticator.createdAt)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildDetailChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations? l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showEditSheet(context),
                icon: const Icon(Icons.edit, size: 18),
                label: Text(l10n?.edit ?? 'Edit'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showIconPicker(context),
                icon: const Icon(Icons.image, size: 18),
                label: Text(l10n?.changeIcon ?? 'Icon'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCategoryPicker(context),
                icon: const Icon(Icons.category, size: 18),
                label: Text(l10n?.assignCategories ?? 'Specify categories'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  showAuthenticatorQrSheet(
                    context,
                    issuer: widget.authenticator.issuer,
                    accountName: widget.authenticator.accountName,
                    secret: widget.authenticator.secret,
                  );
                },
                icon: const Icon(Icons.qr_code, size: 18),
                label: Text(l10n?.qrCode ?? 'QR Code'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _copyCode(context),
            icon: const Icon(Icons.copy, size: 18),
            label: Text(l10n?.copy ?? 'Copy'),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return BlocBuilder<AuthenticatorBloc, AuthenticatorState>(
      builder: (context, state) {
        // Get latest authenticator from state
        final currentAuth = state.authenticators.firstWhere(
          (a) => a.secret == widget.authenticator.secret,
          orElse: () => widget.authenticator,
        );

        if (currentAuth.categoryIds.isEmpty) {
          return const SizedBox.shrink();
        }

        final categoryNames =
            currentAuth.categoryIds.map((id) {
              final category = state.categories.firstWhere(
                (c) => c.id == id,
                orElse:
                    () => Category(
                      id: id,
                      name: 'Unknown',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
              );
              return category.name;
            }).toList();

        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children:
                categoryNames.map((name) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      name,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }

  void _showEditSheet(BuildContext context) {
    Navigator.pop(context);
    showEditAuthenticator(
      context,
      authenticator: widget.authenticator,
    );
  }

  void _showIconPicker(BuildContext context) async {
    final result = await showIconPicker(
      context,
      initialName: widget.authenticator.issuer,
    );

    if (result != null && context.mounted) {
      final updated = widget.authenticator.copyWith(
        icon: result.isCustom ? result.customPath : result.assetPath,
      );
      context.read<AuthenticatorBloc>().add(UpdateAuthenticator(updated));
    }
  }

  void _showCategoryPicker(BuildContext context) async {
    // Get fresh state right before showing picker
    final bloc = context.read<AuthenticatorBloc>();
    final state = bloc.state;
    final currentAuth = state.authenticators.firstWhere(
      (a) => a.secret == widget.authenticator.secret,
      orElse: () => widget.authenticator,
    );

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder:
          (sheetContext) => CategoryFilterSheet(
            mode: CategorySheetMode.select,
            selectedCategoryIds: currentAuth.categoryIds,
          ),
    );

    if (result != null && context.mounted) {
      // Get fresh state again after picker closes
      final freshState = bloc.state;
      final freshAuth = freshState.authenticators.firstWhere(
        (a) => a.secret == widget.authenticator.secret,
        orElse: () => currentAuth,
      );

      // Toggle category: add if not exists, remove if exists
      final updatedCategoryIds = [...freshAuth.categoryIds];
      if (updatedCategoryIds.contains(result)) {
        updatedCategoryIds.remove(result);
      } else {
        updatedCategoryIds.add(result);
      }
      final updated = freshAuth.copyWith(categoryIds: updatedCategoryIds);
      bloc.add(UpdateAuthenticator(updated));
    }
  }

  String _formatCode(String code) {
    if (code.length <= 3) return code;
    final midpoint = code.length ~/ 2;
    return '${code.substring(0, midpoint)} ${code.substring(midpoint)}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Green → Yellow → Red smooth gradient based on remaining time ratio.
  Color _countdownColor(double progress) {
    const green = Color(0xFF4CAF50);
    const yellow = Color(0xFFFFC107);
    const red = Color(0xFFF44336);

    if (progress > 0.5) {
      final t = (1.0 - progress) / 0.5;
      return Color.lerp(green, yellow, t)!;
    } else {
      final t = (0.5 - progress) / 0.5;
      return Color.lerp(yellow, red, t)!;
    }
  }
}

/// Show authenticator details bottom sheet
Future<void> showAuthenticatorDetails(
  BuildContext context, {
  required Authenticator authenticator,
  required String code,
  required int remainingSeconds,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => AuthenticatorDetailsSheet(
          authenticator: authenticator,
          code: code,
          remainingSeconds: remainingSeconds,
        ),
  );
}
