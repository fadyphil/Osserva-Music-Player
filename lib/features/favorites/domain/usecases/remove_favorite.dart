import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/favorites/domain/repositories/favorites_repository.dart';

class RemoveFavorite implements UseCase<void, int> {
  final FavoritesRepository repository;

  RemoveFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(int songId) async {
    return await repository.removeFavorite(songId);
  }
}
