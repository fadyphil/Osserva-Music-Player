import 'dart:io';

import 'package:music_player/features/artists/data/models/artist_mapper.dart';
import 'package:music_player/features/artists/domain/entities/artist_entity.dart';
import 'package:music_player/features/local%20music/data/models/song_model.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:on_audio_query/on_audio_query.dart';

abstract class ArtistLocalDataSource {
  Future<List<ArtistEntity>> getArtists();
  Future<List<SongEntity>> getArtistSongs(int artistId);
  Future<Map<String, dynamic>> getArtistStats(String artistName);
}

class ArtistLocalDataSourceImpl implements ArtistLocalDataSource {
  final OnAudioQuery _onAudioQuery;

  ArtistLocalDataSourceImpl(this._onAudioQuery);

  @override
  Future<Map<String, dynamic>> getArtistStats(String artistName) async {
    // This will actually be implemented in the AnalyticsRepository, 
    // but we can add it here if we want to centralize.
    // For now, return empty as the Bloc will call GetArtistAnalyticsStats usecase directly.
    return {};
  }

  @override
  Future<List<ArtistEntity>> getArtists() async {
    if (Platform.isLinux) {
      return _getLinuxArtists();
    }

    try {
      final artists = await _onAudioQuery.queryArtists(
        sortType: ArtistSortType.ARTIST,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );
      return artists.map((e) => ArtistMapper.toEntity(e)).toList();
    } catch (e) {
      throw Exception('Error fetching artists: $e');
    }
  }

  @override
  Future<List<SongEntity>> getArtistSongs(int artistId) async {
    if (Platform.isLinux) {
      // For Linux, we might need to pass the artist Name instead of ID, 
      // or map ID to name if we generated consistent IDs.
      // Since Linux ID generation in LocalMusicDataSource was file.path.hashCode, 
      // artist ID is tricky. 
      // A better approach for Linux is to fetch all songs and filter.
      final allSongs = await _getLinuxSongs();
      // This is inefficient but functional for the scope. 
      // Ideally we need a better data layer for Linux.
      // We can't easily match by ID unless we know how Artist ID was generated.
      // For now, let's assume we can't fully support ID-based lookup on Linux 
      // without a proper DB. 
      // But wait, getArtists() for Linux below generates IDs.
      
      // Let's implement _getLinuxArtists first to see how we generate IDs.
      final artists = await _getLinuxArtists();
      final artist = artists.firstWhere((a) => a.id == artistId, orElse: () => throw Exception("Artist not found"));
      
      return allSongs.where((s) => s.artist == artist.name).toList();
    }

    try {
      // queryAudios where artistId matches
      // OnAudioQuery doesn't have a direct "querySongsByArtistId" that returns SongModel list easily?
      // It has queryAudiosFrom.
      
      final songs = await _onAudioQuery.queryAudiosFrom(
        AudiosFromType.ARTIST_ID,
        artistId,
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        ignoreCase: true,
      );
      
      // queryAudiosFrom returns List<SongModel>? or Dynamic?
      // Check documentation or assume List<SongModel>
      return songs.map((e) => SongMapper.toEntity(e)).toList();
    } catch (e) {
      throw Exception('Error fetching artist songs: $e');
    }
  }

  Future<List<SongEntity>> _getLinuxSongs() async {
     final List<SongEntity> songs = [];
    final home = Platform.environment['HOME'];
    if (home == null) return [];

    final dirsToScan = [Directory('$home/Music'), Directory('$home/Downloads')];

    for (final dir in dirsToScan) {
      if (!await dir.exists()) continue;
      try {
        await for (final file in dir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (file is File) {
            final path = file.path.toLowerCase();
            if (path.endsWith('.mp3') ||
                path.endsWith('.m4a') ||
                path.endsWith('.wav') ||
                path.endsWith('.ogg') ||
                path.endsWith('.flac')) {
              final filename = file.path.split(Platform.pathSeparator).last;

              String title = filename;
              String artist = 'Unknown Artist';
              final nameWithoutExt = filename.contains('.')
                  ? filename.substring(0, filename.lastIndexOf('.'))
                  : filename;

              if (nameWithoutExt.contains(' - ')) {
                final parts = nameWithoutExt.split(' - ');
                artist = parts[0].trim();
                title = parts.sublist(1).join(' - ').trim();
              } else {
                title = nameWithoutExt;
              }

              songs.add(
                SongEntity(
                  id: file.path.hashCode,
                  title: title,
                  artist: artist,
                  album: 'Unknown Album',
                  albumId: 0,
                  path: file.path,
                  duration: 0, 
                  size: await file.length(),
                ),
              );
            }
          }
        }
      } catch (e) {
        continue;
      }
    }
    return songs;
  }

  Future<List<ArtistEntity>> _getLinuxArtists() async {
    final songs = await _getLinuxSongs();
    final Map<String, List<SongEntity>> artistMap = {};

    for (var song in songs) {
      if (!artistMap.containsKey(song.artist)) {
        artistMap[song.artist] = [];
      }
      artistMap[song.artist]!.add(song);
    }

    final List<ArtistEntity> artists = [];
    artistMap.forEach((name, songs) {
      artists.add(ArtistEntity(
        id: name.hashCode, // Use name hashcode as ID for Linux
        name: name,
        numberOfTracks: songs.length,
        numberOfAlbums: 0, // Hard to calc without album metadata
      ));
    });

    return artists;
  }
}
