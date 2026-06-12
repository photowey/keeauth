import 'package:sqflite_sqlcipher/sqflite.dart';
import 'package:keeauth/features/authenticator/domain/entities/authenticator.dart';
import 'package:keeauth/core/storage/database_helper.dart';

/// Repository for managing authenticator data
class AuthenticatorRepository {
  final DatabaseHelper _databaseHelper;

  AuthenticatorRepository(this._databaseHelper);

  /// Get all authenticators
  Future<List<Authenticator>> getAll() async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'authenticator',
      orderBy: 'ranking ASC, createdAt DESC',
    );

    final authenticators = <Authenticator>[];
    for (final map in maps) {
      final categoryIds = await _getCategoryIds(map['secret'] as String);
      authenticators.add(Authenticator.fromMap(map, categoryIds: categoryIds));
    }
    return authenticators;
  }

  /// Get authenticator by secret
  Future<Authenticator?> getBySecret(String secret) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'authenticator',
      where: 'secret = ?',
      whereArgs: [secret],
    );

    if (maps.isEmpty) return null;

    final categoryIds = await _getCategoryIds(secret);
    return Authenticator.fromMap(maps.first, categoryIds: categoryIds);
  }

  /// Insert authenticator
  Future<void> insert(Authenticator authenticator) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'authenticator',
      authenticator.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Insert category relationships
    await _updateCategoryRelationships(authenticator.secret, authenticator.categoryIds);
  }

  /// Update authenticator
  Future<void> update(Authenticator authenticator) async {
    final db = await _databaseHelper.database;
    await db.update(
      'authenticator',
      authenticator.toMap(),
      where: 'secret = ?',
      whereArgs: [authenticator.secret],
    );

    // Update category relationships
    await _updateCategoryRelationships(authenticator.secret, authenticator.categoryIds);
  }

  /// Delete authenticator
  Future<void> delete(String secret) async {
    final db = await _databaseHelper.database;
    await db.delete(
      'authenticator',
      where: 'secret = ?',
      whereArgs: [secret],
    );
  }

  /// Get authenticators by category
  Future<List<Authenticator>> getByCategory(String categoryId) async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT a.* FROM authenticator a
      INNER JOIN authenticator_category ac ON a.secret = ac.authenticatorSecret
      WHERE ac.categoryId = ?
      ORDER BY a.ranking ASC, a.createdAt DESC
    ''', [categoryId]);

    final authenticators = <Authenticator>[];
    for (final map in maps) {
      final categoryIds = await _getCategoryIds(map['secret'] as String);
      authenticators.add(Authenticator.fromMap(map, categoryIds: categoryIds));
    }
    return authenticators;
  }

  /// Get uncategorized authenticators
  Future<List<Authenticator>> getUncategorized() async {
    final db = await _databaseHelper.database;
    final maps = await db.rawQuery('''
      SELECT a.* FROM authenticator a
      WHERE NOT EXISTS (
        SELECT 1 FROM authenticator_category ac WHERE ac.authenticatorSecret = a.secret
      )
      ORDER BY a.ranking ASC, a.createdAt DESC
    ''');

    final authenticators = <Authenticator>[];
    for (final map in maps) {
      final categoryIds = await _getCategoryIds(map['secret'] as String);
      authenticators.add(Authenticator.fromMap(map, categoryIds: categoryIds));
    }
    return authenticators;
  }

  /// Check if authenticator exists
  Future<bool> exists(String secret) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'authenticator',
      where: 'secret = ?',
      whereArgs: [secret],
    );
    return result.isNotEmpty;
  }

  /// Get category IDs for an authenticator
  Future<List<String>> _getCategoryIds(String secret) async {
    final db = await _databaseHelper.database;
    final maps = await db.query(
      'authenticator_category',
      columns: ['categoryId'],
      where: 'authenticatorSecret = ?',
      whereArgs: [secret],
    );
    return maps.map((m) => m['categoryId'] as String).toList();
  }

  /// Update category relationships
  Future<void> _updateCategoryRelationships(String secret, List<String> categoryIds) async {
    final db = await _databaseHelper.database;

    // Delete existing relationships
    await db.delete(
      'authenticator_category',
      where: 'authenticatorSecret = ?',
      whereArgs: [secret],
    );

    // Insert new relationships
    for (final categoryId in categoryIds) {
      await db.insert(
        'authenticator_category',
        {
          'authenticatorSecret': secret,
          'categoryId': categoryId,
        },
      );
    }
  }

  /// Increment copy count
  Future<void> incrementCopyCount(String secret) async {
    final db = await _databaseHelper.database;
    await db.rawUpdate('''
      UPDATE authenticator
      SET copyCount = copyCount + 1, updatedAt = ?
      WHERE secret = ?
    ''', [DateTime.now().millisecondsSinceEpoch, secret]);
  }

  /// Update ranking (for drag and drop)
  Future<void> updateRanking(String secret, int ranking) async {
    final db = await _databaseHelper.database;
    await db.update(
      'authenticator',
      {'ranking': ranking, 'updatedAt': DateTime.now().millisecondsSinceEpoch},
      where: 'secret = ?',
      whereArgs: [secret],
    );
  }

  /// Get count
  Future<int> count() async {
    final db = await _databaseHelper.database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM authenticator');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
