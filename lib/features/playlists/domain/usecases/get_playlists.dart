import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';

class GetPlaylists implements UseCase<List<PlaylistEntity>, NoParams> {
  final PlaylistRepository repository;

  GetPlaylists(this.repository);

  @override
  Future<Either<Failure, List<PlaylistEntity>>> call(NoParams params) async {
    return await repository.getPlaylists();
  }
}
