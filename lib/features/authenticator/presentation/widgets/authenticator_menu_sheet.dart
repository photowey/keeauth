import 'package:flutter/material.dart';
import 'package:keeauth/core/crypto/otp_generator.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';

/// Bottom sheet for authenticator context menu
///   DragHandle → Centered Title → [HOTP Counter] → [CopyCount] → Menu items
class AuthenticatorMenuSheet extends StatelessWidget {
  final Authenticator authenticator;
  final int? counter;
  final int? copyCount;
  final VoidCallback? onShowDetails;
  final VoidCallback? onEditDetails;
  final VoidCallback? onChangeIcon;
  final VoidCallback? onAssignCategories;
  final VoidCallback? onShowQrCode;
  final VoidCallback? onDelete;

  const AuthenticatorMenuSheet({
    super.key,
    required this.authenticator,
    this.counter,
    this.copyCount,
    this.onShowDetails,
    this.onEditDetails,
    this.onChangeIcon,
    this.onAssignCategories,
    this.onShowQrCode,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final title = authenticator.issuer.isNotEmpty
        ? authenticator.issuer
        : authenticator.accountName;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Material3 BottomSheet drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Centered title (textAppearanceTitleLarge)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                title,
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),

            // HOTP counter row (visible only for counter-based types)
            if (authenticator.type == AuthenticatorType.hotp && counter != null)
              _buildInfoRow(
                context,
                icon: Icons.refresh,
                text: counter.toString(),
              ),

            // Copy count row (visible when sort by copy count)
            if (copyCount != null && copyCount! > 0)
              _buildInfoRow(
                context,
                icon: Icons.content_copy,
                text: copyCount.toString(),
              ),

            // Menu items (RecyclerView equivalent)
            _buildMenuItem(
              context,
              icon: Icons.info_outline,
              label: l10n?.details ?? 'Details',
              onTap: () {
                Navigator.pop(context);
                onShowDetails?.call();
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.edit,
              label: l10n?.editDetails ?? 'Edit details',
              onTap: () {
                Navigator.pop(context);
                onEditDetails?.call();
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.image_outlined,
              label: l10n?.changeIcon ?? 'Change icon',
              onTap: () {
                Navigator.pop(context);
                onChangeIcon?.call();
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.category,
              label: l10n?.assignCategories ?? 'Specify categories',
              onTap: () {
                Navigator.pop(context);
                onAssignCategories?.call();
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.qr_code,
              label: l10n?.showQrCode ?? 'Show QR code',
              onTap: () {
                Navigator.pop(context);
                onShowQrCode?.call();
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.delete_outline,
              label: l10n?.delete ?? 'Delete',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                onDelete?.call();
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 16, right: 16, top: 8, bottom: 16,
      ),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.onSurface),
          const SizedBox(width: 32),
          Text(
            text,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// Menu item matching listItemMenu.axml:
  /// 56dp minHeight, 16dp horizontal padding, 12dp vertical padding
  /// Icon 24dp + 32dp gap + title (subtitle1)
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 32),
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

/// Show authenticator menu bottom sheet
Future<void> showAuthenticatorMenu(
  BuildContext context, {
  required Authenticator authenticator,
  VoidCallback? onShowDetails,
  VoidCallback? onEditDetails,
  VoidCallback? onChangeIcon,
  VoidCallback? onAssignCategories,
  VoidCallback? onShowQrCode,
  VoidCallback? onDelete,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => AuthenticatorMenuSheet(
      authenticator: authenticator,
      onShowDetails: onShowDetails,
      onEditDetails: onEditDetails,
      onChangeIcon: onChangeIcon,
      onAssignCategories: onAssignCategories,
      onShowQrCode: onShowQrCode,
      onDelete: onDelete,
    ),
  );
}
