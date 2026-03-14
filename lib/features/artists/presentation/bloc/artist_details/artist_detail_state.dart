import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';

part 'artist_detail_state.freezed.dart';

@freezed
class ArtistDetailState with _$ArtistDetailState {
  const factory ArtistDetailState.initial() = _Initial;
  const factory ArtistDetailState.loading() = _Loading;
  const factory ArtistDetailState.loaded(
    List<SongEntity> songs, {
    Map<String, dynamic>? analytics,
  }) = _Loaded;
  const factory ArtistDetailState.error(String message) = _Error;
}
