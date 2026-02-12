import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/local%20music/data/datasource/local_music_datasource.dart';
import 'package:music_player/features/local%20music/data/failures/music_failures.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/local%20music/domain/repositories/music_repository.dart';
import 'package:music_player/features/local%20music/domain/usecases/edit_song_metadata.dart';

class MusicRepositoryImpl implements MusicRepository {
  final LocalMusicDatasource _localMusicDatasource;

  MusicRepositoryImpl(this._localMusicDatasource);

  @override
  Future<Either<Failure, List<SongEntity>>> getLocalSongs() async {
    try {
      final songs = await _localMusicDatasource.getLocalMusic();
      return Right(songs);
    } catch (e) {
      return Left(MusicFailures.storageError(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SongEntity>> getSongById(int id) async {
    try {
      final song = await _localMusicDatasource.getSongById(id);
      if (song != null) {
        return Right(song);
      }
      return const Left(MusicFailures.storageError(message: 'Song not found'));
    } catch (e) {
      return Left(MusicFailures.storageError(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSong(int id, String path) async {
    try {
      final result = await _localMusicDatasource.deleteSong(id: id, path: path);
      if (result) {
        return const Right(true);
      }
      return const Left(MusicFailures.storageError(message: 'Failed to delete song file'));
    } catch (e) {
      return Left(MusicFailures.storageError(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> editSongMetadata(EditSongMetadataParams params) async {
    try {
      final result = await _localMusicDatasource.editSongMetadata(
        path: params.song.path,
        title: params.title,
        artist: params.artist,
        album: params.album,
        genre: params.genre,
        year: params.year,
        artworkBytes: params.artworkBytes,
      );
       if (result) {
        return const Right(true);
      }
      return const Left(MusicFailures.storageError(message: 'Failed to edit song metadata'));
    } catch (e) {
      return Left(MusicFailures.storageError(message: e.toString()));
    }
  }
}
