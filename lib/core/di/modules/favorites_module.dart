import 'package:get_it/get_it.dart';
import 'package:music_player/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:music_player/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:music_player/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player/features/favorites/domain/usecases/add_favorite.dart';
import 'package:music_player/features/favorites/domain/usecases/get_favorite_songs.dart';
import 'package:music_player/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';

void registerFavoritesDependencies(GetIt sl) {
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => AddFavorite(sl()));
  sl.registerLazySingleton(() => RemoveFavorite(sl()));
  sl.registerLazySingleton(
    () => GetFavoriteSongs(favoritesRepository: sl(), musicRepository: sl()),
  );
  sl.registerFactory(
    () => FavoritesBloc(
      getFavoriteSongs: sl(),
      addFavorite: sl(),
      removeFavorite: sl(),
    ),
  );
}
