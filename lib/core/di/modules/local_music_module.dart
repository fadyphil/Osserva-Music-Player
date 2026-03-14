import 'package:get_it/get_it.dart';
import 'package:music_player/features/local_music/data/datasource/local_music_datasource.dart';
import 'package:music_player/features/local_music/data/repositories/music_repository_impl.dart';
import 'package:music_player/features/local_music/domain/repositories/music_repository.dart';
import 'package:music_player/features/local_music/domain/usecases/delete_song.dart';
import 'package:music_player/features/local_music/domain/usecases/edit_song_metadata.dart';
import 'package:music_player/features/local_music/domain/usecases/get_local_songs_use_case.dart';
import 'package:music_player/features/local_music/domain/usecases/get_song_by_id_use_case.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_bloc.dart';

void registerLocalMusicDependencies(GetIt sl) {
  sl.registerLazySingleton<LocalMusicDatasource>(
    () => LocalMusicDatasourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<MusicRepository>(() => MusicRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetLocalSongsUseCase(sl()));
  sl.registerLazySingleton(() => GetSongByIdUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSong(sl(), sl(), sl()));
  sl.registerLazySingleton(() => EditSongMetadata(sl()));
  sl.registerFactory(() => LocalMusicBloc(sl(), sl(), sl(), sl()));
}
