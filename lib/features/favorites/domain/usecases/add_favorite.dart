import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/favorites/domain/repositories/favorites_repository.dart';

class AddFavorite implements UseCase<void, SongEntity> {
  final FavoritesRepository repository;

  AddFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(SongEntity song) async {
    return await repository.addFavorite(song);
  }
}
