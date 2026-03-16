import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/artists/domain/entities/artist_entity.dart';
import 'package:osserva/features/artists/domain/repositories/artist_repository.dart';

class GetArtists implements UseCase<List<ArtistEntity>, NoParams> {
  final ArtistRepository repository;

  GetArtists(this.repository);

  @override
  Future<Either<Failure, List<ArtistEntity>>> call(NoParams params) async {
    return await repository.getArtists();
  }
}
