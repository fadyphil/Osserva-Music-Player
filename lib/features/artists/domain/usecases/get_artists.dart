import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/artists/domain/entities/artist_entity.dart';
import 'package:music_player/features/artists/domain/repositories/artist_repository.dart';

class GetArtists implements UseCase<List<ArtistEntity>, NoParams> {
  final ArtistRepository repository;

  GetArtists(this.repository);

  @override
  Future<Either<Failure, List<ArtistEntity>>> call(NoParams params) async {
    return await repository.getArtists();
  }
}
