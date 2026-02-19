import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/achievement_entity.dart';
import '../repositories/profile_repository.dart';

class GetAchievements implements UseCase<List<AchievementEntity>, NoParams> {
  final ProfileRepository _repository;

  GetAchievements(this._repository);

  @override
  Future<Either<Failure, List<AchievementEntity>>> call(NoParams params) async {
    return await _repository.getAchievements();
  }
}
