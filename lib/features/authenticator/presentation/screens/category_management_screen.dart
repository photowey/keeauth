import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/category_color_picker.dart';

class CategoryManagementScreen extends StatefulWidget {
  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthenticatorBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.categories ?? 'Categories'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategoryDialog(context),
            tooltip: l10n?.addCategory ?? 'Add Category',
          ),
        ],
      ),
      body: BlocBuilder<AuthenticatorBloc, AuthenticatorState>(
        builder: (context, state) {
          final categories = state.categories;

          if (categories.isEmpty) {
            return _buildEmptyState(context);
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            onReorder: (oldIndex, newIndex) {
              context.read<AuthenticatorBloc>().add(
                    ReorderCategories(oldIndex, newIndex),
                  );
            },
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryTile(context, category, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.noCategories ?? 'No categories',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _showAddCategoryDialog(context),
            icon: const Icon(Icons.add),
            label: Text(l10n?.addCategory ?? 'Add Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    Category category,
    int index,
  ) {
    final theme = Theme.of(context);
    return Material(
      key: ValueKey(category.id),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.star,
              size: 20,
              color: Color(category.displayColorInt),
            ),
          ],
        ),
        title: Text(category.name),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => _showEditCategoryDialog(context, category),
              tooltip: AppLocalizations.of(context)?.edit ?? 'Edit',
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outlined,
                color: theme.colorScheme.error,
              ),
              onPressed: () => _showDeleteConfirmDialog(context, category),
              tooltip: AppLocalizations.of(context)?.delete ?? 'Delete',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();
    int selectedColor = 0xFF4CAF50;

    final result = await showDialog<({String name, int color})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
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
                      hintText: l10n?.enterCategoryName ?? 'Enter category name',
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        Navigator.pop(
                          ctx,
                          (name: text, color: selectedColor),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.categoryColor ?? 'Color',
                    style: Theme.of(ctx).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  CategoryColorPicker(
                    initialColor: selectedColor,
                    onColorChanged: (color) {
                      setDialogState(() => selectedColor = color);
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
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.pop(
                      ctx,
                      (name: text, color: selectedColor),
                    );
                  }
                },
                child: Text(l10n?.add ?? 'Add'),
              ),
            ],
          );
        },
      ),
    );
    if (result != null && context.mounted) {
      context.read<AuthenticatorBloc>().add(
            CreateCategory(result.name, color: result.color),
          );
    }
  }

  Future<void> _showEditCategoryDialog(
    BuildContext context,
    Category category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: category.name);
    int selectedColor = category.color ?? category.displayColorInt;

    final result = await showDialog<({String name, int color})>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            title: Text(l10n?.editCategory ?? 'Edit Category'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: l10n?.categoryName ?? 'Category Name',
                      hintText: l10n?.enterCategoryName ?? 'Enter category name',
                      border: const OutlineInputBorder(),
                    ),
                    autofocus: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      final text = controller.text.trim();
                      if (text.isNotEmpty) {
                        Navigator.pop(ctx, (name: text, color: selectedColor));
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.categoryColor ?? 'Color',
                    style: Theme.of(ctx).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  CategoryColorPicker(
                    initialColor: selectedColor,
                    onColorChanged: (color) {
                      setDialogState(() => selectedColor = color);
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
                  final text = controller.text.trim();
                  if (text.isNotEmpty) {
                    Navigator.pop(ctx, (name: text, color: selectedColor));
                  }
                },
                child: Text(l10n?.save ?? 'Save'),
              ),
            ],
          );
        },
      ),
    );
    if (result != null && context.mounted) {
      context.read<AuthenticatorBloc>().add(
            UpdateCategory(category.copyWith(name: result.name, color: result.color)),
          );
    }
  }

  Future<void> _showDeleteConfirmDialog(
    BuildContext context,
    Category category,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteCategory ?? 'Delete Category'),
        content: Text(
          l10n?.deleteCategoryConfirm(category.name) ??
              'Are you sure you want to delete "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthenticatorBloc>().add(DeleteCategory(category.id));
    }
  }
}
