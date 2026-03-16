import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/playlists/domain/repositories/playlist_repository.dart';

class AddSongToPlaylist implements UseCase<void, AddSongToPlaylistParams> {
  final PlaylistRepository repository;

  AddSongToPlaylist(this.repository);

  @override
  Future<Either<Failure, void>> call(AddSongToPlaylistParams params) async {
    return await repository.addSongToPlaylist(params.playlistId, params.song);
  }
}

class AddSongToPlaylistParams {
  final int playlistId;
  final SongEntity song;

  AddSongToPlaylistParams({required this.playlistId, required this.song});
}
