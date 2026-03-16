import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:osserva/features/music_player/data/repos/audio_player_repository_impl.dart';
import 'package:osserva/features/music_player/domain/repos/audio_player_repository.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_bloc.dart';

void registerMusicPlayerDependencies(GetIt sl) {
  sl.registerLazySingleton<AudioPlayerRepository>(
    () => AudioPlayerRepositoryImpl(sl<AudioHandler>()),
  );
  sl.registerFactory(() => MusicPlayerBloc(sl(), sl(), sl()));
}
