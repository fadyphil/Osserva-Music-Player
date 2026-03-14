import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:music_player/features/favorites/domain/failures/favorites_failure.dart';
import 'package:music_player/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource dataSource;

  FavoritesRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, void>> addFavorite(SongEntity song) async {
    try {
      await dataSource.addFavorite(song.id);
      return const Right(null);
    } catch (e) {
      return Left(FavoritesFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int songId) async {
    try {
      await dataSource.removeFavorite(songId);
      return const Right(null);
    } catch (e) {
      return Left(FavoritesFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getFavoriteIds() async {
    try {
      final ids = await dataSource.getFavoriteIds();
      return Right(ids);
    } catch (e) {
      return Left(FavoritesFailure(e.toString()));
    }
  }
}
