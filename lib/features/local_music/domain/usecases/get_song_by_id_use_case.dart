import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/local_music/domain/repositories/music_repository.dart';

class GetSongByIdUseCase implements UseCase<SongEntity, int> {
  final MusicRepository _repository;

  GetSongByIdUseCase(this._repository);

  @override
  Future<Either<Failure, SongEntity>> call(int id) async {
    return await _repository.getSongById(id);
  }
}
