import 'package:osserva/features/analytics/data/datasources/db/analytics_database.dart';
import 'package:osserva/features/analytics/domain/entities/analytics_enums.dart';
import 'package:osserva/features/analytics/domain/entities/analytics_stats.dart';
import 'package:osserva/features/analytics/domain/entities/artist_stats.dart';
import 'package:osserva/features/analytics/domain/entities/play_log.dart';

class AnalyticsReader {
  final AnalyticsDatabase _dbProvider;

  AnalyticsReader(this._dbProvider);

  int _getTimestampThreshold(TimeFrame timeFrame) {
    final now = DateTime.now();
    switch (timeFrame) {
      case TimeFrame.day:
        // FIX: Use local midnight, not a rolling 24h window.
        //
        // The old implementation did now.subtract(Duration(days: 1)), which is
        // a floating window — "since exactly 24 hours ago". This broke the
        // "today" stat card: playing 1h at 11 PM and 1h at 1 AM both appeared
        // in the same window but showed incorrect totals when queried at
        // different times of day. Anchoring to local midnight (00:00 today)
        // makes TimeFrame.day mean "today so far" — deterministic regardless
        // of when the card is loaded.
        final midnight = DateTime(now.year, now.month, now.day);
        return midnight.millisecondsSinceEpoch;

      case TimeFrame.week:
        // Anchor to the most recent Monday 00:00 local time.
        final daysFromMonday = (now.weekday - 1) % 7;
        final monday = DateTime(now.year, now.month, now.day - daysFromMonday);
        return monday.millisecondsSinceEpoch;

      case TimeFrame.month:
        // Anchor to the 1st of the current month.
        final firstOfMonth = DateTime(now.year, now.month, 1);
        return firstOfMonth.millisecondsSinceEpoch;

      case TimeFrame.year:
        // Anchor to Jan 1 of the current year.
        final firstOfYear = DateTime(now.year, 1, 1);
        return firstOfYear.millisecondsSinceEpoch;

      case TimeFrame.all:
        return 0;
    }
  }

  /// Helper to generate the SQL that unions Hot Logs + Cold Aggregates.
  ///
  /// FIX: Hot data path now uses SUM(play_count) instead of COUNT(*).
  /// The recorder merges consecutive plays of the same song into one row and
  /// increments play_count (e.g. 5 loops = 1 row, play_count = 5). COUNT(*)
  /// was treating that as 1 play. SUM(play_count) correctly counts it as 5,
  /// consistent with the cold aggregate path which already used SUM(play_count).
  String _buildUnionQuery({
    required String innerSelect,
    required String innerGroupBy,
    required String outerSelect,
    required String outerGroupBy,
  }) {
    return '''
      SELECT $outerSelect, SUM(count_val) as value
      FROM (
        -- Hot Data
        SELECT $innerSelect, SUM(log.play_count) as count_val
        FROM ${AnalyticsDatabase.tblPlaybackLogs} log
        JOIN ${AnalyticsDatabase.tblSongs} s ON log.song_id = s.id
        JOIN ${AnalyticsDatabase.tblArtists} ar ON s.artist_id = ar.id
        JOIN ${AnalyticsDatabase.tblAlbums} al ON s.album_id = al.id
        JOIN ${AnalyticsDatabase.tblGenres} g ON s.genre_id = g.id
        WHERE log.timestamp > ?
        GROUP BY $innerGroupBy

        UNION ALL

        -- Cold Data
        SELECT $innerSelect, SUM(play_count) as count_val
        FROM ${AnalyticsDatabase.tblDailyAggregates} agg
        JOIN ${AnalyticsDatabase.tblSongs} s ON agg.song_id = s.id
        JOIN ${AnalyticsDatabase.tblArtists} ar ON s.artist_id = ar.id
        JOIN ${AnalyticsDatabase.tblAlbums} al ON s.album_id = al.id
        JOIN ${AnalyticsDatabase.tblGenres} g ON s.genre_id = g.id
        WHERE agg.date_epoch > ?
        GROUP BY $innerGroupBy
      )
      GROUP BY $outerGroupBy
      ORDER BY value DESC
      LIMIT ?
    ''';
  }

  Future<List<TopItem>> getTopSongs(TimeFrame timeFrame, int limit) async {
    final db = await _dbProvider.db;
    final threshold = _getTimestampThreshold(timeFrame);

    // FIX: SUM(log.play_count) instead of COUNT(*) in hot path.
    final sql =
        '''
      SELECT 
        CAST(s.source_id AS TEXT) as id,
        s.title as label, 
        ar.name as sub_label, 
        SUM(count_val) as value
      FROM (
        SELECT song_id, SUM(play_count) as count_val
        FROM ${AnalyticsDatabase.tblPlaybackLogs}
        WHERE timestamp > ?
        GROUP BY song_id

        UNION ALL

        SELECT song_id, SUM(play_count) as count_val
        FROM ${AnalyticsDatabase.tblDailyAggregates}
        WHERE date_epoch > ?
        GROUP BY song_id
      ) combined
      JOIN ${AnalyticsDatabase.tblSongs} s ON combined.song_id = s.id
      JOIN ${AnalyticsDatabase.tblArtists} ar ON s.artist_id = ar.id
      GROUP BY s.id
      ORDER BY value DESC
      LIMIT ?
    ''';

    final result = await db.rawQuery(sql, [threshold, threshold, limit]);
    return result
        .map((e) => TopItem.fromJson(e).copyWith(type: 'song'))
        .toList();
  }

  Future<List<TopItem>> getTopArtists(TimeFrame timeFrame, int limit) async {
    final db = await _dbProvider.db;
    final threshold = _getTimestampThreshold(timeFrame);

    final sql = _buildUnionQuery(
      innerSelect: 'ar.name as name',
      innerGroupBy: 'ar.name',
      outerSelect: 'name as id, name as label',
      outerGroupBy: 'name',
    );

    final result = await db.rawQuery(sql, [threshold, threshold, limit]);
    return result
        .map((e) => TopItem.fromJson(e).copyWith(type: 'artist'))
        .toList();
  }

  Future<List<TopItem>> getTopAlbums(TimeFrame timeFrame, int limit) async {
    final db = await _dbProvider.db;
    final threshold = _getTimestampThreshold(timeFrame);

    final sql = _buildUnionQuery(
      innerSelect: 'al.name as album_name, ar.name as artist_name',
      innerGroupBy: 'al.name',
      outerSelect:
          'album_name as id, album_name as label, artist_name as sub_label',
      outerGroupBy: 'album_name',
    );

    final result = await db.rawQuery(sql, [threshold, threshold, limit]);
    return result
        .map((e) => TopItem.fromJson(e).copyWith(type: 'album'))
        .toList();
  }

  Future<List<TopItem>> getTopGenres(TimeFrame timeFrame, int limit) async {
    final db = await _dbProvider.db;
    final threshold = _getTimestampThreshold(timeFrame);

    final sql = _buildUnionQuery(
      innerSelect: 'g.name as name',
      innerGroupBy: 'g.name',
      outerSelect: 'name as id, name as label',
      outerGroupBy: 'name',
    );

    final result = await db.rawQuery(sql, [threshold, threshold, limit]);
    return result
        .map((e) => TopItem.fromJson(e).copyWith(type: 'genre'))
        .toList();
  }

  Future<ListeningStats> getGeneralStats(TimeFrame timeFrame) async {
    final db = await _dbProvider.db;
    final threshold = _getTimestampThreshold(timeFrame);

    // FIX: Hot data play_count was COUNT(*), now SUM(play_count).
    // COUNT(*) = number of log rows. SUM(play_count) = actual play events,
    // because consecutive loops/replays of the same song merge into one row
    // with play_count incremented. Both paths now use SUM(play_count).
    final sql =
        '''
      SELECT 
        SUM(total_duration) as total_duration, 
        SUM(play_count) as total_count
      FROM (
        -- Hot Data
        SELECT 
          SUM(duration_listened) as total_duration, 
          SUM(play_count) as play_count 
        FROM ${AnalyticsDatabase.tblPlaybackLogs} 
        WHERE timestamp > ?
        
        UNION ALL
        
        -- Cold Data
        SELECT 
          SUM(total_duration) as total_duration, 
          SUM(play_count) as play_count 
        FROM ${AnalyticsDatabase.tblDailyAggregates} 
        WHERE date_epoch > ?
      )
    ''';

    final result = await db.rawQuery(sql, [threshold, threshold]);
    final row = result.first;
    final totalSeconds = row['total_duration'] as int? ?? 0;
    final totalCount = row['total_count'] as int? ?? 0;

    // FIX: Time of day — hot path uses SUM(play_count) instead of COUNT(*).
    // Also added 'evening' bucket (18:00–22:59) that was previously swallowed
    // by 'night'. The tracker classifies at log time; the reader just aggregates.
    final timeSql =
        '''
      SELECT time_of_day, SUM(cnt) as count
      FROM (
        SELECT time_of_day, SUM(play_count) as cnt 
        FROM ${AnalyticsDatabase.tblPlaybackLogs} 
        WHERE timestamp > ? 
        GROUP BY time_of_day
        
        UNION ALL
        
        SELECT time_of_day, SUM(play_count) as cnt 
        FROM ${AnalyticsDatabase.tblDailyAggregates} 
        WHERE date_epoch > ? 
        GROUP BY time_of_day
      )
      GROUP BY time_of_day
    ''';

    final timeResult = await db.rawQuery(timeSql, [threshold, threshold]);
    final Map<String, int> distributionMap = {};
    for (var r in timeResult) {
      if (r['time_of_day'] != null) {
        distributionMap[r['time_of_day'] as String] = r['count'] as int;
      }
    }

    return ListeningStats(
      totalMinutes: totalSeconds ~/ 60,
      totalSongsPlayed: totalCount,
      timeOfDayDistribution: distributionMap,
    );
  }

  Future<Map<int, int>> getAllSongPlayCounts() async {
    final db = await _dbProvider.db;

    // FIX: Hot path uses SUM(play_count) for consistency.
    final sql =
        '''
      SELECT s.source_id, SUM(cnt) as count
      FROM (
        SELECT song_id, SUM(play_count) as cnt
        FROM ${AnalyticsDatabase.tblPlaybackLogs}
        GROUP BY song_id

        UNION ALL

        SELECT song_id, SUM(play_count) as cnt
        FROM ${AnalyticsDatabase.tblDailyAggregates}
        GROUP BY song_id
      ) combined
      JOIN ${AnalyticsDatabase.tblSongs} s ON combined.song_id = s.id
      GROUP BY s.source_id
    ''';

    final result = await db.rawQuery(sql);
    final Map<int, int> counts = {};

    for (final row in result) {
      if (row['source_id'] != null) {
        counts[row['source_id'] as int] = row['count'] as int;
      }
    }
    return counts;
  }

  Future<ArtistStats> getArtistStats(String artistName) async {
    final db = await _dbProvider.db;

    // FIX: Hot path uses SUM(play_count) for play_count column.
    final innerSql =
        '''
    SELECT 
      SUM(total_duration) as total_duration, 
      SUM(play_count) as total_count,
      COUNT(DISTINCT session_id) as sessions
    FROM (
      SELECT 
        SUM(duration_listened) as total_duration, 
        SUM(play_count) as play_count,
        strftime('%Y-%m-%d %H', datetime(timestamp / 1000, 'unixepoch', 'localtime')) as session_id
      FROM ${AnalyticsDatabase.tblPlaybackLogs} log
      JOIN ${AnalyticsDatabase.tblSongs} s ON log.song_id = s.id
      JOIN ${AnalyticsDatabase.tblArtists} ar ON s.artist_id = ar.id
      WHERE ar.name = ?
      GROUP BY session_id
      
      UNION ALL
      
      SELECT 
        SUM(total_duration) as total_duration, 
        SUM(play_count) as play_count,
        date_epoch || time_of_day as session_id
      FROM ${AnalyticsDatabase.tblDailyAggregates} agg
      JOIN ${AnalyticsDatabase.tblSongs} s ON agg.song_id = s.id
      JOIN ${AnalyticsDatabase.tblArtists} ar ON s.artist_id = ar.id
      WHERE ar.name = ?
      GROUP BY session_id
    )
  ''';

    final finalSql =
        'SELECT SUM(total_duration) as total_duration, SUM(total_count) as total_count, SUM(sessions) as sessions FROM ($innerSql)';
    final finalResult = await db.rawQuery(finalSql, [artistName, artistName]);
    final row = finalResult.first;

    final timeSql =
        '''
    SELECT time_of_day, SUM(cnt) as count
    FROM (
      SELECT time_of_day, SUM(play_count) as cnt 
      FROM ${AnalyticsDatabase.tblPlaybackLogs} log
      JOIN ${AnalyticsDatabase.tblSongs} s ON log.song_id = s.id
      JOIN ${AnalyticsDatabase.tblArtists} ar ON s.artist_id = ar.id
      WHERE ar.name = ?
      GROUP BY time_of_day
      
      UNION ALL
      
      SELECT time_of_day, SUM(play_count) as cnt 
      FROM ${AnalyticsDatabase.tblDailyAggregates} agg
      JOIN ${AnalyticsDatabase.tblSongs} s ON agg.song_id = s.id
      JOIN ${AnalyticsDatabase.tblArtists} ar ON s.artist_id = ar.id
      WHERE ar.name = ?
      GROUP BY time_of_day
    )
    GROUP BY time_of_day
    ORDER BY count DESC
    LIMIT 1
  ''';

    final timeResult = await db.rawQuery(timeSql, [artistName, artistName]);
    final dominantTime = timeResult.isNotEmpty
        ? timeResult.first['time_of_day'] as String?
        : null;

    return ArtistStats(
      artistName: artistName,
      totalPlays: row['total_count'] as int? ?? 0,
      totalDurationSeconds: row['total_duration'] as int? ?? 0,
      sessions: row['sessions'] as int? ?? 0,
      dominantTimeOfDay: dominantTime,
    );
  }

  Future<List<PlayLog>> getPlaybackHistory({int? limit, int? offset}) async {
    final db = await _dbProvider.db;

    final result = await db.rawQuery(
      '''
      SELECT 
        log.id,
        s.source_id as song_id,
        s.title,
        ar.name as artist,
        al.name as album,
        g.name as genre,
        log.timestamp,
        log.duration_listened,
        log.is_completed,
        log.play_count,
        log.time_of_day
      FROM ${AnalyticsDatabase.tblPlaybackLogs} log
      JOIN ${AnalyticsDatabase.tblSongs} s ON log.song_id = s.id
      LEFT JOIN ${AnalyticsDatabase.tblArtists} ar ON s.artist_id = ar.id
      LEFT JOIN ${AnalyticsDatabase.tblAlbums} al ON s.album_id = al.id
      LEFT JOIN ${AnalyticsDatabase.tblGenres} g ON s.genre_id = g.id
      ORDER BY log.timestamp DESC
      LIMIT ? OFFSET ?
    ''',
      [limit ?? 50, offset ?? 0],
    );

    return result.map((row) {
      return PlayLog(
        id: row['id'] as int?,
        songId: row['song_id'] as int,
        songTitle: row['title'] as String,
        artist: row['artist'] as String,
        album: row['album'] as String,
        genre: row['genre'] as String,
        timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
        durationListenedSeconds: row['duration_listened'] as int,
        isCompleted: (row['is_completed'] as int) == 1,
        playCount: (row['play_count'] as int?) ?? 1,
        sessionTimeOfDay: row['time_of_day'] as String,
      );
    }).toList();
  }
}
