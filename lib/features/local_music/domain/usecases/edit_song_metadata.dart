import 'dart:typed_data';

import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/local_music/domain/repositories/music_repository.dart';

class EditSongMetadataParams {
  final SongEntity song;
  final String? title;
  final String? artist;
  final String? album;
  final String? genre;
  final String? year;
  final Uint8List? artworkBytes;

  EditSongMetadataParams({
    required this.song,
    this.title,
    this.artist,
    this.album,
    this.genre,
    this.year,
    this.artworkBytes,
  });
}

class EditSongMetadata implements UseCase<bool, EditSongMetadataParams> {
  final MusicRepository repository;

  EditSongMetadata(this.repository);

  @override
  Future<Either<Failure, bool>> call(EditSongMetadataParams params) async {
    return await repository.editSongMetadata(params);
  }
}
