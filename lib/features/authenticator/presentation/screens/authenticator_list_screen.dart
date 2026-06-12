
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keeauth/core/storage/secure_storage_service.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/pages/about/about_us_page.dart';
import 'package:keeauth/features/backup/presentation/export_backup.dart';
import 'package:keeauth/features/backup/presentation/restore_backup.dart';
import 'package:keeauth/features/backup/presentation/screens/import_screen.dart';
import 'package:keeauth/features/settings/presentation/screens/settings_screen.dart';
import 'package:keeauth/features/authenticator/presentation/bloc/authenticator_bloc.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/authenticator_list_item.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/authenticator_qr_sheet.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/add_authenticator_sheet.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/totp_code_display.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/authenticator_details_sheet.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/edit_authenticator_sheet.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/icon_picker_sheet.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/main_menu_sheet.dart';
import 'package:keeauth/features/authenticator/presentation/widgets/search_app_bar.dart';
import 'category_management_screen.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';

/// Main screen displaying list of authenticators
class AuthenticatorListScreen extends StatefulWidget {
  const AuthenticatorListScreen({super.key});

  @override
  State<AuthenticatorListScreen> createState() =>
      _AuthenticatorListScreenState();
}

class _AuthenticatorListScreenState extends State<AuthenticatorListScreen> {
  final SecureStorageService _secureStorage = SecureStorageService();
  bool _tapToRevealEnabled = false;
  final Map<String, GlobalKey<TotpCodeDisplayState>> _revealKeys = {};
  int _codeGroupSize = 3;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final tapToReveal = await _secureStorage.isTapToRevealEnabled();
    final codeGroupSize = await _secureStorage.getCodeGroupSize();
    final viewMode = await _secureStorage.getViewMode();
    if (mounted) {
      setState(() {
        _tapToRevealEnabled = tapToReveal;
        _codeGroupSize = codeGroupSize;
      });
      context.read<AuthenticatorBloc>().add(SetViewMode(viewMode));
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        context.read<AuthenticatorBloc>().add(ClearSearch());
      }
    });
  }

  void _onSearchChanged(String query) {
    context.read<AuthenticatorBloc>().add(SearchAuthenticators(query));
  }

  void _clearSearch() {
    context.read<AuthenticatorBloc>().add(ClearSearch());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<AuthenticatorBloc, AuthenticatorState>(
      builder: (context, state) {
        final categoryName = state.selectedCategoryId != null
            ? state.categories
                .where((c) => c.id == state.selectedCategoryId)
                .map((c) => c.name)
                .firstOrNull
            : null;

        return Scaffold(
          appBar: SearchAppBar(
            title: categoryName ?? (l10n?.authenticator ?? 'Authenticator'),
            isSearching: _isSearching,
            searchQuery: state.searchQuery,
            onSearchChanged: _onSearchChanged,
            onSearchToggle: _toggleSearch,
            onSearchClear: _clearSearch,
            actions: [
              PopupMenuButton<SortMode>(
                icon: const Icon(Icons.sort),
                tooltip: l10n?.sortMode ?? 'Sort',
                onSelected: (mode) {
                  context.read<AuthenticatorBloc>().add(SetSortMode(mode));
                },
                itemBuilder: (context) => [
                  _buildSortMenuItem(SortMode.manual, l10n?.manual ?? 'Custom', Icons.drag_handle, state.sortMode),
                  _buildSortMenuItem(SortMode.alphabeticalAsc, l10n?.sortAZ ?? 'A-Z', Icons.sort_by_alpha, state.sortMode),
                  _buildSortMenuItem(SortMode.alphabeticalDesc, l10n?.sortZA ?? 'Z-A', Icons.sort_by_alpha, state.sortMode),
                  _buildSortMenuItem(SortMode.mostUsed, l10n?.mostUsed ?? 'Most Used', Icons.trending_up, state.sortMode),
                  _buildSortMenuItem(SortMode.leastUsed, l10n?.leastUsed ?? 'Least Used', Icons.trending_down, state.sortMode),
                ],
              ),
            ],
          ),
          body: _buildBody(context, state),
          bottomNavigationBar: _buildBottomAppBar(),
          floatingActionButton: _buildFAB(),
          floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        );
      },
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 64,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: _showMainMenu,
            tooltip: AppLocalizations.of(context)?.mainMenu ?? 'Menu',
          ),
          IconButton(
            icon: Icon(_isSearching ? Icons.search_off : Icons.search),
            onPressed: _toggleSearch,
            tooltip: AppLocalizations.of(context)?.search ?? 'Search',
          ),
        ],
      ),
    );
  }

  PopupMenuEntry<SortMode> _buildSortMenuItem(SortMode mode, String label, IconData icon, SortMode current) {
    return PopupMenuItem<SortMode>(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
          if (mode == current) ...[
            const Spacer(),
            const Icon(Icons.check, size: 18),
          ],
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return _AnimatedFAB(
      onPressed: () => _showAddAuthenticator(context),
    );
  }

  void _showMainMenu() {
    final bloc = context.read<AuthenticatorBloc>();
    showMainMenu(
      context,
      currentCategoryId: bloc.state.selectedCategoryId,
      onCategorySelected: (categoryId) {
        bloc.add(FilterByCategory(categoryId));
      },
      onManageCategories: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoryManagementScreen(),
          ),
        );
      },
      onBackup: () {
        showExportBackupDialog(context);
      },
      onSettings: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        _loadSettings();
      },
      onAbout: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AboutUsPage()),
        );
      },
    );
  }

  // ─── Body ───────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context, AuthenticatorState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      final l10n = AppLocalizations.of(context);
      final errorText = _localizeError(state.error!, l10n);
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(errorText),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<AuthenticatorBloc>().add(LoadAuthenticators());
              },
              child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (state.authenticators.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return _buildEmptyState(
        context,
        l10n?.noAuthenticators ?? 'No authenticators yet',
        l10n?.addFirstAuthenticator ?? 'Add your first authenticator',
      );
    }

    if (state.filteredAuthenticators.isEmpty && state.searchQuery.isNotEmpty) {
      final l10n = AppLocalizations.of(context);
      return _buildEmptyState(
        context,
        l10n?.noResultsFound ?? 'No results found',
        l10n?.tryDifferentSearch ?? 'Try a different search term',
        showClearButton: true,
      );
    }

    if (state.viewMode == ViewMode.tile) {
      return _buildTileGrid(context, state);
    }
    return _buildListView(context, state);
  }

  Widget _buildAnimatedItem(Widget child, int index, {Key? key}) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildListView(BuildContext context, AuthenticatorState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AuthenticatorBloc>().add(LoadAuthenticators());
      },
      child: ReorderableListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: state.filteredAuthenticators.length,
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) newIndex--;
          context.read<AuthenticatorBloc>().add(
            ReorderAuthenticators(oldIndex, newIndex),
          );
        },
        itemBuilder: (context, index) {
          final authenticator = state.filteredAuthenticators[index];
          final code = state.codes[authenticator.secret] ?? '------';

          return _buildAnimatedItem(
            AuthenticatorListItem(
              authenticator: authenticator,
              code: code,
              remainingSeconds: state.remainingSeconds,
              period: authenticator.period,
              viewMode: state.viewMode,
              tapToRevealEnabled: _tapToRevealEnabled,
              codeGroupSize: _codeGroupSize,
              searchQuery: state.searchQuery,
              categoryNames: _categoryNamesFor(authenticator, state.categories),
              categoryColorInts: _categoryColorIntsFor(authenticator, state.categories),
              onDoubleTap: () => _copyCode(context, authenticator.secret),
              onTap: () => _revealKeys[authenticator.secret]?.currentState?.toggle(),
              codeKey: _revealKeys.putIfAbsent(authenticator.secret, () => GlobalKey<TotpCodeDisplayState>()),
              onLongPress:
                  () => _showEditAuthenticator(context, authenticator),
              onShowDetails: () => _showDetailsSheet(
                  context, authenticator, code, state.remainingSeconds),
              onEdit:
                  () => _showEditAuthenticator(context, authenticator),
              onDelete: () => _confirmDelete(context, authenticator),
              onShowQr: () => _showQrCode(context, authenticator),
              onChangeIcon: () => _showChangeIcon(context, authenticator),
              onRefresh: () => context
                  .read<AuthenticatorBloc>()
                  .add(AdvanceHotpCounter(authenticator.secret)),
            ),
            index,
            key: ValueKey(authenticator.secret),
          );
        },
      ),
    );
  }

  List<String> _categoryNamesFor(dynamic authenticator, List<Category> categories) {
    final names = <String>[];
    for (final id in authenticator.categoryIds) {
      final match = categories.where((c) => c.id == id);
      names.add(match.isEmpty ? 'Unknown' : match.first.name);
    }
    return names;
  }

  List<int> _categoryColorIntsFor(dynamic authenticator, List<Category> categories) {
    final colorInts = <int>[];
    for (final id in authenticator.categoryIds) {
      final match = categories.where((c) => c.id == id);
      colorInts.add(match.isEmpty ? 0xFF9E9E9E : match.first.displayColorInt);
    }
    return colorInts;
  }

  Widget _buildTileGrid(BuildContext context, AuthenticatorState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AuthenticatorBloc>().add(LoadAuthenticators());
      },
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 80, left: 8, right: 8, top: 8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemCount: state.filteredAuthenticators.length,
        itemBuilder: (context, index) {
          final authenticator = state.filteredAuthenticators[index];
          final code = state.codes[authenticator.secret] ?? '------';

          return _buildAnimatedItem(
            AuthenticatorListItem(
              authenticator: authenticator,
              code: code,
              remainingSeconds: state.remainingSeconds,
              period: authenticator.period,
              viewMode: ViewMode.tile,
              tapToRevealEnabled: _tapToRevealEnabled,
              codeGroupSize: _codeGroupSize,
              searchQuery: state.searchQuery,
              categoryNames: _categoryNamesFor(authenticator, state.categories),
              categoryColorInts: _categoryColorIntsFor(authenticator, state.categories),
              onDoubleTap: () => _copyCode(context, authenticator.secret),
              onTap: () => _revealKeys[authenticator.secret]?.currentState?.toggle(),
              codeKey: _revealKeys.putIfAbsent(authenticator.secret, () => GlobalKey<TotpCodeDisplayState>()),
              onLongPress:
                  () => _showEditAuthenticator(context, authenticator),
              onShowDetails: () => _showDetailsSheet(
                  context, authenticator, code, state.remainingSeconds),
              onEdit:
                  () => _showEditAuthenticator(context, authenticator),
              onDelete: () => _confirmDelete(context, authenticator),
              onShowQr: () => _showQrCode(context, authenticator),
              onChangeIcon: () => _showChangeIcon(context, authenticator),
              onRefresh: () => context
                  .read<AuthenticatorBloc>()
                  .add(AdvanceHotpCounter(authenticator.secret)),
            ),
            index,
            key: ValueKey(authenticator.secret),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String title,
    String subtitle, {
    bool showClearButton = false,
  }) {
    if (showClearButton) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.clear),
              label: Text(
                AppLocalizations.of(context)?.clearSearch ?? 'Clear Search',
              ),
            ),
          ],
        ),
      );
    }

    // 64dp icon → headline5 title (22dp) → subtitle2 message (12dp) → buttons (centered)
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 10),
            // Getting Started Guide — TextButton with icon
            TextButton.icon(
              onPressed: () => _showGuideDialog(context),
              icon: const Icon(Icons.help_outline),
              label: Text(l10n?.gettingStartedGuide ?? 'Getting started guide'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 4),
            // Import from other apps — OutlinedButton with icon
            OutlinedButton.icon(
              onPressed: () => _navigateToImport(context),
              icon: const Icon(Icons.input),
              label: Text(l10n?.importFromOtherApps ?? 'Import from other apps'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
            const SizedBox(height: 4),
            // Restore backup — OutlinedButton with icon
            OutlinedButton.icon(
              onPressed: () => restoreBackupFromFile(context),
              icon: const Icon(Icons.restore),
              label: Text(l10n?.restoreBackup ?? 'Restore a backup'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToImport(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ImportScreen()),
    );
  }

  void _showGuideDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.gettingStarted ?? 'Getting Started'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n?.guideStep1 ?? '1. Tap the + button to add a new authenticator'),
              const SizedBox(height: 8),
              Text(l10n?.guideStep2 ?? '2. Scan a QR code or enter the secret manually'),
              const SizedBox(height: 8),
              Text(l10n?.guideStep3 ?? '3. Your codes will be generated automatically'),
              const SizedBox(height: 8),
              Text(l10n?.guideStep4 ?? '4. Tap a code to copy it to clipboard'),
              const SizedBox(height: 8),
              Text(l10n?.guideStep5 ?? '5. Use the menu to manage categories and settings'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n?.gotIt ?? 'Got it'),
          ),
        ],
      ),
    );
  }

  String _localizeError(String error, AppLocalizations? l10n) {
    if (error.contains('Invalid URI')) {
      return l10n?.invalidUri ?? error;
    }
    if (error.contains('Authenticator already exists')) {
      return l10n?.authenticatorAlreadyExists ?? error;
    }
    return error;
  }

  void _showAddAuthenticator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddAuthenticatorSheet(),
    );
  }

  void _showDetailsSheet(
    BuildContext context,
    dynamic authenticator,
    String code,
    int remainingSeconds,
  ) {
    showAuthenticatorDetails(
      context,
      authenticator: authenticator,
      code: code,
      remainingSeconds: remainingSeconds,
    );
  }

  void _showEditAuthenticator(
    BuildContext context,
    dynamic authenticator,
  ) {
    showEditAuthenticator(context, authenticator: authenticator);
  }

  void _showChangeIcon(BuildContext context, dynamic authenticator) async {
    final result = await showIconPicker(
      context,
      initialName: authenticator.issuer,
    );
    if (result != null && context.mounted) {
      final updated = authenticator.copyWith(
        icon: result.isCustom ? result.customPath : result.assetPath,
      );
      context.read<AuthenticatorBloc>().add(UpdateAuthenticator(updated));
    }
  }

  void _showQrCode(BuildContext context, dynamic authenticator) {
    showAuthenticatorQrSheet(
      context,
      issuer: authenticator.issuer,
      accountName: authenticator.accountName,
      secret: authenticator.secret,
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    dynamic authenticator,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              AppLocalizations.of(context)?.deleteAuthenticator ??
                  'Delete Authenticator',
            ),
            content: Text(
              AppLocalizations.of(context)?.deleteConfirm ??
                  'Are you sure you want to delete this authenticator?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppLocalizations.of(context)?.delete ?? 'Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      context.read<AuthenticatorBloc>().add(
        DeleteAuthenticator(authenticator.secret),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.authenticatorDeleted ??
                'Authenticator deleted',
          ),
        ),
      );
    }
  }

  void _copyCode(BuildContext context, String secret) {
    final state = context.read<AuthenticatorBloc>().state;
    final code = state.codes[secret];
    if (code != null) {
      Clipboard.setData(ClipboardData(text: code));
      context.read<AuthenticatorBloc>().add(CopyCode(secret));

      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.codeCopied ?? 'Code copied to clipboard'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }
}

/// Stylish circular FAB with gradient, shadow, and scale animation on press
class _AnimatedFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedFAB({required this.onPressed});

  @override
  State<_AnimatedFAB> createState() => _AnimatedFABState();
}

class _AnimatedFABState extends State<_AnimatedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.forward();

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.tertiary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: colorScheme.tertiary.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
            ],
          ),
          child: const Icon(
            Icons.add_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
