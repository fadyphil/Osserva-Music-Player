import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../domain/usecases/get_user_profile.dart';
import '../../domain/usecases/update_user_profile.dart';
import '../../domain/usecases/clear_cache.dart';
import '../../domain/usecases/get_achievements.dart';
import '../../../analytics/domain/usecases/clear_analytics.dart';
import '../../../analytics/domain/usecases/get_general_stats.dart';
import '../../../analytics/domain/entities/analytics_enums.dart';
import '../../../analytics/domain/entities/analytics_stats.dart';
import '../../../../core/usecases/usecase.dart';

part 'profile_event.dart';
part 'profile_state.dart';
part 'profile_bloc.freezed.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetUserProfile _getUserProfile;
  final UpdateUserProfile _updateUserProfile;
  final ClearCache _clearCache;
  final GetAchievements _getAchievements;
  final ClearAnalytics _clearAnalytics;
  final GetGeneralStats _getGeneralStats;

  ProfileBloc({
    required GetUserProfile getUserProfile,
    required UpdateUserProfile updateUserProfile,
    required ClearCache clearCache,
    required GetAchievements getAchievements,
    required ClearAnalytics clearAnalytics,
    required GetGeneralStats getGeneralStats,
  })  : _getUserProfile = getUserProfile,
        _updateUserProfile = updateUserProfile,
        _clearCache = clearCache,
        _getAchievements = getAchievements,
        _clearAnalytics = clearAnalytics,
        _getGeneralStats = getGeneralStats,
        super(const ProfileState.initial()) {
    on<_LoadProfile>(_onLoadProfile);
    on<_UpdateProfile>(_onUpdateProfile);
    on<_ClearCache>(_onClearCache);
    on<_ChangeNavBarStyle>(_onChangeNavBarStyle);
  }

  Future<void> _onLoadProfile(_LoadProfile event, Emitter<ProfileState> emit) async {
    emit(const ProfileState.loading());
    
    final userResult = await _getUserProfile(NoParams());
    final achievementsResult = await _getAchievements(NoParams());
    final statsResult = await _getGeneralStats(TimeFrame.all);

    userResult.fold(
      (failure) => emit(ProfileState.error(failure.message)),
      (user) {
        achievementsResult.fold(
          (failure) => emit(ProfileState.error(failure.message)),
          (achievements) {
            statsResult.fold(
              (failure) => emit(ProfileState.error(failure.message)),
              (stats) => emit(ProfileState.loaded(
                user: user,
                achievements: achievements,
                listeningStats: stats,
              )),
            );
          },
        );
      },
    );
  }

  Future<void> _onUpdateProfile(_UpdateProfile event, Emitter<ProfileState> emit) async {
    // Note: We don't emit loading here because we want to preserve the current state (stats/achievements)
    // and just update the user part if possible, or reload everything.
    // For simplicity, let's reload everything after update.
    final result = await _updateUserProfile(event.user);
    result.fold(
      (failure) => emit(ProfileState.error(failure.message)),
      (user) => add(const ProfileEvent.loadProfile()),
    );
  }

  Future<void> _onClearCache(_ClearCache event, Emitter<ProfileState> emit) async {
    emit(const ProfileState.loading());
    
    // 1. Clear Profile Cache
    final cacheResult = await _clearCache(NoParams());
    
    // 2. Clear Analytics
    final analyticsResult = await _clearAnalytics(NoParams());

    if (cacheResult.isLeft()) {
      cacheResult.fold((l) => emit(ProfileState.error(l.message)), (_) {});
      return;
    }

    if (analyticsResult.isLeft()) {
       analyticsResult.fold((l) => emit(ProfileState.error(l.message)), (_) {});
       return;
    }

    emit(const ProfileState.cacheCleared());
  }

  Future<void> _onChangeNavBarStyle(_ChangeNavBarStyle event, Emitter<ProfileState> emit) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final updatedUser = currentState.user.copyWith(preferredNavBar: event.style);
      add(ProfileEvent.updateProfile(updatedUser));
    }
  }
}
