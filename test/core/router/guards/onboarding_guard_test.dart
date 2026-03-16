import 'package:auto_route/auto_route.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:osserva/core/di/init_dependencies.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/router/app_router.dart';
import 'package:osserva/core/router/guards/onboarding_guard.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/onboarding/domain/usecases/check_if_user_is_first_timer.dart';

class MockCheckIfUserIsFirstTimer extends Mock
    implements CheckIfUserIsFirstTimer {}

class MockNavigationResolver extends Mock implements NavigationResolver {}

class MockStackRouter extends Mock implements StackRouter {}

class FakeFailure extends Failure {
  FakeFailure(super.message);
}

void main() {
  late OnboardingGuard guard;
  late MockCheckIfUserIsFirstTimer mockCheckIfUserIsFirstTimer;
  late MockNavigationResolver mockResolver;
  late MockStackRouter mockRouter;

  setUpAll(() {
    registerFallbackValue(OnboardingRoute());
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockCheckIfUserIsFirstTimer = MockCheckIfUserIsFirstTimer();
    mockResolver = MockNavigationResolver();
    mockRouter = MockStackRouter();

    // Reset GetIt to ensure clean state
    serviceLocator.reset();
    // Register mock in service locator
    serviceLocator.registerSingleton<CheckIfUserIsFirstTimer>(
      mockCheckIfUserIsFirstTimer,
    );

    guard = OnboardingGuard();

    // Stub router replace
    when(() => mockRouter.replace(any())).thenAnswer((_) async => null);
  });

  tearDown(() {
    serviceLocator.reset();
  });

  test('should redirect to OnboardingRoute if user is first timer', () async {
    // ARRANGE
    when(
      () => mockCheckIfUserIsFirstTimer(any()),
    ).thenAnswer((_) async => const Right(true));

    // ACT
    guard.onNavigation(mockResolver, mockRouter);

    // Wait for microtasks
    await Future.delayed(Duration.zero);

    // ASSERT
    verify(() => mockResolver.next(false)).called(1);
    verify(
      () => mockRouter.replace(any(that: isA<OnboardingRoute>())),
    ).called(1);
  });

  test('should proceed if user is NOT first timer', () async {
    // ARRANGE
    when(
      () => mockCheckIfUserIsFirstTimer(any()),
    ).thenAnswer((_) async => const Right(false));

    // ACT
    guard.onNavigation(mockResolver, mockRouter);

    // Wait for microtasks
    await Future.delayed(Duration.zero);

    // ASSERT
    verify(() => mockResolver.next(true)).called(1);
    verifyNever(() => mockRouter.replace(any()));
  });

  test('should redirect to OnboardingRoute if check fails', () async {
    // ARRANGE
    when(
      () => mockCheckIfUserIsFirstTimer(any()),
    ).thenAnswer((_) async => Left(FakeFailure('Error')));

    // ACT
    guard.onNavigation(mockResolver, mockRouter);

    // Wait for microtasks
    await Future.delayed(Duration.zero);

    // ASSERT
    verify(() => mockResolver.next(false)).called(1);
    verify(
      () => mockRouter.replace(any(that: isA<OnboardingRoute>())),
    ).called(1);
  });
}
