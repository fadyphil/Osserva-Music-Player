import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
part 'local_music_state.freezed.dart';

enum SortOption {
  titleAz('Title (A-Z)'),
  titleZa('Title (Z-A)'),
  artistAz('Artist (A-Z)'),
  dateAdded('Last Added'), // Using ID as proxy
  duration('Duration'),
  mostPlayed('Most Played');

  final String label;
  const SortOption(this.label);
}

@freezed
class LocalMusicState with _$LocalMusicState {
  const factory LocalMusicState.initial() = _Initial;
  const factory LocalMusicState.loading() = _Loading;
  const factory LocalMusicState.loaded({
    required List<SongEntity> allSongs,
    required List<SongEntity> processedSongs,
    @Default(SortOption.dateAdded) SortOption sortOption,

    @Default(false) bool isSearching,
    @Default('') String searchQuery,
    @Default(false) bool hasPermission,
    @Default({}) Map<int, int> playCounts,
  }) = _Loaded;
  const factory LocalMusicState.failure(Failure failure) = _Error;
}
