import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/onboarding/domain/repositories/onboarding_repository.dart';

class CheckIfUserIsFirstTimer implements UseCase<bool, NoParams> {
  final OnboardingRepository onboardingRepository;

  CheckIfUserIsFirstTimer(this.onboardingRepository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await onboardingRepository.checkIfUserIsFirstTimer();
  }
}
