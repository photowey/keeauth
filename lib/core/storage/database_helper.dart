import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';

class DatabaseHelper {
  static const String _databaseName = 'keeauth.db';
  static const String _encryptedDatabaseName = 'keeauth_encrypted.db';
  static const int _databaseVersion = 4;
  static const String _dbPasswordKey = 'db_encryption_key';

  static const List<String> _migrationTables = [
    'authenticator',
    'category',
    'authenticator_category',
    'custom_icon',
  ];

  Database? _database;
  Completer<Database>? _initCompleter; // Prevent concurrent initialization

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Wait for in-progress initialization
    if (_initCompleter != null) {
      return await _initCompleter!.future;
    }

    // Start new initialization
    _initCompleter = Completer<Database>();

    try {
      final db = await _initDatabase();
      _database = db;
      _initCompleter!.complete(db);
      return db;
    } catch (e) {
      _initCompleter!.completeError(e);
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbPath = join(documentsDirectory.path, _databaseName);
    final password = await _getOrCreatePassword();

    final needsMigration = await _isUnencryptedDatabase(dbPath);
    if (needsMigration) {
      await _migrateToEncrypted(documentsDirectory.path, password);
    }

    final db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      password: password,
    );

    return db;
  }

  String _generatePassword() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  Future<String> _getOrCreatePassword() async {
    String? password = await _secureStorage.read(key: _dbPasswordKey);
    if (password == null) {
      password = _generatePassword();
      await _secureStorage.write(key: _dbPasswordKey, value: password);
    }
    return password;
  }

  Future<bool> _isUnencryptedDatabase(String dbPath) async {
    final file = File(dbPath);
    if (!await file.exists()) return false;

    // Check the file header: plain SQLite starts with "SQLite format 3\0"
    try {
      final bytes = await file
          .openRead(0, 16)
          .fold<List<int>>([], (prev, chunk) => prev..addAll(chunk));
      if (bytes.length < 16) return false;
      const sqliteHeader = [
        0x53,
        0x51,
        0x4c,
        0x69,
        0x74,
        0x65,
        0x20,
        0x66,
        0x6f,
        0x72,
        0x6d,
        0x61,
        0x74,
        0x20,
        0x33,
        0x00,
      ];
      for (var i = 0; i < 16; i++) {
        if (bytes[i] != sqliteHeader[i]) return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _migrateToEncrypted(String dirPath, String password) async {
    final oldDbPath = join(dirPath, _databaseName);
    final newDbPath = join(dirPath, _encryptedDatabaseName);

    Database? oldDb;
    Database? newDb;

    try {
      oldDb = await openDatabase(oldDbPath, readOnly: true);

      final tableData = <String, List<Map<String, dynamic>>>{};
      for (final table in _migrationTables) {
        final exists = await _tableExists(oldDb, table);
        if (exists) {
          tableData[table] = await oldDb.query(table);
        }
      }

      newDb = await openDatabase(
        newDbPath,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        password: password,
      );

      for (final entry in tableData.entries) {
        for (final row in entry.value) {
          await newDb.insert(
            entry.key,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }

      for (final entry in tableData.entries) {
        final count = Sqflite.firstIntValue(
          await newDb.rawQuery('SELECT COUNT(*) FROM ${entry.key}'),
        );
        if (count != entry.value.length) {
          throw StateError(
            'Migration verification failed for ${entry.key}: '
            'expected ${entry.value.length}, got $count',
          );
        }
      }

      await oldDb.close();
      oldDb = null;
      await newDb.close();
      newDb = null;

      final oldFile = File(oldDbPath);
      await oldFile.delete();

      final newFile = File(newDbPath);
      await newFile.rename(oldDbPath);

    } catch (e) {
      if (oldDb != null) {
        try {
          await oldDb.close();
        } catch (_) {}
      }
      if (newDb != null) {
        try {
          await newDb.close();
        } catch (_) {}
      }

      final newFile = File(newDbPath);
      if (await newFile.exists()) {
        await newFile.delete();
      }

      rethrow;
    }
  }

  Future<bool> _tableExists(Database db, String table) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    return result.isNotEmpty;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE authenticator (
        secret TEXT PRIMARY KEY,
        issuer TEXT,
        accountName TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'totp',
        algorithm TEXT NOT NULL DEFAULT 'sha1',
        digits INTEGER NOT NULL DEFAULT 6,
        period INTEGER NOT NULL DEFAULT 30,
        counter INTEGER NOT NULL DEFAULT 0,
        icon TEXT,
        pin TEXT,
        copyCount INTEGER NOT NULL DEFAULT 0,
        ranking INTEGER NOT NULL DEFAULT 0,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE category (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        ranking INTEGER NOT NULL DEFAULT 0,
        color INTEGER,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE authenticator_category (
        authenticatorSecret TEXT NOT NULL,
        categoryId TEXT NOT NULL,
        PRIMARY KEY (authenticatorSecret, categoryId),
        FOREIGN KEY (authenticatorSecret) REFERENCES authenticator(secret) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES category(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_icon (
        id TEXT PRIMARY KEY,
        data BLOB NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE icon_pack (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        version INTEGER NOT NULL DEFAULT 1,
        isBuiltin INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE icon_pack_entry (
        id TEXT PRIMARY KEY,
        packId TEXT NOT NULL,
        name TEXT NOT NULL,
        aliases TEXT,
        assetPath TEXT NOT NULL,
        FOREIGN KEY (packId) REFERENCES icon_pack(id) ON DELETE CASCADE
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_authenticator_ranking ON authenticator(ranking)',
    );
    await db.execute('CREATE INDEX idx_category_ranking ON category(ranking)');
    await db.execute(
      'CREATE INDEX idx_authenticator_category_auth ON authenticator_category(authenticatorSecret)',
    );
    await db.execute(
      'CREATE INDEX idx_authenticator_category_cat ON authenticator_category(categoryId)',
    );
    await db.execute(
      'CREATE INDEX idx_icon_pack_entry_name ON icon_pack_entry(name)',
    );
    await db.execute(
      'CREATE INDEX idx_icon_pack_entry_pack ON icon_pack_entry(packId)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS icon_pack_entry');
      await db.execute('DROP TABLE IF EXISTS icon_pack');

      await db.execute('''
        CREATE TABLE icon_pack (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          version INTEGER NOT NULL DEFAULT 1,
          isBuiltin INTEGER NOT NULL DEFAULT 1,
          createdAt INTEGER NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE icon_pack_entry (
          id TEXT PRIMARY KEY,
          packId TEXT NOT NULL,
          name TEXT NOT NULL,
          aliases TEXT,
          assetPath TEXT NOT NULL,
          FOREIGN KEY (packId) REFERENCES icon_pack(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE category ADD COLUMN color INTEGER');
    }
    if (oldVersion < 4) {
      final info = await db.rawQuery('PRAGMA table_info(category)');
      final hasColor = info.any((row) => row['name'] == 'color');
      if (!hasColor) {
        await db.execute('ALTER TABLE category ADD COLUMN color INTEGER');
      }
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> deleteDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
