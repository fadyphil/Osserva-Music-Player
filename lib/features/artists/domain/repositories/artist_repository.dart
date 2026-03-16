import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/features/artists/domain/entities/artist_entity.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';

abstract class ArtistRepository {
  Future<Either<Failure, List<ArtistEntity>>> getArtists();
  Future<Either<Failure, List<SongEntity>>> getArtistSongs(int artistId);
  Future<Either<Failure, Map<String, dynamic>>> getArtistStats(
    String artistName,
  );
}
