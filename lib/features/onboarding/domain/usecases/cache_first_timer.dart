import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/onboarding/domain/repositories/onboarding_repository.dart';

class CacheFirstTimer implements UseCase<void, NoParams> {
  final OnboardingRepository onboardingRepository;

  CacheFirstTimer(this.onboardingRepository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await onboardingRepository.cacheFirstTimer();
  }
}
