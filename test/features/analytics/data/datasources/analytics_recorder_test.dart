import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:osserva/features/analytics/data/datasources/analytics_recorder.dart';
import 'package:osserva/features/analytics/data/datasources/db/analytics_database.dart';
import 'package:osserva/features/analytics/domain/entities/play_log.dart';

class MockAnalyticsDatabase extends Mock implements AnalyticsDatabase {}

void main() {
  late AnalyticsRecorder recorder;
  late MockAnalyticsDatabase mockDbProvider;
  late Database db;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    mockDbProvider = MockAnalyticsDatabase();

    // Open in-memory database
    db = await openDatabase(
      inMemoryDatabasePath,
      version: 3,
      onCreate: (db, version) async {
        // Create tables needed for the test
        // 1. Dimensions
        await db.execute(
          'CREATE TABLE ${AnalyticsDatabase.tblArtists} (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
        );
        await db.execute(
          'CREATE TABLE ${AnalyticsDatabase.tblAlbums} (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
        );
        await db.execute(
          'CREATE TABLE ${AnalyticsDatabase.tblGenres} (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE)',
        );

        // 2. Song Metadata
        await db.execute('''
        CREATE TABLE ${AnalyticsDatabase.tblSongs} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          source_id INTEGER, 
          title TEXT,
          artist_id INTEGER REFERENCES ${AnalyticsDatabase.tblArtists}(id),
          album_id INTEGER REFERENCES ${AnalyticsDatabase.tblAlbums}(id),
          genre_id REFERENCES ${AnalyticsDatabase.tblGenres}(id)
        )
      ''');
        await db.execute(
          'CREATE INDEX idx_songs_source ON ${AnalyticsDatabase.tblSongs} (source_id)',
        );

        // 3. Fact Table: Hot Logs
        await db.execute('''
        CREATE TABLE ${AnalyticsDatabase.tblPlaybackLogs} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          song_id INTEGER REFERENCES ${AnalyticsDatabase.tblSongs}(id),
          timestamp INTEGER,
          duration_listened INTEGER,
          is_completed INTEGER,
          play_count INTEGER DEFAULT 1,
          time_of_day TEXT
        )
      ''');
      },
    );

    when(() => mockDbProvider.db).thenAnswer((_) async => db);
    recorder = AnalyticsRecorder(mockDbProvider);
  });

  tearDown(() async {
    await db.close();
  });

  final testLogA = PlayLog(
    songId: 101,
    songTitle: 'Song A',
    artist: 'Artist A',
    album: 'Album A',
    genre: 'Genre A',
    timestamp: DateTime.now(),
    durationListenedSeconds: 120,
    isCompleted: true,
    sessionTimeOfDay: 'Morning',
    playCount: 1,
  );

  final testLogB = PlayLog(
    songId: 102,
    songTitle: 'Song B',
    artist: 'Artist B',
    album: 'Album B',
    genre: 'Genre B',
    timestamp: DateTime.now().add(const Duration(minutes: 5)),
    durationListenedSeconds: 180,
    isCompleted: true,
    sessionTimeOfDay: 'Morning',
    playCount: 1,
  );

  test('should insert new log when history is empty', () async {
    await recorder.logEvent(testLogA);

    final result = await db.query(AnalyticsDatabase.tblPlaybackLogs);
    expect(result.length, 1);
    expect(result.first['play_count'], 1);

    // Check song insertion
    final songs = await db.query(AnalyticsDatabase.tblSongs);
    expect(songs.length, 1);
    expect(songs.first['source_id'], 101);
  });

  test(
    'should increment play_count when same song is played consecutively',
    () async {
      await recorder.logEvent(testLogA);
      // Log same song again immediately
      await recorder.logEvent(testLogA);

      final result = await db.query(AnalyticsDatabase.tblPlaybackLogs);
      expect(result.length, 1); // Should still be 1 row
      expect(result.first['play_count'], 2); // Count should be 2
    },
  );

  test(
    'should insert new logs for different songs sequence (A -> B -> A)',
    () async {
      // 1. Play A
      await recorder.logEvent(testLogA);
      var logs = await db.query(AnalyticsDatabase.tblPlaybackLogs);
      expect(logs.length, 1);
      expect(logs.first['play_count'], 1);

      // 2. Play B
      await recorder.logEvent(testLogB);
      logs = await db.query(AnalyticsDatabase.tblPlaybackLogs);
      expect(logs.length, 2);
      // Last log should be B
      expect(logs.last['song_id'], isNot(logs.first['song_id']));

      // 3. Play A again (should insert NEW row, not update the first one)
      await recorder.logEvent(testLogA);
      logs = await db.query(AnalyticsDatabase.tblPlaybackLogs);
      expect(logs.length, 3);

      // Verify sequence
      // Row 1: A, count 1
      // Row 2: B, count 1
      // Row 3: A, count 1

      // Note: ID is autoincrement, so order by ID is sufficient
      expect(logs[0]['play_count'], 1);
      expect(logs[1]['play_count'], 1);
      expect(logs[2]['play_count'], 1);
    },
  );

  test('should increment play_count correctly for A -> A -> B', () async {
    // A
    await recorder.logEvent(testLogA);
    // A (update)
    await recorder.logEvent(testLogA);

    var logs = await db.query(AnalyticsDatabase.tblPlaybackLogs);
    expect(logs.length, 1);
    expect(logs.first['play_count'], 2);

    // B (insert)
    await recorder.logEvent(testLogB);

    logs = await db.query(AnalyticsDatabase.tblPlaybackLogs);
    expect(logs.length, 2);
    expect(logs[0]['play_count'], 2); // A
    expect(logs[1]['play_count'], 1); // B
  });
}
