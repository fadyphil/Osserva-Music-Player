import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/local%20music/domain/repositories/music_repository.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';

class DeleteSong implements UseCase<bool, SongEntity> {
  final MusicRepository musicRepository;
  final PlaylistRepository playlistRepository;
  final AnalyticsRepository analyticsRepository;

  DeleteSong(this.musicRepository, this.playlistRepository, this.analyticsRepository);

  @override
  Future<Either<Failure, bool>> call(SongEntity params) async {
    // 1. Delete from Playlists
    // We try to remove it, but even if it fails (e.g. not in any playlist), we proceed.
    await playlistRepository.removeSongFromAllPlaylists(params.id);
    
    // 2. Delete from Analytics
    await analyticsRepository.deleteSongAnalytics(params.id);

    // 3. Delete File (Last step)
    return await musicRepository.deleteSong(params.path);
  }
}
