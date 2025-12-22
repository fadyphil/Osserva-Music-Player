part of 'favorites_bloc.dart';

@freezed
class FavoritesState with _$FavoritesState {
  const factory FavoritesState.initial() = _Initial;
  const factory FavoritesState.loading() = _Loading;
  const factory FavoritesState.loaded({
    required Set<int> favoriteIds,
    required List<SongEntity> favoriteSongs,
  }) = _Loaded;
  const factory FavoritesState.failure(String message) = _Failure;
}
