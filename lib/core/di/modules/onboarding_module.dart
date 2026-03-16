import 'package:get_it/get_it.dart';
import 'package:osserva/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:osserva/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:osserva/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:osserva/features/onboarding/domain/usecases/cache_first_timer.dart';
import 'package:osserva/features/onboarding/domain/usecases/check_if_user_is_first_timer.dart';
import 'package:osserva/features/onboarding/domain/usecases/log_onboarding_complete.dart';
import 'package:osserva/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:osserva/features/onboarding/presentation/cubit/user_registration_cubit.dart';

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
