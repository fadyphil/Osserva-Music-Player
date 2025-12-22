part of 'playlist_detail_bloc.dart';

@freezed
class PlaylistDetailState with _$PlaylistDetailState {
  const factory PlaylistDetailState.initial() = _Initial;
  const factory PlaylistDetailState.loading() = _Loading;
  const factory PlaylistDetailState.loaded({
    required PlaylistEntity playlist,
    required List<SongEntity> songs,
  }) = _Loaded;
  const factory PlaylistDetailState.failure(String message) = _Failure;
}
