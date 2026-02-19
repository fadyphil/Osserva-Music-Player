import 'package:freezed_annotation/freezed_annotation.dart';

part 'artists_event.freezed.dart';

@freezed
class ArtistsEvent with _$ArtistsEvent {
  const factory ArtistsEvent.loadArtists() = LoadArtists;
}
