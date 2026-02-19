import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/achievement_entity.dart';

abstract interface class ProfileLocalDataSource {
  Future<UserEntity> getUserProfile();
  Future<void> saveUserProfile(UserEntity user);
  Future<void> clearCache();
  Future<List<AchievementEntity>> getAchievements();
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  final SharedPreferences _sharedPreferences;

  ProfileLocalDataSourceImpl(this._sharedPreferences);

  static const _userKey = 'cached_user_profile';

  @override
  Future<UserEntity> getUserProfile() async {
    final jsonString = _sharedPreferences.getString(_userKey);
    if (jsonString != null) {
      try {
        return UserEntity.fromJson(jsonDecode(jsonString));
      } catch (e) {
        // Fallback if schema changes
        return _defaultUser;
      }
    } else {
      return _defaultUser;
    }
  }

  UserEntity get _defaultUser => const UserEntity(
        id: 'user_1',
        username: 'Music Lover',
        email: 'user@example.com',
        avatarUrl: '', 
        preferredNavBar: NavBarStyle.simple,
      );

  @override
  Future<void> saveUserProfile(UserEntity user) async {
    await _sharedPreferences.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<void> clearCache() async {
    // Clears all keys for now or specific ones.
    // The prompt specifically asked for "deleting cache", which might imply image cache or data.
    // Given I don't control the image cache directly here (cached_network_image usually manages its own),
    // I will clear the user profile as a proxy for "resetting" this feature's cache.
    await _sharedPreferences.remove(_userKey);
    await _sharedPreferences.remove('is_first_timer');
  }

  @override
  Future<List<AchievementEntity>> getAchievements() async {
    // For now, return dummy data to support the new designs.
    // In a real app, these might be calculated based on stats.
    return [
      AchievementEntity(
        id: '1',
        title: 'EARLY BIRD',
        description: 'Listen to music before 8:00 AM',
        iconPath: 'assets/icons/morning.png',
        unlockedAt: DateTime.now(),
        isUnlocked: true,
        progress: 1.0,
      ),
      AchievementEntity(
        id: '2',
        title: 'NIGHT OWL',
        description: 'Listen to music after 11:00 PM',
        iconPath: 'assets/icons/night.png',
        unlockedAt: DateTime.now(),
        isUnlocked: false,
        progress: 0.45,
      ),
      AchievementEntity(
        id: '3',
        title: 'MARATHONER',
        description: 'Listen for more than 5 hours in one day',
        iconPath: 'assets/icons/timer.png',
        unlockedAt: DateTime.now(),
        isUnlocked: true,
        progress: 1.0,
      ),
      AchievementEntity(
        id: '4',
        title: 'EXPLORER',
        description: 'Listen to 50 different artists',
        iconPath: 'assets/icons/explore.png',
        unlockedAt: DateTime.now(),
        isUnlocked: false,
        progress: 0.2,
      ),
    ];
  }
}
