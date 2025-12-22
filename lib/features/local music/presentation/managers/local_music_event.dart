import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_state.dart';
part 'local_music_event.freezed.dart';

@freezed
class LocalMusicEvent with _$LocalMusicEvent {
  const factory LocalMusicEvent.getLocalSongs() = GetLocalSongs;
  const factory LocalMusicEvent.searchSongs(String query) = SearchSongs;
  const factory LocalMusicEvent.sortSongs(SortOption option) = SortSongs;
}
