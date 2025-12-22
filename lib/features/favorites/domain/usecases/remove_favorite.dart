import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/favorites/domain/repositories/favorites_repository.dart';

class RemoveFavorite implements UseCase<void, int> {
  final FavoritesRepository repository;

  RemoveFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(int songId) async {
    return await repository.removeFavorite(songId);
  }
}
