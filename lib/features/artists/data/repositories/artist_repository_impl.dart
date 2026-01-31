import 'package:fpdart/fpdart.dart';
import 'package:music_player/core/error/failure.dart';
import 'package:music_player/features/artists/data/datasources/artist_local_datasource.dart';
import 'package:music_player/features/artists/domain/entities/artist_entity.dart';
import 'package:music_player/features/artists/domain/repositories/artist_repository.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/artists/domain/failures/artist_failure.dart';

class ArtistRepositoryImpl implements ArtistRepository {
  final ArtistLocalDataSource dataSource;

  ArtistRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<ArtistEntity>>> getArtists() async {
    try {
      final result = await dataSource.getArtists();
      return Right(result);
    } catch (e) {
      return Left(ArtistFailure('Failed to load artists: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SongEntity>>> getArtistSongs(int artistId) async {
    try {
      final result = await dataSource.getArtistSongs(artistId);
      return Right(result);
    } catch (e) {
      return Left(ArtistFailure('Failed to load artist songs: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getArtistStats(String artistName) async {
    try {
      final result = await dataSource.getArtistStats(artistName);
      return Right(result);
    } catch (e) {
      return Left(ArtistFailure('Failed to load artist stats: $e'));
    }
  }
}
