import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class FavoritesLocalDataSource {
  Future<void> addFavorite(int songId);
  Future<void> removeFavorite(int songId);
  Future<List<int>> getFavoriteIds();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  static Database? _db;
  static const String _dbName = 'favorites.db';
  static const String _tableName = 'favorites';

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            song_id INTEGER PRIMARY KEY,
            added_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  @override
  Future<void> addFavorite(int songId) async {
    final database = await db;
    await database.insert(
      _tableName,
      {
        'song_id': songId,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> removeFavorite(int songId) async {
    final database = await db;
    await database.delete(
      _tableName,
      where: 'song_id = ?',
      whereArgs: [songId],
    );
  }

  @override
  Future<List<int>> getFavoriteIds() async {
    final database = await db;
    final result = await database.query(
      _tableName,
      orderBy: 'added_at DESC', // Newest first
    );
    return result.map((e) => e['song_id'] as int).toList();
  }
}
