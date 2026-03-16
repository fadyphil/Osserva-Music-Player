import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist_detail_event.freezed.dart';

@freezed
abstract class ArtistDetailEvent with _$ArtistDetailEvent {
  const factory ArtistDetailEvent.loadArtistSongs(
    int artistId,
    String artistName,
  ) = LoadArtistSongs;
}
