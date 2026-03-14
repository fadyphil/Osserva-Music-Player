import 'package:get_it/get_it.dart';
import 'package:music_player/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:music_player/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:music_player/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_player/features/profile/domain/usecases/clear_cache.dart';
import 'package:music_player/features/profile/domain/usecases/get_achievements.dart';
import 'package:music_player/features/profile/domain/usecases/get_user_profile.dart';
import 'package:music_player/features/profile/domain/usecases/update_user_profile.dart';
import 'package:music_player/features/profile/presentation/bloc/profile_bloc.dart';

void registerProfileDependencies(GetIt sl) {
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetUserProfile(sl()));
  sl.registerLazySingleton(() => UpdateUserProfile(sl()));
  sl.registerLazySingleton(() => ClearCache(sl()));
  sl.registerLazySingleton(() => GetAchievements(sl()));
  sl.registerFactory(
    () => ProfileBloc(
      getUserProfile: sl(),
      updateUserProfile: sl(),
      clearCache: sl(),
      getAchievements: sl(),
      clearAnalytics: sl(),
      getGeneralStats: sl(),
    ),
  );
}
