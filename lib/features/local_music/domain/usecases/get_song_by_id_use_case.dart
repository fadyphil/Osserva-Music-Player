import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';
import 'package:music_player/features/local_music/domain/repositories/music_repository.dart';

class GetSongByIdUseCase implements UseCase<SongEntity, int> {
  final MusicRepository _repository;

  GetSongByIdUseCase(this._repository);

  @override
  Future<Either<Failure, SongEntity>> call(int id) async {
    return await _repository.getSongById(id);
  }
}
