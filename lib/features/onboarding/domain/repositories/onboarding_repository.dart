import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';

abstract interface class OnboardingRepository {
  Future<Either<Failure, void>> cacheFirstTimer();
  Future<Either<Failure, bool>> checkIfUserIsFirstTimer();
}
