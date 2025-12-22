import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';

class EditPlaylist implements UseCase<PlaylistEntity, EditPlaylistParams> {
  final PlaylistRepository repository;

  EditPlaylist(this.repository);

  @override
  Future<Either<Failure, PlaylistEntity>> call(EditPlaylistParams params) async {
    return await repository.editPlaylist(
      playlistId: params.id,
      name: params.name,
      description: params.description,
      imagePath: params.imagePath,
    );
  }
}

class EditPlaylistParams {
  final int id;
  final String? name;
  final String? description;
  final String? imagePath;

  EditPlaylistParams({
    required this.id,
    this.name,
    this.description,
    this.imagePath,
  });
}
