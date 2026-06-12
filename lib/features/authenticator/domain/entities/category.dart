import 'package:equatable/equatable.dart';

/// Category entity for organizing authenticators.
/// [color] is ARGB as int (e.g. 0xFF4CAF50). Null for legacy; UI can derive from id.
class Category extends Equatable {
  final String id;
  final String name;
  final int ranking;
  final DateTime createdAt;
  final DateTime updatedAt;
  /// ARGB int, or null for old data (UI uses deterministic color from id).
  final int? color;

  const Category({
    required this.id,
    required this.name,
    this.ranking = 0,
    required this.createdAt,
    required this.updatedAt,
    this.color,
  });

  Category copyWith({
    String? id,
    String? name,
    int? ranking,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      ranking: ranking ?? this.ranking,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
    );
  }

  /// Resolved ARGB for display: [color] if set, else stable from [id].
  int get displayColorInt {
    if (color != null) return color!;
    const palette = [
      0xFF4CAF50, 0xFF2196F3, 0xFFFF9800, 0xFF9C27B0,
      0xFF00BCD4, 0xFF795548, 0xFF607D8B, 0xFFE91E63,
    ];
    return palette[id.hashCode.abs() % palette.length];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ranking': ranking,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'color': color,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      ranking: map['ranking'] as int? ?? 0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
      color: map['color'] as int?,
    );
  }

  @override
  List<Object?> get props => [id, name, ranking, createdAt, updatedAt, color];
}
