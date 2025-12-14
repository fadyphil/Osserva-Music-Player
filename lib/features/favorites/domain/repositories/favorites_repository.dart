import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, void>> addFavorite(SongEntity song);
  Future<Either<Failure, void>> removeFavorite(int songId);
  Future<Either<Failure, List<int>>> getFavoriteIds();
}
