import 'db/analytics_database.dart';

class AnalyticsAggregator {
  final AnalyticsDatabase _dbProvider;

  AnalyticsAggregator(this._dbProvider);

  /// Aggregates logs older than [daysToKeep] into daily_aggregates
  /// and deletes the raw logs.
  Future<void> performRollUp({int daysToKeep = 90}) async {
    final db = await _dbProvider.db;
    final now = DateTime.now();
    final thresholdDate = now.subtract(Duration(days: daysToKeep));
    final thresholdEpoch = thresholdDate.millisecondsSinceEpoch;

    await db.transaction((txn) async {
      // 1. Insert into Aggregates or Update if exists (Upsert)
      // We group by Day (calculated from timestamp), song_id, and time_of_day.
      // 86400000 = ms in a day. Integer division gives us the "Day Number".
      // Multiplying back gives us Midnight of that day.
      await txn.execute(
        '''
        INSERT INTO ${AnalyticsDatabase.tblDailyAggregates} 
        (date_epoch, song_id, time_of_day, play_count, total_duration)
        SELECT 
          (timestamp / 86400000) * 86400000 as day_epoch,
          song_id,
          time_of_day,
          COUNT(*) as play_count,
          SUM(duration_listened) as total_duration
        FROM ${AnalyticsDatabase.tblPlaybackLogs}
        WHERE timestamp < ?
        GROUP BY day_epoch, song_id, time_of_day
        ON CONFLICT(date_epoch, song_id, time_of_day) DO UPDATE SET
          play_count = play_count + excluded.play_count,
          total_duration = total_duration + excluded.total_duration
      ''',
        [thresholdEpoch],
      );

      // 2. Delete Raw Logs
      await txn.delete(
        AnalyticsDatabase.tblPlaybackLogs,
        where: 'timestamp < ?',
        whereArgs: [thresholdEpoch],
      );
    });
  }
}
