import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/artists/domain/repositories/artist_repository.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';

class GetArtistSongs implements UseCase<List<SongEntity>, int> {
  final ArtistRepository repository;

  GetArtistSongs(this.repository);

  @override
  Future<Either<Failure, List<SongEntity>>> call(int artistId) async {
    return await repository.getArtistSongs(artistId);
  }
}
