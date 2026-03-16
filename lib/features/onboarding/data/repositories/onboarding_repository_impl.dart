import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:osserva/features/onboarding/domain/failure/onboarding_failure.dart';
import 'package:osserva/features/onboarding/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource onboardingLocalDataSource;

  OnboardingRepositoryImpl(this.onboardingLocalDataSource);

  @override
  Future<Either<Failure, void>> cacheFirstTimer() async {
    try {
      await onboardingLocalDataSource.cacheFirstTimer();
      return const Right(null);
    } catch (e) {
      return Left(OnboardingFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkIfUserIsFirstTimer() async {
    try {
      final result = await onboardingLocalDataSource.checkIfUserIsFirstTimer();
      return Right(result);
    } catch (e) {
      return Left(OnboardingFailure(e.toString()));
    }
  }
}
