import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';

abstract class UseCase<type, Params> {
  Future<Either<Failure, type>> call(Params params);
}

class NoParams<type> {}
