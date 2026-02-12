import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';

abstract class MusicRepository {
  Future<Either<Failure, List<SongEntity>>> getLocalSongs();
  Future<Either<Failure, SongEntity>> getSongById(int id);
  Future<Either<Failure, bool>> deleteSong(int id, String path);
  Future<Either<Failure, bool>> editSongMetadata(SongEntity song, Map<String, dynamic> metadata);
}
