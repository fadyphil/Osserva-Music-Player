import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:music_player/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player/features/favorites/domain/usecases/add_favorite.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';

class MockFavoritesRepository extends Mock implements FavoritesRepository {}

void main() {
  late AddFavorite useCase;
  late MockFavoritesRepository mockRepository;

  setUp(() {
    mockRepository = MockFavoritesRepository();
    useCase = AddFavorite(mockRepository);
  });

  final tSong = SongEntity(
    id: 123,
    title: 'Test Song',
    artist: 'Test Artist',
    album: 'Test Album',
    albumId: 456,
    path: '/path/to/song',
    duration: 3000,
    size: 1024,
  );

  test('should call repository.addFavorite with the song', () async {
    // Arrange
    when(
      () => mockRepository.addFavorite(tSong),
    ).thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase(tSong);

    // Assert
    expect(result, const Right(null));
    verify(() => mockRepository.addFavorite(tSong)).called(1);
  });
}
