import 'package:get_it/get_it.dart';
import 'package:music_player/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:music_player/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:music_player/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:music_player/features/onboarding/domain/usecases/cache_first_timer.dart';
import 'package:music_player/features/onboarding/domain/usecases/check_if_user_is_first_timer.dart';
import 'package:music_player/features/onboarding/domain/usecases/log_onboarding_complete.dart';
import 'package:music_player/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:music_player/features/onboarding/presentation/cubit/user_registration_cubit.dart';

void registerOnboardingDependencies(GetIt sl) {
  sl.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => CacheFirstTimer(sl()));
  sl.registerLazySingleton(() => CheckIfUserIsFirstTimer(sl()));
  sl.registerLazySingleton(() => LogOnboardingComplete(sl()));
  sl.registerFactory(() => OnboardingCubit(cacheFirstTimer: sl()));
  sl.registerFactory(
    () => UserRegistrationCubit(
      updateUserProfile: sl(),
      logOnboardingComplete: sl(),
      cacheFirstTimer: sl(),
    ),
  );
}
