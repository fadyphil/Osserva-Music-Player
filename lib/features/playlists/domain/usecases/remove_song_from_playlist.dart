import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/playlists/domain/repositories/playlist_repository.dart';

class RemoveSongFromPlaylist
    implements UseCase<void, RemoveSongFromPlaylistParams> {
  final PlaylistRepository repository;

  RemoveSongFromPlaylist(this.repository);

  @override
  Future<Either<Failure, void>> call(
    RemoveSongFromPlaylistParams params,
  ) async {
    return await repository.removeSongFromPlaylist(
      params.playlistId,
      params.songId,
    );
  }
}

class RemoveSongFromPlaylistParams {
  final int playlistId;
  final int songId;

  RemoveSongFromPlaylistParams({
    required this.playlistId,
    required this.songId,
  });
}
