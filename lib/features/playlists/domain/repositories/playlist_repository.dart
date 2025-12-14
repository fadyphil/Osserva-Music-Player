import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';

abstract class PlaylistRepository {
  Future<Either<Failure, PlaylistEntity>> createPlaylist({
    required String name,
    required String description,
    String? imagePath,
  });

  Future<Either<Failure, void>> deletePlaylist(int playlistId);

  Future<Either<Failure, PlaylistEntity>> editPlaylist({
    required int playlistId,
    String? name,
    String? description,
    String? imagePath,
  });

  Future<Either<Failure, void>> addSongToPlaylist(int playlistId, SongEntity song);

  Future<Either<Failure, void>> removeSongFromPlaylist(int playlistId, int songId);

  Future<Either<Failure, List<PlaylistEntity>>> getPlaylists();

  Future<Either<Failure, List<int>>> getPlaylistSongIds(int playlistId);
}
