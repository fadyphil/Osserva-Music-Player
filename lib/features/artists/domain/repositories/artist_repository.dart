import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/artists/domain/entities/artist_entity.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';

abstract class ArtistRepository {
  Future<Either<Failure, List<ArtistEntity>>> getArtists();
  Future<Either<Failure, List<SongEntity>>> getArtistSongs(int artistId);
  Future<Either<Failure, Map<String, dynamic>>> getArtistStats(
    String artistName,
  );
}
