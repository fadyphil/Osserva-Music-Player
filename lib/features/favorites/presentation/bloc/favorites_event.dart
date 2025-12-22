part of 'favorites_bloc.dart';

@freezed
class FavoritesEvent with _$FavoritesEvent {
  const factory FavoritesEvent.loadFavorites() = _LoadFavorites;
  const factory FavoritesEvent.toggleFavorite(SongEntity song) = _ToggleFavorite;
}
