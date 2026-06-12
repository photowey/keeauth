import 'dart:typed_data';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:keeauth/core/storage/database_helper.dart';

/// Repository for managing custom icons
class CustomIconRepository {
  final DatabaseHelper _databaseHelper;

  CustomIconRepository(this._databaseHelper);

  /// Get all custom icons
  Future<List<CustomIcon>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query('custom_icon', orderBy: 'createdAt DESC');
    return maps.map((m) => CustomIcon.fromMap(m)).toList();
  }

  /// Get custom icon by ID
  Future<CustomIcon?> getById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'custom_icon',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return CustomIcon.fromMap(maps.first);
  }

  /// Insert custom icon
  Future<void> insert(CustomIcon icon) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'custom_icon',
      icon.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Delete custom icon
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'custom_icon',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if icon is used by any authenticator
  Future<bool> isUsed(String id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'authenticator',
      where: 'icon = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  /// Delete unused icons
  Future<void> deleteUnused() async {
    final db = await _databaseHelper.database;
    await db.rawDelete('''
      DELETE FROM custom_icon
      WHERE id NOT IN (SELECT DISTINCT icon FROM authenticator WHERE icon IS NOT NULL)
    ''');
  }

  /// Get count
  Future<int> count() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM custom_icon');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}

/// Custom icon entity
class CustomIcon {
  final String id;
  final Uint8List data;
  final DateTime createdAt;

  CustomIcon({
    required this.id,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory CustomIcon.fromMap(Map<String, dynamic> map) {
    return CustomIcon(
      id: map['id'] as String,
      data: map['data'] as Uint8List,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }
}
