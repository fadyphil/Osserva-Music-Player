import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/library/presentation/widgets/library_toggle_bar.dart';
import 'package:music_player/features/library/presentation/widgets/library_tracks_view.dart';
import 'package:music_player/features/library/presentation/widgets/library_playlists_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:music_player/features/local%20music/presentation/managers/local_music_state.dart';

@RoutePage()
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> with AutomaticKeepAliveClientMixin {
  LibraryViewMode _viewMode = LibraryViewMode.tracks;
  bool _hasPermission = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndFetch();
  }

  Future<void> _checkPermissionAndFetch() async {
    // Permission Logic reused from SongListPage
    Permission permission;
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      _fetchSongs();
      return;
    }
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        permission = Permission.audio;
      } else {
        permission = Permission.storage;
      }
    } else {
      permission = Permission.mediaLibrary;
    }

    final status = await permission.status;

    if (status.isGranted) {
      _fetchSongs();
    } else if (status.isDenied) {
      final result = await permission.request();
      if (result.isGranted) {
        _fetchSongs();
      }
    }
  }

  void _fetchSongs() {
    if (mounted) {
      setState(() {
        _hasPermission = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BlocProvider(
      create: (_) {
        final bloc = serviceLocator<LocalMusicBloc>();
        // Restore sort preference
        final prefs = serviceLocator<SharedPreferences>();
        final savedIndex = prefs.getInt('local_songs_sort_option');
        if (savedIndex != null &&
            savedIndex >= 0 &&
            savedIndex < SortOption.values.length) {
          bloc.add(LocalMusicEvent.sortSongs(SortOption.values[savedIndex]));
        }

        if (_hasPermission) {
          bloc.add(const LocalMusicEvent.getLocalSongs());
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppPallete.backgroundColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text(
            "Library",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            // Toggle Bar
            LibraryToggleBar(
              currentMode: _viewMode,
              onModeChanged: (mode) {
                HapticFeedback.lightImpact();
                setState(() {
                  _viewMode = mode;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Content
            Expanded(
              child: !_hasPermission 
                ? _PermissionRequestView(onGrant: _checkPermissionAndFetch)
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _viewMode == LibraryViewMode.tracks
                        ? const LibraryTracksView()
                        : const LibraryPlaylistsView(),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionRequestView extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionRequestView({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, size: 64, color: AppPallete.grey),
          const SizedBox(height: 16),
          const Text("Library Locked", style: TextStyle(color: Colors.white, fontSize: 20)),
          const SizedBox(height: 8),
          const Text("Permission required to access local files", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onGrant,
            style: FilledButton.styleFrom(backgroundColor: AppPallete.primaryColor),
            child: const Text("Grant Access"),
          )
        ],
      ),
    );
  }
}
