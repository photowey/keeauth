import 'package:flutter/material.dart';
import 'package:keeauth/l10n/app_localizations.dart';

/// AppBar with search functionality
class SearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearching;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchClear;
  final List<Widget>? actions;

  const SearchAppBar({
    super.key,
    required this.title,
    required this.isSearching,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.onSearchToggle,
    required this.onSearchClear,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant SearchAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchController.text != widget.searchQuery) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.isSearching) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onSearchToggle,
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n?.searchAuthenticators ?? 'Search authenticators...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Theme.of(context).hintColor),
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onChanged: widget.onSearchChanged,
        ),
        actions: [
          if (widget.searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                widget.onSearchClear();
              },
            ),
        ],
      );
    }

    return AppBar(
      title: Text(widget.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: widget.onSearchToggle,
        ),
        ...?widget.actions,
      ],
    );
  }
}

/// Mixin for handling search functionality with debouncing
mixin SearchMixin<T extends StatefulWidget> on State<T> {
  String _searchQuery = '';
  bool _isSearching = false;
  DateTime? _lastSearchTime;

  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        onSearchChanged('');
      }
    });
  }

  void clearSearch() {
    setState(() {
      _searchQuery = '';
    });
    onSearchChanged('');
  }

  void onSearchChanged(String query) {
    final now = DateTime.now();
    _lastSearchTime = now;

    // Debounce: wait 300ms before applying search
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _lastSearchTime == now) {
        setState(() {
          _searchQuery = query.toLowerCase().trim();
        });
        applySearch(_searchQuery);
      }
    });
  }

  void applySearch(String query);
}

/// Widget for highlighting search matches in text
class HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow? overflow;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty) {
      return Text(text, style: style, maxLines: maxLines, overflow: overflow);
    }

    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();
    final spans = <TextSpan>[];

    var start = 0;
    while (true) {
      final index = lowerText.indexOf(lowerHighlight, start);
      if (index == -1) break;

      // Add text before match
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index), style: style));
      }

      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + highlight.length),
          style:
              highlightStyle ??
              style?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
      );

      start = index + highlight.length;
    }

    // Add remaining text
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style: style));
    }

    return RichText(
      text: TextSpan(children: spans, style: style),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}
