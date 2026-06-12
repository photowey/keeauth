import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:keeauth/core/storage/database_helper.dart';
import 'package:keeauth/features/authenticator/domain/entities/icon_pack.dart';

/// Service for managing authenticator icons
class IconService {
  static final IconService _instance = IconService._internal();
  factory IconService() => _instance;
  IconService._internal();

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final Map<String, String> _iconAliases = {};
  final Map<String, IconPackEntry> _iconCache = {};
  bool _initialized = false;

  /// Default icon path when no match found
  static const String defaultIconPath = 'assets/icons/key.png';

  /// Initialize icon service - load metadata and populate database
  Future<void> initialize() async {
    if (_initialized) return;

    await _loadIconMetadata();
    await _initializeIconPack();
    _initialized = true;
  }

  /// Load icon metadata from JSON
  Future<void> _loadIconMetadata() async {
    try {
      final jsonString = await rootBundle.loadString('assets/icons/metadata.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final aliases = json['aliases'] as Map<String, dynamic>;

      _iconAliases.clear();
      for (final entry in aliases.entries) {
        _iconAliases[entry.key] = entry.value as String;
      }
    } catch (e) {
    }
  }

  /// Initialize built-in icon pack in database
  Future<void> _initializeIconPack() async {
    final db = await _databaseHelper.database;

    // Check if built-in pack already exists
    final existing = await db.query(
      'icon_pack',
      where: 'id = ?',
      whereArgs: ['builtin'],
    );

    if (existing.isNotEmpty) {
      // Already initialized
      return;
    }

    // Create built-in icon pack
    final pack = IconPack(
      id: 'builtin',
      name: 'Default',
      version: 1,
      isBuiltin: true,
      createdAt: DateTime.now(),
    );

    await db.insert('icon_pack', pack.toMap());

    // Get list of all icon files from assets
    await _populateIconEntries(db, pack.id);
  }

  /// Populate icon entries from asset manifest
  Future<void> _populateIconEntries(dynamic db, String packId) async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final manifest = jsonDecode(manifestContent) as Map<String, dynamic>;

      // Filter icon files
      final iconPaths = manifest.keys
          .where((path) => path.startsWith('assets/icons/') && path.endsWith('.png'))
          .toList();

      for (final path in iconPaths) {
        final fileName = path.split('/').last;
        final name = fileName.replaceAll('.png', '');

        // Skip metadata file
        if (name == 'metadata') continue;

        final entry = IconPackEntry(
          id: 'builtin_$name',
          packId: packId,
          name: _normalizeIconName(name),
          assetPath: path,
          aliases: _getAliasesForName(name),
        );

        await db.insert('icon_pack_entry', entry.toMap());
      }
    } catch (e) {
    }
  }

  /// Normalize icon name for matching
  String _normalizeIconName(String name) {
    return name.toLowerCase()
        .replaceAll('_dark', '')
        .replaceAll('_light', '');
  }

  /// Get aliases for an icon name
  List<String> _getAliasesForName(String name) {
    final normalized = _normalizeIconName(name);
    final aliases = <String>[];

    for (final entry in _iconAliases.entries) {
      if (entry.value == normalized) {
        aliases.add(entry.key);
      }
    }

    return aliases;
  }

  /// Normalize issuer name for icon matching
  String normalizeIssuer(String issuer) {
    var normalized = issuer.toLowerCase().trim();

    // Remove special characters
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9]'), '');

    // Remove common prefixes
    normalized = normalized.replaceAll(RegExp(r'^(the|my)'), '');

    return normalized;
  }

  /// Get icon path for issuer name
  Future<String> getIconPathForIssuer(String issuer) async {
    if (!_initialized) {
      await initialize();
    }

    final normalizedIssuer = normalizeIssuer(issuer);

    // Check cache first
    if (_iconCache.containsKey(normalizedIssuer)) {
      return _iconCache[normalizedIssuer]!.assetPath;
    }

    // Try direct match
    final db = await _databaseHelper.database;
    var result = await db.query(
      'icon_pack_entry',
      where: 'name = ?',
      whereArgs: [normalizedIssuer],
    );

    // Try alias match
    if (result.isEmpty && _iconAliases.containsKey(normalizedIssuer)) {
      final aliasedName = _iconAliases[normalizedIssuer];
      result = await db.query(
        'icon_pack_entry',
        where: 'name = ?',
        whereArgs: [aliasedName],
      );
    }

    // Try partial match (e.g., "googlecloud" -> "google")
    if (result.isEmpty) {
      final allEntries = await db.query('icon_pack_entry');
      for (final entry in allEntries) {
        final name = entry['name'] as String;
        if (normalizedIssuer.contains(name) || name.contains(normalizedIssuer)) {
          result = [entry];
          break;
        }
      }
    }

    if (result.isNotEmpty) {
      final entry = IconPackEntry.fromMap(result.first);
      _iconCache[normalizedIssuer] = entry;
      return entry.assetPath;
    }

    return defaultIconPath;
  }

  /// Get icon widget for issuer
  Future<Widget> getIconForIssuer(
    String issuer, {
    double size = 40,
    BorderRadius? borderRadius,
  }) async {
    final path = await getIconPathForIssuer(issuer);
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(size / 4),
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackIcon(size);
        },
      ),
    );
  }

  /// Build fallback icon when image fails to load
  Widget _buildFallbackIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Icon(
        Icons.security,
        size: size * 0.5,
        color: Colors.grey[600],
      ),
    );
  }

  /// Search icons by query
  Future<List<IconPackEntry>> searchIcons(String query) async {
    if (!_initialized) {
      await initialize();
    }

    if (query.isEmpty) {
      return getAllIcons();
    }

    final normalizedQuery = query.toLowerCase().trim();
    final db = await _databaseHelper.database;

    // Search by name or aliases
    final results = await db.query(
      'icon_pack_entry',
      where: 'name LIKE ? OR aliases LIKE ?',
      whereArgs: ['%$normalizedQuery%', '%$normalizedQuery%'],
    );

    return results.map((r) => IconPackEntry.fromMap(r)).toList();
  }

  /// Get all available icons
  Future<List<IconPackEntry>> getAllIcons() async {
    if (!_initialized) {
      await initialize();
    }

    final db = await _databaseHelper.database;
    final results = await db.query('icon_pack_entry', orderBy: 'name ASC');
    return results.map((r) => IconPackEntry.fromMap(r)).toList();
  }

  /// Clear icon cache
  void clearCache() {
    _iconCache.clear();
  }
}

/// Model for icon pack item (legacy support)
class IconPackItem {
  final String name;
  final IconData icon;
  final Color color;
  final String? customPath;

  const IconPackItem({
    required this.name,
    required this.icon,
    required this.color,
    this.customPath,
  });

  bool get isCustom => customPath != null;
}
