import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/features/artists/domain/entities/artist_entity.dart';

part 'artists_state.freezed.dart';

@freezed
class ArtistsState with _$ArtistsState {
  const factory ArtistsState.initial() = _Initial;
  const factory ArtistsState.loading() = _Loading;
  const factory ArtistsState.loaded(List<ArtistEntity> artists) = _Loaded;
  const factory ArtistsState.error(String message) = _Error;
}
