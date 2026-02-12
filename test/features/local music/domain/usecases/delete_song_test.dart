import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_player/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:music_player/features/local%20music/data/failures/music_failures.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/local%20music/domain/repositories/music_repository.dart';
import 'package:music_player/features/local%20music/domain/usecases/delete_song.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';

class MockMusicRepository extends Mock implements MusicRepository {}
class MockPlaylistRepository extends Mock implements PlaylistRepository {}
class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late DeleteSong usecase;
  late MockMusicRepository mockMusicRepository;
  late MockPlaylistRepository mockPlaylistRepository;
  late MockAnalyticsRepository mockAnalyticsRepository;

  setUp(() {
    mockMusicRepository = MockMusicRepository();
    mockPlaylistRepository = MockPlaylistRepository();
    mockAnalyticsRepository = MockAnalyticsRepository();
    usecase = DeleteSong(
      mockMusicRepository,
      mockPlaylistRepository,
      mockAnalyticsRepository,
    );
  });

  const tSong = SongEntity(
    id: 1,
    title: 'Test Song',
    artist: 'Test Artist',
    album: 'Test Album',
    albumId: 0,
    path: '/path/to/song.mp3',
    duration: 1000,
    size: 1024,
  );

  test('should delete song from playlists, analytics, and finally from music repository', () async {
    // ARRANGE
    when(() => mockPlaylistRepository.removeSongFromAllPlaylists(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockAnalyticsRepository.deleteSongAnalytics(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockMusicRepository.deleteSong(any(), any()))
        .thenAnswer((_) async => const Right(true));

    // ACT
    final result = await usecase(tSong);

    // ASSERT
    expect(result, const Right(true));
    verify(() => mockPlaylistRepository.removeSongFromAllPlaylists(tSong.id)).called(1);
    verify(() => mockAnalyticsRepository.deleteSongAnalytics(tSong.id)).called(1);
    verify(() => mockMusicRepository.deleteSong(tSong.id, tSong.path)).called(1);
  });

  test('should return failure if music repository fails to delete', () async {
    // ARRANGE
    const tFailure = MusicFailures.storageError(message: 'Delete failed');
    when(() => mockPlaylistRepository.removeSongFromAllPlaylists(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockAnalyticsRepository.deleteSongAnalytics(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockMusicRepository.deleteSong(any(), any()))
        .thenAnswer((_) async => const Left(tFailure));

    // ACT
    final result = await usecase(tSong);

    // ASSERT
    expect(result, const Left(tFailure));
  });
}
