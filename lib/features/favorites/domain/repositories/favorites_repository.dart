import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, void>> addFavorite(SongEntity song);
  Future<Either<Failure, void>> removeFavorite(int songId);
  Future<Either<Failure, List<int>>> getFavoriteIds();
}
