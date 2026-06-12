import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'category_color_picker.dart';

class CategoryAssignmentDialog extends StatefulWidget {
  final Authenticator authenticator;

  const CategoryAssignmentDialog({super.key, required this.authenticator});

  @override
  State<CategoryAssignmentDialog> createState() =>
      _CategoryAssignmentDialogState();
}

class _CategoryAssignmentDialogState extends State<CategoryAssignmentDialog> {
  late Set<String> _selectedCategoryIds;

  Future<void> _showCreateCategoryInDialog(
    BuildContext context,
    AuthenticatorState state,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    int selectedColor = Theme.of(context).colorScheme.primary.toARGB32();

    final result = await showDialog<({String name, int color})>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n?.createCategory ?? 'Create category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n?.categoryName ?? 'Category name',
                    hintText: l10n?.enterCategoryName ?? 'Enter category name',
                  ),
                  onSubmitted: (value) {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      Navigator.pop(ctx, (name: name, color: selectedColor));
                    }
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.categoryColor ?? 'Color',
                  style: Theme.of(ctx).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                CategoryColorPicker(
                  initialColor: selectedColor,
                  onColorChanged: (color) {
                    selectedColor = color;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(
                    ctx,
                    (name: name, color: selectedColor),
                  );
                }
              },
              child: Text(l10n?.save ?? 'Save'),
            ),
          ],
        );
      },
    );
    if (result != null && context.mounted) {
      context.read<AuthenticatorBloc>().add(
            CreateCategory(result.name, color: result.color),
          );
    }
  }

  @override
  void initState() {
    super.initState();
    // Read the freshest categoryIds from BLoC state to avoid stale data
    final bloc = context.read<AuthenticatorBloc>();
    final freshAuth = bloc.state.authenticators.firstWhere(
      (a) => a.secret == widget.authenticator.secret,
      orElse: () => widget.authenticator,
    );
    _selectedCategoryIds = Set<String>.from(freshAuth.categoryIds);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<AuthenticatorBloc, AuthenticatorState>(
      builder: (context, state) {
        final hasCategories = state.categories.isNotEmpty;

        return AlertDialog(
          title: Text(l10n?.assignCategories ?? 'Assign Categories'),
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: hasCategories
                  ? MediaQuery.of(context).size.height * 0.5
                  : 160,
              minWidth: 280,
            ),
            child: hasCategories
                ? ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.categories.length,
                    itemBuilder: (context, index) {
                      final category = state.categories[index];
                      final isSelected =
                          _selectedCategoryIds.contains(category.id);
                      final theme = Theme.of(context);
                      return Material(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedCategoryIds.remove(category.id);
                              } else {
                                _selectedCategoryIds.add(category.id);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 18,
                                  color: Color(category.displayColorInt),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  isSelected
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  size: 22,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? theme.colorScheme.onPrimaryContainer
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n?.noCategoriesCreate ??
                                'No categories. Create one first.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: () => _showCreateCategoryInDialog(context, state),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(l10n?.createCategory ?? 'Create category'),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            if (hasCategories)
              FilledButton(
                onPressed: () {
                  final updated = widget.authenticator.copyWith(
                    categoryIds: _selectedCategoryIds.toList(),
                    updatedAt: DateTime.now(),
                  );
                  context
                      .read<AuthenticatorBloc>()
                      .add(UpdateAuthenticator(updated));
                  Navigator.pop(context);
                },
                child: Text(l10n?.save ?? 'Save'),
              ),
          ],
        );
      },
    );
  }
}

Future<void> showCategoryAssignmentDialog(
  BuildContext context, {
  required Authenticator authenticator,
}) {
  return showDialog(
    context: context,
    builder: (context) =>
        CategoryAssignmentDialog(authenticator: authenticator),
  );
}
