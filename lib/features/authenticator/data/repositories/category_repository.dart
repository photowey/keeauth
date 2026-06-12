import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:keeauth/features/authenticator/domain/entities/category.dart';
import 'package:keeauth/core/storage/database_helper.dart';

/// Repository for managing category data
class CategoryRepository {
  final DatabaseHelper _databaseHelper;

  CategoryRepository(this._databaseHelper);

  /// Get all categories
  Future<List<Category>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'category',
      orderBy: 'ranking ASC, name ASC',
    );
    return maps.map((m) => Category.fromMap(m)).toList();
  }

  /// Get category by ID
  Future<Category?> getById(String id) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'category',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Get category by name
  Future<Category?> getByName(String name) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'category',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Insert category
  Future<void> insert(Category category) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'category',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  /// Update category
  Future<void> update(Category category) async {
    final db = await _databaseHelper.database;
    await db.update(
      'category',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Delete category
  Future<void> delete(String id) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'category',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Check if category exists
  Future<bool> exists(String id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'category',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty;
  }

  /// Check if name exists
  Future<bool> nameExists(String name) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'category',
      where: 'name = ?',
      whereArgs: [name],
    );
    return result.isNotEmpty;
  }

  /// Get count
  Future<int> count() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM category');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Get authenticator count in category
  Future<int> getAuthenticatorCount(String categoryId) async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM authenticator_category
      WHERE categoryId = ?
    ''', [categoryId]);
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
