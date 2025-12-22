import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';

class CreatePlaylist implements UseCase<PlaylistEntity, CreatePlaylistParams> {
  final PlaylistRepository repository;

  CreatePlaylist(this.repository);

  @override
  Future<Either<Failure, PlaylistEntity>> call(CreatePlaylistParams params) async {
    return await repository.createPlaylist(
      name: params.name,
      description: params.description,
      imagePath: params.imagePath,
    );
  }
}

class CreatePlaylistParams {
  final String name;
  final String description;
  final String? imagePath;

  CreatePlaylistParams({
    required this.name,
    required this.description,
    this.imagePath,
  });
}
