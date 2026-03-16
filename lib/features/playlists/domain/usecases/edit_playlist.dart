import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/playlists/domain/entities/playlist_entity.dart';
import 'package:osserva/features/playlists/domain/repositories/playlist_repository.dart';

class EditPlaylist implements UseCase<PlaylistEntity, EditPlaylistParams> {
  final PlaylistRepository repository;

  EditPlaylist(this.repository);

  @override
  Future<Either<Failure, PlaylistEntity>> call(
    EditPlaylistParams params,
  ) async {
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
