import 'dart:io';
import 'dart:typed_data';

import 'package:audiotags/audiotags.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:music_player/features/local%20music/data/models/song_model.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

abstract class LocalMusicDatasource {
  Future<List<SongEntity>> getLocalMusic();
  Future<SongEntity?> getSongById(int id);
  Future<bool> deleteSong({required int id, required String path});
  Future<bool> editSongMetadata({
    required String path,
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? year,
    Uint8List? artworkBytes,
  });
}

class LocalMusicDatasourceImpl implements LocalMusicDatasource {
  final MediaStore _mediaStore;
  final OnAudioQuery _onAudioQuery;
  LocalMusicDatasourceImpl(this._onAudioQuery, this._mediaStore);

  @override
  Future<bool> deleteSong({required int id, required String path}) async {
    // 1. Desktop Implementation
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      try {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
        return false;
      } catch (e) {
        throw Exception('Failed to delete on Desktop: $e');
      }
    }

    // 2. Android Implementation
    if (Platform.isAndroid) {
      try {
        // Construct the Content URI using the ID
        // This URI tells Android EXACTLY which database entry to modify
        final String uriString = 'content://media/external/audio/media/$id';

        // Use the MediaStore plugin to trigger the native permission popup
        final result = await _mediaStore.deleteFileUsingUri(
          uriString: uriString,
        );

        return result;
      } catch (e) {
        // Fallback: Try standard File delete (Works for files YOUR app created)
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
            await _onAudioQuery.scanMedia(path); // Update index
            return true;
          }
        } catch (fallbackError) {
          // Both deletion attempts failed
        }
        return false;
      }
    }

    return false;
  }

  @override
  Future<bool> editSongMetadata({
    required String path,
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? year,
    Uint8List? artworkBytes,
  }) async {
    try {
      await _ensureStoragePermission();

      // Read existing tags to perform a partial update
      final Tag? originalTags = await _readExistingTags(path);

      final List<Picture> artwork = _prepareArtwork(
        artworkBytes,
        originalTags?.pictures,
      );

      final int? releaseYear = _parseYear(year) ?? originalTags?.year;

      final Tag updatedTag = Tag(
        title: title ?? originalTags?.title,
        artist: artist ?? originalTags?.artist,
        album: album ?? originalTags?.album,
        genre: genre ?? originalTags?.genre,
        year: releaseYear,
        pictures: artwork,
      );

      await AudioTags.write(path, updatedTag);

      if (Platform.isAndroid) {
        // Notify the system media store to re-index the file with new metadata
        await _onAudioQuery.scanMedia(path);
      }

      return true;
    } catch (e) {
      // Errors are handled by returning false; 
      // Higher layers (Repository) will map this to a Failure.
      return false;
    }
  }

  Future<void> _ensureStoragePermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.manageExternalStorage.status;
      if (!status.isGranted) {
        final requestStatus = await Permission.manageExternalStorage.request();
        if (!requestStatus.isGranted) {
          throw Exception(
            "Access Denied: 'All Files Access' is required for metadata editing.",
          );
        }
      }
    }
  }

  Future<Tag?> _readExistingTags(String path) async {
    try {
      return await AudioTags.read(path);
    } catch (_) {
      // If reading fails, we proceed with null to allow a "fresh" write
      return null;
    }
  }

  List<Picture> _prepareArtwork(Uint8List? newArtwork, List<Picture>? existingArtwork) {
    if (newArtwork != null) {
      return [
        Picture(
          bytes: newArtwork,
          mimeType: MimeType.none, // We use none as we don't strictly need to specify
          pictureType: PictureType.coverFront,
        ),
      ];
    }
    return existingArtwork ?? [];
  }

  int? _parseYear(String? yearString) {
    if (yearString == null || yearString.isEmpty) return null;
    return int.tryParse(yearString);
  }

  @override
  Future<SongEntity?> getSongById(int id) async {
    // 1. Try Linux Native first if applicable
    if (Platform.isLinux) {
      final allSongs = await _getLinuxSongs();
      try {
        return allSongs.firstWhere((s) => s.id == id);
      } catch (e) {
        return null;
      }
    }

    // 2. Use OnAudioQuery for others
    try {
      final songs = await _onAudioQuery.querySongs(
        sortType: SongSortType.DATE_ADDED,
        orderType: OrderType.DESC_OR_GREATER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      final match = songs.firstWhere((s) => s.id == id);
      return SongMapper.toEntity(match);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<SongEntity>> getLocalMusic() async {
    try {
      // Linux Native Implementation: Manually scan directories
      // This bypasses on_audio_query which may lack native implementations on some distros.
      if (Platform.isLinux) {
        return _getLinuxSongs();
      }

      List<SongModel> rawsongs;

      if (Platform.isMacOS || Platform.isWindows) {
        rawsongs = await _onAudioQuery.querySongs();
      } else {
        rawsongs = await _onAudioQuery.querySongs(
          sortType: SongSortType.DATE_ADDED,
          orderType: OrderType.DESC_OR_GREATER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
      }
      // 2. Platform-Specific Filtering
      final validSongs = rawsongs.where((s) {
        // Common Check: Duration must be > 5 seconds (filters blips/notifications)
        final bool hasDuration = (s.duration ?? 0) > 5000;

        if (!hasDuration) return false;

        // Desktop Check:
        // On Linux, 'isMusic' relies on file metadata which might be missing.
        // Since the library scans the Music folder, we assume files found are valid audio.
        if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          return true;
        }

        // Mobile Check:
        // On Android, we must strictly filter out Ringtones/Notifications/Alarms
        return (s.isMusic == true || s.isPodcast == true);
      }).toList();

      return validSongs.map((song) => SongMapper.toEntity(song)).toList();
    } catch (e) {
      throw Exception('Error getting local music: $e');
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

              // Heuristic: "Artist - Title.mp3"
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
                  duration: 0, // Duration unknown without metadata parser
                  size: await file.length(),
                ),
              );
            }
          }
        }
      } catch (e) {
        // Ignore permission errors or specific dir errors
        continue;
      }
    }
    return songs;
  }
}
