import 'package:music_player/features/artists/domain/entities/artist_entity.dart';
import 'package:on_audio_query/on_audio_query.dart' as lib;

class ArtistMapper {
  static ArtistEntity toEntity(lib.ArtistModel artist) {
    return ArtistEntity(
      id: artist.id,
      name: artist.artist,
      numberOfTracks: artist.numberOfTracks ?? 0,
      numberOfAlbums: artist.numberOfAlbums ?? 0,
    );
  }
}
