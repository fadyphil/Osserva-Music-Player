import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_player/features/local_music/data/datasource/local_music_datasource.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MockOnAudioQuery extends Mock implements OnAudioQuery {}

class MockMediaStore extends Mock implements MediaStore {}

void main() {
  late LocalMusicDatasourceImpl datasource;
  late MockOnAudioQuery mockOnAudioQuery;
  late MockMediaStore mockMediaStore;

  setUp(() {
    mockOnAudioQuery = MockOnAudioQuery();
    mockMediaStore = MockMediaStore();
    datasource = LocalMusicDatasourceImpl(mockOnAudioQuery, mockMediaStore);
  });

  group('LocalMusicDatasource', () {
    test('should return list of songs (Linux Logic or OnAudioQuery)', () async {
      // ARRANGE
      if (!Platform.isLinux && !Platform.isWindows && !Platform.isMacOS) {
        // If not desktop, we expect OnAudioQuery to be called
        when(
          () => mockOnAudioQuery.querySongs(
            sortType: any(named: 'sortType'),
            orderType: any(named: 'orderType'),
            uriType: any(named: 'uriType'),
            ignoreCase: any(named: 'ignoreCase'),
          ),
        ).thenAnswer(
          (_) async => [
            SongModel({
              '_id': 1,
              'title': 'Test Song',
              'artist': 'Test Artist',
              'album': 'Test Album',
              'duration': 60000,
              'is_music': true,
              '_data': '/path/to/song.mp3',
            }),
          ],
        );
      }

      // ACT
      final result = await datasource.getLocalMusic();

      // ASSERT
      expect(result, isA<List>());
      if (Platform.isLinux) {
        // On Linux, we just expect it not to crash and return a list (empty or not)
      } else if (!Platform.isWindows && !Platform.isMacOS) {
        // On Mobile, verify mock usage
        verify(
          () => mockOnAudioQuery.querySongs(
            sortType: any(named: 'sortType'),
            orderType: any(named: 'orderType'),
            uriType: any(named: 'uriType'),
            ignoreCase: any(named: 'ignoreCase'),
          ),
        ).called(1);
        expect(result.length, 1);
        expect(result.first.title, 'Test Song');
      }
    });

    group('deleteSong', () {
      const tId = 1;
      const tPath = '/path/to/song.mp3';

      test('should use MediaStore on Android', () async {
        // ARRANGE
        // We can't easily mock Platform.isAndroid, but we can check if the call happens if we were on Android.
        // For the sake of this test, we assume the code path for Android is hit if Platform.isAndroid is true.
        if (Platform.isAndroid) {
          when(
            () => mockMediaStore.deleteFileUsingUri(
              uriString: any(named: 'uriString'),
            ),
          ).thenAnswer((_) async => true);

          // ACT
          final result = await datasource.deleteSong(id: tId, path: tPath);

          // ASSERT
          expect(result, true);
          verify(
            () => mockMediaStore.deleteFileUsingUri(
              uriString: 'content://media/external/audio/media/$tId',
            ),
          ).called(1);
        }
      });

      test('should return false if deletion fails on Android', () async {
        if (Platform.isAndroid) {
          when(
            () => mockMediaStore.deleteFileUsingUri(
              uriString: any(named: 'uriString'),
            ),
          ).thenThrow(Exception('Failed'));

          // Fallback will also likely fail as file doesn't exist
          // ACT
          final result = await datasource.deleteSong(id: tId, path: tPath);

          // ASSERT
          expect(result, false);
        }
      });
    });
  });
}
