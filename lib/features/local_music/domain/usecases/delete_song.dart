import 'package:fpdart/fpdart.dart';
import 'package:osserva/core/error/failure.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/local_music/domain/repositories/music_repository.dart';
import 'package:osserva/features/playlists/domain/repositories/playlist_repository.dart';

class DeleteSong implements UseCase<bool, SongEntity> {
  final MusicRepository musicRepository;
  final PlaylistRepository playlistRepository;
  final AnalyticsRepository analyticsRepository;

  DeleteSong(
    this.musicRepository,
    this.playlistRepository,
    this.analyticsRepository,
  );

  @override
  Future<Either<Failure, bool>> call(SongEntity params) async {
    // 1. Delete from Playlists
    // We try to remove it, but even if it fails (e.g. not in any playlist), we proceed.
    await playlistRepository.removeSongFromAllPlaylists(params.id);

    // 2. Delete from Analytics
    await analyticsRepository.deleteSongAnalytics(params.id);

    // 3. Delete File (Last step)
    return await musicRepository.deleteSong(params.id, params.path);
  }
}
