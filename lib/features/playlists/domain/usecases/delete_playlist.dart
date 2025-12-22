import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';

class DeletePlaylist implements UseCase<void, int> {
  final PlaylistRepository repository;

  DeletePlaylist(this.repository);

  @override
  Future<Either<Failure, void>> call(int playlistId) async {
    return await repository.deletePlaylist(playlistId);
  }
}
