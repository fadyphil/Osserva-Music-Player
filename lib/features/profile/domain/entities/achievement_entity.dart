import 'package:freezed_annotation/freezed_annotation.dart';

part 'achievement_entity.freezed.dart';
part 'achievement_entity.g.dart';

@freezed
abstract class AchievementEntity with _$AchievementEntity {
  const factory AchievementEntity({
    required String id,
    required String title,
    required String description,
    required String iconPath,
    required DateTime unlockedAt,
    required bool isUnlocked,
    @Default(0.0) double progress,
  }) = _AchievementEntity;

  factory AchievementEntity.fromJson(Map<String, dynamic> json) =>
      _$AchievementEntityFromJson(json);
}
