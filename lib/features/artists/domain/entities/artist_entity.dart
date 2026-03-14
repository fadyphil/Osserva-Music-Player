import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/features/analytics/domain/entities/artist_stats.dart';

part 'artist_entity.freezed.dart';

@freezed
abstract class ArtistEntity with _$ArtistEntity {
  const factory ArtistEntity({
    required int id,
    required String name,
    required int numberOfTracks,
    required int numberOfAlbums,
    ArtistStats? analytics,
  }) = _ArtistEntity;
}
