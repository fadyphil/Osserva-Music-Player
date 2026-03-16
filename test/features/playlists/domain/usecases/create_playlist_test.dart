import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:osserva/features/playlists/domain/entities/playlist_entity.dart';
import 'package:osserva/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:osserva/features/playlists/domain/usecases/create_playlist.dart';

class MockPlaylistRepository extends Mock implements PlaylistRepository {}

void main() {
  late CreatePlaylist useCase;
  late MockPlaylistRepository mockRepository;

  setUp(() {
    mockRepository = MockPlaylistRepository();
    useCase = CreatePlaylist(mockRepository);
  });

  // Actually we can't use const with null for required unless nullable.
  // Let's use real dates.
  final tDate = DateTime.now();
  final tPlaylistReal = PlaylistEntity(
    id: 1,
    name: 'Test Playlist',
    description: 'Desc',
    imagePath: null,
    createdAt: tDate,
    updatedAt: tDate,
    totalSongs: 0,
    totalDurationSeconds: 0,
    songIds: [],
  );

  test('should call repository.createPlaylist and return the result', () async {
    // Arrange
    when(
      () => mockRepository.createPlaylist(
        name: any(named: 'name'),
        description: any(named: 'description'),
        imagePath: any(named: 'imagePath'),
      ),
    ).thenAnswer((_) async => Right(tPlaylistReal));

    // Act
    final result = await useCase(
      CreatePlaylistParams(name: 'Test Playlist', description: 'Desc'),
    );

    // Assert
    expect(result, Right(tPlaylistReal));
    verify(
      () => mockRepository.createPlaylist(
        name: 'Test Playlist',
        description: 'Desc',
        imagePath: null,
      ),
    ).called(1);
  });
}
