import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/user_entity.dart';
import '../entities/achievement_entity.dart';

abstract interface class ProfileRepository {
  Future<Either<Failure, UserEntity>> getUserProfile();
  Future<Either<Failure, UserEntity>> updateUserProfile(UserEntity user);
  Future<Either<Failure, void>> clearCache();
  Future<Either<Failure, List<AchievementEntity>>> getAchievements();
}
