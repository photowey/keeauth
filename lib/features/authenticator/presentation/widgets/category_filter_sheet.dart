import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'category_color_picker.dart';

/// Mode for the category sheet
enum CategorySheetMode {
  filter, // For filtering authenticators
  select, // For selecting category for an authenticator
}

/// Bottom sheet for filtering or selecting categories
class CategoryFilterSheet extends StatelessWidget {
  final CategorySheetMode mode;
  final List<String>? selectedCategoryIds;

  const CategoryFilterSheet({
    super.key,
    this.mode = CategorySheetMode.filter,
    this.selectedCategoryIds,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AuthenticatorBloc, AuthenticatorState>(
      builder: (context, state) {
        final title =
            mode == CategorySheetMode.filter
                ? (l10n?.category ?? 'Filter by Category')
                : (l10n?.selectCategory ?? 'Select Category');

        final maxHeight = MediaQuery.of(context).size.height * 0.65;

        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (mode == CategorySheetMode.filter) ...[
                          ListTile(
                            leading: const Icon(Icons.apps),
                            title: Text(l10n?.all ?? 'All'),
                            selected: state.selectedCategoryId == null,
                            onTap: () {
                              context.read<AuthenticatorBloc>().add(
                                const FilterByCategory(null),
                              );
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.folder_off),
                            title: Text(l10n?.uncategorized ?? 'Uncategorized'),
                            selected: false,
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Divider(),
                        ],

                        ...state.categories.map((category) {
                          final isSelected =
                              mode == CategorySheetMode.filter
                                  ? state.selectedCategoryId == category.id
                                  : (selectedCategoryIds?.contains(category.id) ?? false);

                          return ListTile(
                            leading: Icon(
                              isSelected
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              color:
                                  isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : null,
                            ),
                            title: Text(category.name),
                            selected: isSelected,
                            onTap: () {
                              if (mode == CategorySheetMode.filter) {
                                context.read<AuthenticatorBloc>().add(
                                  FilterByCategory(category.id),
                                );
                                Navigator.pop(context);
                              } else {
                                Navigator.pop(context, category.id);
                              }
                            },
                          );
                        }),

                        const Divider(),

                        ListTile(
                          leading: const Icon(Icons.add),
                          title: Text(l10n?.addCategory ?? 'Add Category'),
                          onTap: () {
                            Navigator.pop(context);
                            _showAddCategoryDialog(context);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        int selectedColor = Theme.of(context).colorScheme.primary.toARGB32();
        return AlertDialog(
          title: Text(l10n?.addCategory ?? 'Add Category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    labelText: l10n?.categoryName ?? 'Category Name',
                    hintText:
                        '${AppLocalizations.of(context)?.issuer ?? 'Issuer'}: Work, Personal',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.categoryColor ?? 'Color',
                  style: Theme.of(context).textTheme.labelMedium,
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
              onPressed: () => Navigator.pop(context),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  context.read<AuthenticatorBloc>().add(
                    CreateCategory(
                      controller.text,
                      color: selectedColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(l10n?.add ?? 'Add'),
            ),
          ],
        );
      },
    );
  }
}
