import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/playlists/data/datasources/playlist_local_datasource.dart';
import 'package:music_player/features/playlists/data/models/playlist_model.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';
import 'package:music_player/features/playlists/domain/failures/playlist_failure.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final PlaylistLocalDataSource dataSource;

  PlaylistRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, PlaylistEntity>> createPlaylist({
    required String name,
    required String description,
    String? imagePath,
  }) async {
    try {
      final model = await dataSource.createPlaylist(
        name: name,
        description: description,
        imagePath: imagePath,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(PlaylistFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePlaylist(int playlistId) async {
    try {
      await dataSource.deletePlaylist(playlistId);
      return const Right(null);
    } catch (e) {
      return Left(PlaylistFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PlaylistEntity>> editPlaylist({
    required int playlistId,
    String? name,
    String? description,
    String? imagePath,
  }) async {
    try {
      final model = await dataSource.editPlaylist(
        id: playlistId,
        name: name,
        description: description,
        imagePath: imagePath,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(PlaylistFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addSongToPlaylist(int playlistId, SongEntity song) async {
    try {
      await dataSource.addSongToPlaylist(
        playlistId: playlistId,
        songId: song.id,
        durationMs: song.duration.toInt(),
      );
      return const Right(null);
    } catch (e) {
      return Left(PlaylistFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeSongFromPlaylist(int playlistId, int songId) async {
    try {
      await dataSource.removeSongFromPlaylist(playlistId: playlistId, songId: songId);
      return const Right(null);
    } catch (e) {
      return Left(PlaylistFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeSongFromAllPlaylists(int songId) async {
    try {
      await dataSource.removeSongFromAllPlaylists(songId);
      return const Right(null);
    } catch (e) {
      return Left(PlaylistFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PlaylistEntity>>> getPlaylists() async {
    try {
      final models = await dataSource.getPlaylists();
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(PlaylistFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<int>>> getPlaylistSongIds(int playlistId) async {
    try {
      final ids = await dataSource.getPlaylistSongIds(playlistId);
      return Right(ids);
    } catch (e) {
      return Left(PlaylistFailure(e.toString()));
    }
  }
}
