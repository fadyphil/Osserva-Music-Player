import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/favorites/domain/repositories/favorites_repository.dart';

class GetFavoriteIds implements UseCase<List<int>, NoParams> {
  final FavoritesRepository repository;

  GetFavoriteIds(this.repository);

  @override
  Future<Either<Failure, List<int>>> call(NoParams params) async {
    return await repository.getFavoriteIds();
  }
}
