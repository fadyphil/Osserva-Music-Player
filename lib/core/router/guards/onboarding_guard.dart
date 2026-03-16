import 'package:auto_route/auto_route.dart';
import 'package:osserva/core/di/init_dependencies.dart';
import 'package:osserva/core/router/app_router.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/onboarding/domain/usecases/check_if_user_is_first_timer.dart';

class OnboardingGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final checkIfUserIsFirstTimer = serviceLocator<CheckIfUserIsFirstTimer>();

    final result = await checkIfUserIsFirstTimer(NoParams());

    result.fold(
      (failure) {
        // If error checking (e.g. shared prefs failed), default to onboarding for safety
        resolver.next(false);
        router.replace(OnboardingRoute());
      },
      (isFirstTimer) {
        if (isFirstTimer) {
          resolver.next(false);
          router.replace(OnboardingRoute());
        } else {
          resolver.next(true);
        }
      },
    );
  }
}
