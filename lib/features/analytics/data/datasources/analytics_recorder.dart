import 'dart:async';
import 'dart:developer';
import 'package:sqflite/sqflite.dart';

import '../../domain/entities/play_log.dart';
import 'db/analytics_database.dart';

class AnalyticsRecorder {
  final AnalyticsDatabase _dbProvider;
  final _logController = StreamController<void>.broadcast();

  // Simple in-memory cache to reduce DB reads for repetitive dimensions
  // Key: "table_name:value_name", Value: id
  final Map<String, int> _idCache = {};

  AnalyticsRecorder(this._dbProvider);

  Stream<void> get onLogStream => _logController.stream;

  Future<void> logEvent(PlayLog log) async {
    final db = await _dbProvider.db;

    await db.transaction((txn) async {
      // 1. Ensure Dimensions exist and get IDs
      int artistId = await _getOrInsertId(
        txn,
        AnalyticsDatabase.tblArtists,
        log.artist,
      );
      int albumId = await _getOrInsertId(
        txn,
        AnalyticsDatabase.tblAlbums,
        log.album,
      );
      int genreId = await _getOrInsertId(
        txn,
        AnalyticsDatabase.tblGenres,
        log.genre,
      );

      // 2. Ensure Song exists
      // We check if this source_id already exists in our internal map
      // Note: We don't cache song IDs yet as they depend on other IDs,
      // but the dimensions are the heaviest repeated reads.
      final songQuery = await txn.query(
        AnalyticsDatabase.tblSongs,
        columns: ['id'],
        where: 'source_id = ?',
        whereArgs: [log.songId],
        limit: 1,
      );

      int internalSongId;
      if (songQuery.isNotEmpty) {
        internalSongId = songQuery.first['id'] as int;
      } else {
        internalSongId = await txn.insert(AnalyticsDatabase.tblSongs, {
          'source_id': log.songId,
          'title': log.songTitle,
          'artist_id': artistId,
          'album_id': albumId,
          'genre_id': genreId,
        });
      }

      // 3. Insert or Update Log
      // Check last log to see if it's the same song
      final lastLogQuery = await txn.query(
        AnalyticsDatabase.tblPlaybackLogs,
        columns: ['id', 'song_id', 'play_count', 'duration_listened'],
        orderBy: 'id DESC',
        limit: 1,
      );

      bool isConsecutive = false;
      int? lastLogId;
      int currentPlayCount = 0;

      if (lastLogQuery.isNotEmpty) {
        final lastRow = lastLogQuery.first;
        final lastSongId = lastRow['song_id'] as int;
        final lastTimeStamp = (lastRow['timestamp'] as int?) ?? 0;
        final ageMs = DateTime.now().millisecondsSinceEpoch - lastTimeStamp;
        // Only consider consecutive if same song AND within the last 10 minutes

        if (lastSongId == internalSongId && ageMs < 10 * 60 * 1000) {
          isConsecutive = true;
          lastLogId = lastRow['id'] as int;
          currentPlayCount = (lastRow['play_count'] as int?) ?? 1;
        }
      }

      if (isConsecutive && lastLogId != null) {
        final existingDuration =
            (lastLogQuery.first['duration_listened'] as int?) ?? 0;
        // Update existing log
        await txn.update(
          AnalyticsDatabase.tblPlaybackLogs,
          {
            'timestamp': log.timestamp.millisecondsSinceEpoch,
            'duration_listened':
                existingDuration +
                log.durationListenedSeconds, //new comment: this accumalates the duration
            // old comment: Update duration if needed, or maybe accumulate?
            // Usually history shows the "play" event. unique duration might vary.
            // For now simply updating timestamp and count.
            'is_completed': log.isCompleted ? 1 : 0,
            'time_of_day': log.sessionTimeOfDay,
            'play_count': currentPlayCount + 1,
          },
          where: 'id = ?',
          whereArgs: [lastLogId],
        );
      } else {
        // Insert new log
        await txn.insert(AnalyticsDatabase.tblPlaybackLogs, {
          'song_id': internalSongId,
          'timestamp': log.timestamp.millisecondsSinceEpoch,
          'duration_listened': log.durationListenedSeconds,
          'is_completed': log.isCompleted ? 1 : 0,
          'play_count': 1,
          'time_of_day': log.sessionTimeOfDay,
        });
      }
    });

    _logController.add(null);
  }

  Future<int> _getOrInsertId(Transaction txn, String table, String name) async {
    final cacheKey = '$table:$name';
    if (_idCache.containsKey(cacheKey)) {
      return _idCache[cacheKey]!;
    }

    final results = await txn.query(
      table,
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name],
      limit: 1,
    );

    int id;
    if (results.isNotEmpty) {
      id = results.first['id'] as int;
    } else {
      id = await txn.insert(table, {'name': name});
    }

    _idCache[cacheKey] = id;
    return id;
  }

  Future<void> logOnboardingComplete() async {
    log('Analytics: Onboarding Completed');
  }

  Future<void> clearAllData() async {
    final db = await _dbProvider.db;
    await db.transaction((txn) async {
      await txn.delete(AnalyticsDatabase.tblPlaybackLogs);
      await txn.delete(AnalyticsDatabase.tblDailyAggregates);
      await txn.delete(AnalyticsDatabase.tblSongs);
      await txn.delete(AnalyticsDatabase.tblArtists);
      await txn.delete(AnalyticsDatabase.tblAlbums);
      await txn.delete(AnalyticsDatabase.tblGenres);
    });
    _idCache.clear();
    _logController.add(null);
  }

  Future<void> deleteSongLogs(int sourceSongId) async {
    final db = await _dbProvider.db;
    await db.transaction((txn) async {
      final songQuery = await txn.query(
        AnalyticsDatabase.tblSongs,
        columns: ['id'],
        where: 'source_id = ?',
        whereArgs: [sourceSongId],
        limit: 1,
      );

      if (songQuery.isNotEmpty) {
        final internalId = songQuery.first['id'] as int;
        await txn.delete(
          AnalyticsDatabase.tblPlaybackLogs,
          where: 'song_id = ?',
          whereArgs: [internalId],
        );
        await txn.delete(
          AnalyticsDatabase.tblDailyAggregates,
          where: 'song_id = ?',
          whereArgs: [internalId],
        );
        await txn.delete(
          AnalyticsDatabase.tblSongs,
          where: 'id = ?',
          whereArgs: [internalId],
        );
      }
    });
    _logController.add(null);
  }
}
