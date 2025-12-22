part of 'playlist_detail_bloc.dart';

@freezed
class PlaylistDetailEvent with _$PlaylistDetailEvent {
  const factory PlaylistDetailEvent.loadPlaylistDetail(PlaylistEntity playlist) = _LoadPlaylistDetail;
  const factory PlaylistDetailEvent.addSong(SongEntity song) = _AddSong;
  const factory PlaylistDetailEvent.removeSong(int songId) = _RemoveSong;
  const factory PlaylistDetailEvent.editPlaylist({
    String? name,
    String? description,
    String? imagePath,
  }) = _EditPlaylistDetail;
}
