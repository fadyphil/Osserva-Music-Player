import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:music_player/features/playlists/data/models/playlist_model.dart';

abstract class PlaylistLocalDataSource {
  Future<PlaylistModel> createPlaylist({
    required String name,
    required String description,
    String? imagePath,
  });

  Future<void> deletePlaylist(int id);

  Future<PlaylistModel> editPlaylist({
    required int id,
    String? name,
    String? description,
    String? imagePath,
  });

  Future<void> addSongToPlaylist({
    required int playlistId,
    required int songId,
    required int durationMs,
  });

  Future<void> removeSongFromPlaylist({
    required int playlistId,
    required int songId,
  });

  Future<void> removeSongFromAllPlaylists(int songId);

  Future<List<PlaylistModel>> getPlaylists();

  Future<List<int>> getPlaylistSongIds(int playlistId);
}

class PlaylistLocalDataSourceImpl implements PlaylistLocalDataSource {
  static Database? _db;
  static const String _dbName = 'playlists.db';
  static const String _tablePlaylists = 'playlists';
  static const String _tablePlaylistSongs = 'playlist_songs';

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
          CREATE TABLE $_tablePlaylists (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            image_path TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_tablePlaylistSongs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            playlist_id INTEGER NOT NULL,
            song_id INTEGER NOT NULL,
            duration INTEGER DEFAULT 0,
            added_at INTEGER NOT NULL,
            FOREIGN KEY (playlist_id) REFERENCES $_tablePlaylists (id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
          'CREATE INDEX idx_playlist_id ON $_tablePlaylistSongs (playlist_id)',
        );
      },
    );
  }

  @override
  Future<PlaylistModel> createPlaylist({
    required String name,
    required String description,
    String? imagePath,
  }) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;

    final id = await database.insert(_tablePlaylists, {
      'name': name,
      'description': description,
      'image_path': imagePath,
      'created_at': now,
      'updated_at': now,
    });

    return PlaylistModel(
      id: id,
      name: name,
      description: description,
      imagePath: imagePath,
      createdAt: now,
      updatedAt: now,
      totalSongs: 0,
      totalDurationSeconds: 0,
      songIds: [],
    );
  }

  @override
  Future<void> deletePlaylist(int id) async {
    final database = await db;
    await database.delete(_tablePlaylists, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<PlaylistModel> editPlaylist({
    required int id,
    String? name,
    String? description,
    String? imagePath,
  }) async {
    final database = await db;
    final now = DateTime.now().millisecondsSinceEpoch;

    final Map<String, dynamic> values = {'updated_at': now};
    if (name != null) values['name'] = name;
    if (description != null) values['description'] = description;
    if (imagePath != null) values['image_path'] = imagePath;

    await database.update(
      _tablePlaylists,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );

    // Fetch updated
    final maps = await database.query(
      _tablePlaylists,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) throw Exception('Playlist not found');

    // We need to fetch stats to return a complete model
    return _getPlaylistWithStats(PlaylistModel.fromJson(maps.first));
  }

  @override
  Future<void> addSongToPlaylist({
    required int playlistId,
    required int songId,
    required int durationMs,
  }) async {
    final database = await db;
    // Check duplication? usually playlists allow duplicates, but let's assume unique for now or allow it.
    // Let's allow duplicates as standard.

    await database.insert(_tablePlaylistSongs, {
      'playlist_id': playlistId,
      'song_id': songId,
      'duration': durationMs,
      'added_at': DateTime.now().millisecondsSinceEpoch,
    });

    // Update updated_at
    await database.update(
      _tablePlaylists,
      {'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [playlistId],
    );
  }

  @override
  Future<void> removeSongFromPlaylist({
    required int playlistId,
    required int songId,
  }) async {
    final database = await db;
    // Remove ONE instance of the song? Or all? Usually one.
    // SQLite delete removes all matching rows.
    // If we support duplicates, we need to delete by row ID or limit 1.
    // 'DELETE FROM table WHERE ... LIMIT 1' is not standard SQL but SQLite supports it if compiled with it.
    // Safer: Select ID of one, then delete.

    final List<Map<String, dynamic>> rows = await database.query(
      _tablePlaylistSongs,
      columns: ['id'],
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
      limit: 1,
    );

    if (rows.isNotEmpty) {
      final id = rows.first['id'] as int;
      await database.delete(
        _tablePlaylistSongs,
        where: 'id = ?',
        whereArgs: [id],
      );

      // Update updated_at
      await database.update(
        _tablePlaylists,
        {'updated_at': DateTime.now().millisecondsSinceEpoch},
        where: 'id = ?',
        whereArgs: [playlistId],
      );
    }
  }

  @override
  Future<void> removeSongFromAllPlaylists(int songId) async {
    final database = await db;
    // We need to find which playlists had this song to update their updated_at
    final affectedPlaylists = await database.query(
      _tablePlaylistSongs,
      columns: ['playlist_id'],
      where: 'song_id = ?',
      whereArgs: [songId],
    );

    if (affectedPlaylists.isNotEmpty) {
      final playlistIds = affectedPlaylists.map((e) => e['playlist_id'] as int).toSet();

      await database.delete(
        _tablePlaylistSongs,
        where: 'song_id = ?',
        whereArgs: [songId],
      );

      // Update updated_at for all affected playlists
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final id in playlistIds) {
        await database.update(
          _tablePlaylists,
          {'updated_at': now},
          where: 'id = ?',
          whereArgs: [id],
        );
      }
    }
  }

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    final database = await db;

    // Get all playlists
    final playlistMaps = await database.query(
      _tablePlaylists,
      orderBy: 'updated_at DESC',
    );

    // Get stats for all
    // Can be done with a GROUP BY join
    final stats = await database.rawQuery('''
      SELECT 
        playlist_id, 
        COUNT(*) as count, 
        SUM(duration) as total_duration 
      FROM $_tablePlaylistSongs 
      GROUP BY playlist_id
    ''');

    final Map<int, Map<String, int>> statsMap = {};
    for (var row in stats) {
      statsMap[row['playlist_id'] as int] = {
        'count': row['count'] as int,
        'total_duration':
            (row['total_duration'] as int? ?? 0) ~/ 1000, // Convert ms to s
      };
    }

    return playlistMaps.map((map) {
      final model = PlaylistModel.fromJson(map);
      final id = model.id;
      final s = statsMap[id] ?? {'count': 0, 'total_duration': 0};
      return model.copyWith(
        totalSongs: s['count']!,
        totalDurationSeconds: s['total_duration']!,
      );
    }).toList();
  }

  @override
  Future<List<int>> getPlaylistSongIds(int playlistId) async {
    final database = await db;
    final result = await database.query(
      _tablePlaylistSongs,
      columns: ['song_id'],
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
      orderBy: 'added_at ASC',
    );

    return result.map((e) => e['song_id'] as int).toList();
  }

  Future<PlaylistModel> _getPlaylistWithStats(PlaylistModel model) async {
    final database = await db;
    final stats = await database.rawQuery(
      '''
      SELECT 
        COUNT(*) as count, 
        SUM(duration) as total_duration 
      FROM $_tablePlaylistSongs 
      WHERE playlist_id = ?
    ''',
      [model.id],
    );

    final row = stats.first;
    return model.copyWith(
      totalSongs: row['count'] as int,
      totalDurationSeconds: (row['total_duration'] as int? ?? 0) ~/ 1000,
    );
  }
}
