import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:keeauth/core/icons/icon_service.dart';
import 'package:keeauth/l10n/app_localizations.dart';
import 'package:keeauth/features/authenticator/domain/entities/icon_pack.dart';

/// Result type for icon selection
class IconSelectionResult {
  final String name;
  final String? assetPath;
  final String? customPath;
  final bool isCustom;

  const IconSelectionResult({
    required this.name,
    this.assetPath,
    this.customPath,
    this.isCustom = false,
  });
}

/// Widget for selecting an icon
class IconPickerSheet extends StatefulWidget {
  final String? initialName;

  const IconPickerSheet({super.key, this.initialName});

  @override
  State<IconPickerSheet> createState() => _IconPickerSheetState();
}

// Helper function to show the icon picker
Future<IconSelectionResult?> showIconPicker(
  BuildContext context, {
  String? initialName,
}) async {
  return showModalBottomSheet<IconSelectionResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => IconPickerSheet(initialName: initialName),
  );
}

class _IconPickerSheetState extends State<IconPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final IconService _iconService = IconService();
  final _uuid = const Uuid();

  List<IconPackEntry> _icons = [];
  List<IconPackEntry> _filteredIcons = [];
  bool _isLoading = true;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _loadIcons();
    if (widget.initialName != null) {
      _searchController.text = widget.initialName!;
    }
  }

  Future<void> _loadIcons() async {
    setState(() => _isLoading = true);

    try {
      await _iconService.initialize();
      final icons = await _iconService.getAllIcons();

      if (mounted) {
        setState(() {
          _icons = icons;
          _filteredIcons = icons;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n?.failedToLoadIcons ?? 'Failed to load icons'}: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredIcons = _icons;
      } else {
        final normalizedQuery = query.toLowerCase().trim();
        _filteredIcons =
            _icons.where((icon) {
              final nameMatch = icon.name.toLowerCase().contains(
                normalizedQuery,
              );
              final aliasMatch = icon.aliases.any(
                (alias) => alias.toLowerCase().contains(normalizedQuery),
              );
              return nameMatch || aliasMatch;
            }).toList();
      }
    });
  }

  Future<void> _pickCustomImage() async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 256,
        maxHeight: 256,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() => _isPickingImage = true);

        // Copy image to app directory
        final appDir = await getApplicationDocumentsDirectory();
        final customIconsDir = Directory('${appDir.path}/custom_icons');
        if (!await customIconsDir.exists()) {
          await customIconsDir.create(recursive: true);
        }

        final fileName = '${_uuid.v4()}.png';
        final savedPath = '${customIconsDir.path}/$fileName';

        await File(image.path).copy(savedPath);

        if (mounted) {
          Navigator.pop(context, savedPath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${l10n?.failedToPickImage ?? 'Failed to pick image'}: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n?.searchIcons ?? 'Select Icon',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n?.searchIcons ?? 'Search icons...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                      )
                      : null,
            ),
            onChanged: _search,
          ),
          const SizedBox(height: 16),
          // Add custom image button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isPickingImage ? null : _pickCustomImage,
              icon:
                  _isPickingImage
                      ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.add_photo_alternate),
              label: Text(l10n?.addCustomImage ?? 'Add Custom Image'),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredIcons.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n?.noResultsFound ?? 'No icons found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                    : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _filteredIcons.length,
                      itemBuilder: (context, index) {
                        final item = _filteredIcons[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pop(
                              context,
                              IconSelectionResult(
                                name: item.name,
                                assetPath: item.assetPath,
                                isCustom: false,
                              ),
                            );
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      item.assetPath,
                                      fit: BoxFit.contain,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey[400],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 4,
                                    right: 4,
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[700],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
