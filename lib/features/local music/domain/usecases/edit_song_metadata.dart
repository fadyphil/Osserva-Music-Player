import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/local%20music/domain/repositories/music_repository.dart';

class EditSongMetadataParams {
  final SongEntity song;
  final String title;
  final String artist;
  final String album;
  final String? genre;
  final String? lyrics;

  EditSongMetadataParams({
    required this.song,
    required this.title,
    required this.artist,
    required this.album,
    this.genre,
    this.lyrics,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      if (genre != null) 'genre': genre,
      if (lyrics != null) 'lyrics': lyrics,
    };
  }
}

class EditSongMetadata implements UseCase<bool, EditSongMetadataParams> {
  final MusicRepository repository;

  EditSongMetadata(this.repository);

  @override
  Future<Either<Failure, bool>> call(EditSongMetadataParams params) async {
    return await repository.editSongMetadata(params.song, params.toMap());
  }
}
