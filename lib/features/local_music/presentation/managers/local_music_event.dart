import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/local_music/presentation/managers/local_music_state.dart';
part 'local_music_event.freezed.dart';

@freezed
class LocalMusicEvent with _$LocalMusicEvent {
  const factory LocalMusicEvent.getLocalSongs() = GetLocalSongs;
  const factory LocalMusicEvent.searchSongs(String query) = SearchSongs;
  const factory LocalMusicEvent.sortSongs(SortOption option) = SortSongs;
  const factory LocalMusicEvent.deleteSong(SongEntity song) = DeleteSongEvent;
  const factory LocalMusicEvent.editSong({
    required SongEntity song,
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? year,
    Uint8List? artworkBytes,
  }) = EditSongEvent;
}
