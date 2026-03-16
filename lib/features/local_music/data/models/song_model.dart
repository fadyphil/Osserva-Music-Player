import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:on_audio_query/on_audio_query.dart' as lib;

class SongMapper {
  static SongEntity toEntity(lib.SongModel song) {
    return SongEntity(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      album: song.album ?? 'Unknown Album',
      albumId: song.albumId,
      path: song.data,
      duration: (song.duration ?? 0.0).toDouble(),
      size: song.size,
    );
  }
}
