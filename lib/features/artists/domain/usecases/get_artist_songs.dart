import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/artists/domain/repositories/artist_repository.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';

class GetArtistSongs implements UseCase<List<SongEntity>, int> {
  final ArtistRepository repository;

  GetArtistSongs(this.repository);

  @override
  Future<Either<Failure, List<SongEntity>>> call(int artistId) async {
    return await repository.getArtistSongs(artistId);
  }
}
