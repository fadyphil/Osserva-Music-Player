part of 'playlist_bloc.dart';

@freezed
abstract class PlaylistState with _$PlaylistState {
  const factory PlaylistState.initial() = _Initial;
  const factory PlaylistState.loading() = _Loading;
  const factory PlaylistState.loaded(List<PlaylistEntity> playlists) = _Loaded;
  const factory PlaylistState.failure(String message) = _Failure;
}
