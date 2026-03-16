import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/local_music/domain/usecases/edit_song_metadata.dart';

abstract class MusicRepository {
  Future<Either<Failure, List<SongEntity>>> getLocalSongs();
  Future<Either<Failure, SongEntity>> getSongById(int id);
  Future<Either<Failure, bool>> deleteSong(int id, String path);
  Future<Either<Failure, bool>> editSongMetadata(EditSongMetadataParams params);
}
