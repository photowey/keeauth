import 'package:equatable/equatable.dart';

/// Icon pack entity representing a collection of icons
class IconPack extends Equatable {
  final String id;
  final String name;
  final int version;
  final bool isBuiltin;
  final DateTime createdAt;

  const IconPack({
    required this.id,
    required this.name,
    this.version = 1,
    this.isBuiltin = true,
    required this.createdAt,
  });

  IconPack copyWith({
    String? id,
    String? name,
    int? version,
    bool? isBuiltin,
    DateTime? createdAt,
  }) {
    return IconPack(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      isBuiltin: isBuiltin ?? this.isBuiltin,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'version': version,
      'isBuiltin': isBuiltin ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory IconPack.fromMap(Map<String, dynamic> map) {
    return IconPack(
      id: map['id'] as String,
      name: map['name'] as String,
      version: map['version'] as int? ?? 1,
      isBuiltin: (map['isBuiltin'] as int? ?? 1) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  @override
  List<Object?> get props => [id, name, version, isBuiltin, createdAt];
}

/// Icon pack entry entity representing a single icon
class IconPackEntry extends Equatable {
  final String id;
  final String packId;
  final String name;
  final List<String> aliases;
  final String assetPath;

  const IconPackEntry({
    required this.id,
    required this.packId,
    required this.name,
    this.aliases = const [],
    required this.assetPath,
  });

  IconPackEntry copyWith({
    String? id,
    String? packId,
    String? name,
    List<String>? aliases,
    String? assetPath,
  }) {
    return IconPackEntry(
      id: id ?? this.id,
      packId: packId ?? this.packId,
      name: name ?? this.name,
      aliases: aliases ?? this.aliases,
      assetPath: assetPath ?? this.assetPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packId': packId,
      'name': name,
      'aliases': aliases.join(','),
      'assetPath': assetPath,
    };
  }

  factory IconPackEntry.fromMap(Map<String, dynamic> map) {
    final aliasesStr = map['aliases'] as String? ?? '';
    return IconPackEntry(
      id: map['id'] as String,
      packId: map['packId'] as String,
      name: map['name'] as String,
      aliases: aliasesStr.isEmpty ? [] : aliasesStr.split(','),
      assetPath: map['assetPath'] as String,
    );
  }

  @override
  List<Object?> get props => [id, packId, name, aliases, assetPath];
}
