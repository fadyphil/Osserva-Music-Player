part of 'playlist_bloc.dart';

@freezed
class PlaylistEvent with _$PlaylistEvent {
  const factory PlaylistEvent.loadPlaylists() = _LoadPlaylists;
  const factory PlaylistEvent.createPlaylist({
    required String name,
    required String description,
    String? imagePath,
  }) = _CreatePlaylist;
  const factory PlaylistEvent.deletePlaylist(int playlistId) = _DeletePlaylist;
  const factory PlaylistEvent.addSongToPlaylist({
    required int playlistId,
    required SongEntity song,
  }) = _AddSongToPlaylist;
}
