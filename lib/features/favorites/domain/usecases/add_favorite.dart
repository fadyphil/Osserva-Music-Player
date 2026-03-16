import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';

class AddFavorite implements UseCase<void, SongEntity> {
  final FavoritesRepository repository;

  AddFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(SongEntity song) async {
    return await repository.addFavorite(song);
  }
}
