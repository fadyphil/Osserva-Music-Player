import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AnalyticsDatabase {
  static Database? _database;
  static const String _dbName = 'music_analytics.db';
  static const int _version = 2; // Bumped version

  // Table Names
  static const String tblArtists = 'artists';
  static const String tblAlbums = 'albums';
  static const String tblGenres = 'genres';
  static const String tblSongs = 'songs';
  static const String tblPlaybackLogs = 'playback_logs'; // Hot Data
  static const String tblDailyAggregates = 'daily_aggregates'; // Cold Data

  // Singleton accessor
  Future<Database> get db async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onConfigure: (db) async {
        // Enable Foreign Keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createV2Schema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _migrateV1toV2(db);
        }
      },
    );
  }

  Future<void> _createV2Schema(DatabaseExecutor db) async {
    // 1. Dimensions
    await db.execute(
      'CREATE TABLE $tblArtists (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
    );
    await db.execute(
      'CREATE TABLE $tblAlbums (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
    );
    await db.execute(
      'CREATE TABLE $tblGenres (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
    );

    // 2. Song Metadata (Slow Changing Dimension)
    await db.execute('''
      CREATE TABLE $tblSongs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        source_id INTEGER, -- Original ID from MediaStore
        title TEXT,
        artist_id INTEGER REFERENCES $tblArtists(id),
        album_id INTEGER REFERENCES $tblAlbums(id),
        genre_id INTEGER REFERENCES $tblGenres(id)
      )
    ''');
    // Index source_id for fast lookups during insertion
    await db.execute('CREATE INDEX idx_songs_source ON $tblSongs (source_id)');

    // 3. Fact Table: Hot Logs (Recent detailed history)
    await db.execute('''
      CREATE TABLE $tblPlaybackLogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER REFERENCES $tblSongs(id),
        timestamp INTEGER,
        duration_listened INTEGER,
        is_completed INTEGER,
        time_of_day TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_logs_timestamp ON $tblPlaybackLogs (timestamp)',
    );

    // 4. Fact Table: Cold Aggregates (Daily Roll-ups)
    await db.execute('''
      CREATE TABLE $tblDailyAggregates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_epoch INTEGER, -- Midnight timestamp of the day
        song_id INTEGER REFERENCES $tblSongs(id),
        play_count INTEGER,
        total_duration INTEGER,
        time_of_day TEXT,
        UNIQUE(date_epoch, song_id, time_of_day)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_agg_date ON $tblDailyAggregates (date_epoch)',
    );
  }

  /// CRITICAL: Migration logic
  Future<void> _migrateV1toV2(Database db) async {
    await db.transaction((txn) async {
      // 1. Rename old table
      await txn.execute('ALTER TABLE playback_logs RENAME TO playback_logs_v1');

      // 2. Create new Schema
      await _createV2Schema(txn);

      // 3. Extract Dimensions (Artists, Albums, Genres)
      await txn.execute('''
        INSERT OR IGNORE INTO $tblArtists (name) 
        SELECT DISTINCT artist FROM playback_logs_v1 WHERE artist IS NOT NULL
      ''');
      await txn.execute('''
        INSERT OR IGNORE INTO $tblAlbums (name) 
        SELECT DISTINCT album FROM playback_logs_v1 WHERE album IS NOT NULL
      ''');
      await txn.execute('''
        INSERT OR IGNORE INTO $tblGenres (name) 
        SELECT DISTINCT genre FROM playback_logs_v1 WHERE genre IS NOT NULL
      ''');

      // 4. Extract Songs & Map to Dimensions
      // We group by song_id (source) to ensure uniqueness in the song table
      await txn.execute('''
        INSERT INTO $tblSongs (source_id, title, artist_id, album_id, genre_id)
        SELECT 
          v1.song_id, 
          MAX(v1.title), 
          ar.id, 
          al.id, 
          g.id
        FROM playback_logs_v1 v1
        LEFT JOIN $tblArtists ar ON v1.artist = ar.name
        LEFT JOIN $tblAlbums al ON v1.album = al.name
        LEFT JOIN $tblGenres g ON v1.genre = g.name
        GROUP BY v1.song_id
      ''');

      // 5. Migrate Logs (Mapping to new song_id FKs)
      await txn.execute('''
        INSERT INTO $tblPlaybackLogs (song_id, timestamp, duration_listened, is_completed, time_of_day)
        SELECT 
          s.id, 
          v1.timestamp, 
          v1.duration_listened, 
          v1.is_completed, 
          v1.time_of_day
        FROM playback_logs_v1 v1
        JOIN $tblSongs s ON v1.song_id = s.source_id
      ''');

      // 6. Cleanup
      await txn.execute('DROP TABLE playback_logs_v1');
    });
  }
}
