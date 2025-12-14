import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/local%20music/domain/repositories/music_repository.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';

class GetPlaylistSongs implements UseCase<List<SongEntity>, int> {
  final PlaylistRepository playlistRepository;
  final MusicRepository musicRepository;

  GetPlaylistSongs({
    required this.playlistRepository,
    required this.musicRepository,
  });

  @override
  Future<Either<Failure, List<SongEntity>>> call(int playlistId) async {
    // 1. Get IDs
    final idsResult = await playlistRepository.getPlaylistSongIds(playlistId);
    
    return idsResult.fold(
      (failure) => Left(failure),
      (ids) async {
        if (ids.isEmpty) return const Right([]);

        // 2. Get All Songs
        final songsResult = await musicRepository.getLocalSongs();
        
        return songsResult.fold(
          (failure) => Left(failure),
          (allSongs) {
            // 3. Filter and Sort (to maintain order of addition)
            // Create a map for O(1) lookup
            final songMap = {for (var s in allSongs) s.id: s};
            
            final List<SongEntity> playlistSongs = [];
            for (var id in ids) {
              if (songMap.containsKey(id)) {
                playlistSongs.add(songMap[id]!);
              }
            }
            return Right(playlistSongs);
          },
        );
      },
    );
  }
}
