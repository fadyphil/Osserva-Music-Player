import 'package:get_it/get_it.dart';
import 'package:osserva/features/playlists/data/datasources/playlist_local_datasource.dart';
import 'package:osserva/features/playlists/data/repositories/playlist_repository_impl.dart';
import 'package:osserva/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:osserva/features/playlists/domain/usecases/add_song_to_playlist.dart';
import 'package:osserva/features/playlists/domain/usecases/create_playlist.dart';
import 'package:osserva/features/playlists/domain/usecases/delete_playlist.dart';
import 'package:osserva/features/playlists/domain/usecases/edit_playlist.dart';
import 'package:osserva/features/playlists/domain/usecases/get_playlist_songs.dart';
import 'package:osserva/features/playlists/domain/usecases/get_playlists.dart';
import 'package:osserva/features/playlists/domain/usecases/remove_song_from_playlist.dart';
import 'package:osserva/features/playlists/presentation/bloc/playlist_bloc.dart';
import 'package:osserva/features/playlists/presentation/bloc/playlist_detail_bloc.dart';

void registerPlaylistsDependencies(GetIt sl) {
  sl.registerLazySingleton<PlaylistLocalDataSource>(
    () => PlaylistLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => CreatePlaylist(sl()));
  sl.registerLazySingleton(() => DeletePlaylist(sl()));
  sl.registerLazySingleton(() => EditPlaylist(sl()));
  sl.registerLazySingleton(() => GetPlaylists(sl()));
  sl.registerLazySingleton(() => AddSongToPlaylist(sl()));
  sl.registerLazySingleton(() => RemoveSongFromPlaylist(sl()));
  sl.registerLazySingleton(
    () => GetPlaylistSongs(playlistRepository: sl(), musicRepository: sl()),
  );
  sl.registerFactory(
    () => PlaylistBloc(
      getPlaylists: sl(),
      createPlaylist: sl(),
      deletePlaylist: sl(),
      addSongToPlaylist: sl(),
    ),
  );
  sl.registerFactory(
    () => PlaylistDetailBloc(
      getPlaylistSongs: sl(),
      addSongToPlaylist: sl(),
      removeSongFromPlaylist: sl(),
      editPlaylist: sl(),
    ),
  );
}
