import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';
import 'package:music_player/features/local_music/domain/repositories/music_repository.dart';

class GetFavoriteSongs implements UseCase<List<SongEntity>, NoParams> {
  final FavoritesRepository favoritesRepository;
  final MusicRepository musicRepository;

  GetFavoriteSongs({
    required this.favoritesRepository,
    required this.musicRepository,
  });

  @override
  Future<Either<Failure, List<SongEntity>>> call(NoParams params) async {
    // 1. Get IDs
    final idsResult = await favoritesRepository.getFavoriteIds();

    return idsResult.fold((failure) => Left(failure), (ids) async {
      if (ids.isEmpty) return const Right([]);

      // 2. Get All Songs
      final songsResult = await musicRepository.getLocalSongs();

      return songsResult.fold((failure) => Left(failure), (allSongs) {
        // 3. Filter
        final songMap = {for (var s in allSongs) s.id: s};
        final List<SongEntity> favoriteSongs = [];
        for (var id in ids) {
          if (songMap.containsKey(id)) {
            favoriteSongs.add(songMap[id]!);
          }
        }
        // Sort by added order?
        // The IDs returned by repo should ideally be sorted by added_at.
        // But since I'm iterating `ids`, the order is preserved if `ids` is sorted.
        return Right(favoriteSongs);
      });
    });
  }
}
