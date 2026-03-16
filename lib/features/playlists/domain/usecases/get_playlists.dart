import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/playlists/domain/entities/playlist_entity.dart';
import 'package:osserva/features/playlists/domain/repositories/playlist_repository.dart';

class GetPlaylists implements UseCase<List<PlaylistEntity>, NoParams> {
  final PlaylistRepository repository;

  GetPlaylists(this.repository);

  @override
  Future<Either<Failure, List<PlaylistEntity>>> call(NoParams params) async {
    return await repository.getPlaylists();
  }
}
