import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/local_music/domain/repositories/music_repository.dart';

class GetLocalSongsUseCase implements UseCase<List<SongEntity>, NoParams> {
  final MusicRepository musicRepository;
  GetLocalSongsUseCase(this.musicRepository);

  @override
  Future<Either<Failure, List<SongEntity>>> call(NoParams params) async {
    return await musicRepository.getLocalSongs();
  }
}
