import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';

/// Bottom sheet for main menu
///   DragHandle → Centered Title → "Categories" section (category filter list)
///   → "More" section (Backup, Categories, Icon Packs, Settings, About)
class MainMenuSheet extends StatelessWidget {
  final String? currentCategoryId;
  final ValueChanged<String?>? onCategorySelected;
  final VoidCallback? onManageCategories;
  final VoidCallback? onBackup;
  final VoidCallback? onSettings;
  final VoidCallback? onAbout;

  const MainMenuSheet({
    super.key,
    this.currentCategoryId,
    this.onCategorySelected,
    this.onManageCategories,
    this.onBackup,
    this.onSettings,
    this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Material3 drag handle
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Centered title (textAppearanceTitleLarge)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  l10n?.mainMenu ?? 'Main menu',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),

              // --- Categories section ---
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 18,
                  ),
                  child: Text(
                    l10n?.categories ?? 'Categories',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              // Category list from BLoC state
              BlocBuilder<AuthenticatorBloc, AuthenticatorState>(
                builder: (context, state) {
                  return _buildCategoryList(
                    context, theme, l10n, state.categories,
                  );
                },
              ),

              const SizedBox(height: 20),

              // --- "More" section ---
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16, right: 16, bottom: 12,
                  ),
                  child: Text(
                    l10n?.more ?? 'More',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),

              _buildMenuItem(
                context,
                icon: Icons.save_outlined,
                label: l10n?.backUp ?? 'Back up',
                onTap: () {
                  Navigator.pop(context);
                  onBackup?.call();
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.category_outlined,
                label: l10n?.editCategories ?? 'Edit categories',
                onTap: () {
                  Navigator.pop(context);
                  onManageCategories?.call();
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.settings_outlined,
                label: l10n?.settings ?? 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  onSettings?.call();
                },
              ),
              _buildMenuItem(
                context,
                icon: Icons.info_outline,
                label: l10n?.about ?? 'About',
                onTap: () {
                  Navigator.pop(context);
                  onAbout?.call();
                },
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
    List<Category> categories,
  ) {
    final isAllSelected = currentCategoryId == null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor, width: 0.5),
          bottom: BorderSide(color: theme.dividerColor, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // "All" category
          _buildCategoryItem(
            context,
            label: l10n?.all ?? 'All',
            isSelected: isAllSelected,
            onTap: () {
              Navigator.pop(context);
              onCategorySelected?.call(null);
            },
          ),
          // Each category
          ...categories.map((category) {
            final isSelected = currentCategoryId == category.id;
            return _buildCategoryItem(
              context,
              label: category.name,
              isSelected: isSelected,
              onTap: () {
                Navigator.pop(context);
                onCategorySelected?.call(category.id);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isSelected
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.5)
            : null,
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.folder : Icons.folder_outlined,
              size: 24,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check, size: 20, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  /// Menu item matching listItemMenu.axml
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.onSurface),
            const SizedBox(width: 32),
            Text(
              label,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Show main menu bottom sheet
Future<void> showMainMenu(
  BuildContext context, {
  String? currentCategoryId,
  ValueChanged<String?>? onCategorySelected,
  VoidCallback? onManageCategories,
  VoidCallback? onBackup,
  VoidCallback? onSettings,
  VoidCallback? onAbout,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MainMenuSheet(
      currentCategoryId: currentCategoryId,
      onCategorySelected: onCategorySelected,
      onManageCategories: onManageCategories,
      onBackup: onBackup,
      onSettings: onSettings,
      onAbout: onAbout,
    ),
  );
}
