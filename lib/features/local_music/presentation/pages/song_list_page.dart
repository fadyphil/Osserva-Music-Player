import 'dart:async';
import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_state.dart';
import 'package:music_player/features/local_music/presentation/widgets/song_list_tile.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class SongListPage extends StatefulWidget {
  const SongListPage({super.key});

  @override
  State<SongListPage> createState() => _SongListPageState();
}

class _SongListPageState extends State<SongListPage>
    with WidgetsBindingObserver {
  bool _hasPermission = false;
  final TextEditingController _searchController = TextEditingController();
  static const String _sortPrefKey = 'local_songs_sort_option';

  /// Held as a field so we can dispatch events from anywhere (initState,
  /// lifecycle callbacks, sort callback) without needing context.read.
  late final LocalMusicBloc _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bloc = serviceLocator<LocalMusicBloc>();

    // Restore saved sort preference into _pendingSort BEFORE the load fires.
    final prefs = serviceLocator<SharedPreferences>();
    final savedIndex = prefs.getInt(_sortPrefKey);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < SortOption.values.length) {
      _bloc.add(LocalMusicEvent.sortSongs(SortOption.values[savedIndex]));
    }

    _checkPermissionAndFetch();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndFetch();
    }
  }

  Future<void> _checkPermissionAndFetch() async {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      _onPermissionGranted();
      return;
    }

    Permission permission;
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      permission = androidInfo.version.sdkInt >= 33
          ? Permission.audio
          : Permission.storage;
    } else {
      permission = Permission.mediaLibrary;
    }

    final status = await permission.status;
    if (status.isGranted) {
      _onPermissionGranted();
    } else if (status.isDenied) {
      final result = await permission.request();
      if (result.isGranted) _onPermissionGranted();
    }
  }

  void _onPermissionGranted() {
    if (!mounted) return;
    setState(() => _hasPermission = true);
    _bloc.add(const LocalMusicEvent.getLocalSongs());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: Stack(
          children: [
            if (!_hasPermission)
              _PermissionRequestView(onGrant: _checkPermissionAndFetch),
            if (_hasPermission)
              BlocConsumer<LocalMusicBloc, LocalMusicState>(
                listener: (context, state) {
                  state.mapOrNull(
                    loaded: (loadedState) {
                      if (loadedState.searchQuery != _searchController.text) {
                        _searchController.text = loadedState.searchQuery;
                      }
                    },
                  );
                },
                builder: (context, state) {
                  return state.when(
                    initial: () =>
                        const Center(child: CircularProgressIndicator()),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppPallete.accent,
                      ),
                    ),
                    failure: (failure) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Unable to load songs.\n${failure.message}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    loaded:
                        (
                          allSongs,
                          processedSongs,
                          sortOption,
                          isSearching,
                          searchQuery,
                          hasPermission,
                          playCounts,
                        ) {
                          return _SliverSongLayout(
                            songs: processedSongs,
                            totalSongs: allSongs.length,
                            searchController: _searchController,
                            onSearchChanged: (query) {
                              _bloc.add(LocalMusicEvent.searchSongs(query));
                            },
                            onSortOptionSelected: (option) {
                              _bloc.add(LocalMusicEvent.sortSongs(option));
                              serviceLocator<SharedPreferences>().setInt(
                                _sortPrefKey,
                                SortOption.values.indexOf(option),
                              );
                            },
                            currentSortOption: sortOption,
                            isSearching: isSearching,
                          );
                        },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Permission View ────────────────────────────────────────────────────────────

class _PermissionRequestView extends StatelessWidget {
  final VoidCallback onGrant;
  const _PermissionRequestView({required this.onGrant});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppPallete.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.library_music_rounded,
                size: 64,
                color: AppPallete.primaryGreen,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Access Your Library',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'We need permission to scan your device for local audio files to play them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                onGrant();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppPallete.primaryGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Grant Access',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: openAppSettings,
              child: const Text(
                'Open Settings',
                style: TextStyle(color: AppPallete.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptySongState extends StatelessWidget {
  final bool isFiltered;
  const _EmptySongState({this.isFiltered = false});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        height: 400,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFiltered ? Icons.search_off_rounded : Icons.music_off_rounded,
              size: 80,
              color: AppPallete.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No Matches Found' : 'No Songs Found',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try adjusting your search query.'
                  : 'Add some audio files to your device\nto see them here.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sliver Layout ──────────────────────────────────────────────────────────────

class _SliverSongLayout extends StatelessWidget {
  const _SliverSongLayout({
    required this.songs,
    required this.totalSongs,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSortOptionSelected,
    required this.currentSortOption,
    required this.isSearching,
  });

  final List<SongEntity> songs;
  final int totalSongs;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SortOption> onSortOptionSelected;
  final SortOption currentSortOption;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _SongListSliverAppBar(
          songsCount: totalSongs,
          displayCount: songs.length,
          searchController: searchController,
          onSearchChanged: onSearchChanged,
          onSortOptionSelected: onSortOptionSelected,
          currentSortOption: currentSortOption,
          isSearching: isSearching,
        ),
        if (songs.isEmpty)
          const _EmptySongState(isFiltered: true)
        else
          _SongListSliverItems(songs: songs),
        const SliverToBoxAdapter(child: SizedBox(height: 180)),
      ],
    );
  }
}

class _SongListSliverItems extends StatelessWidget {
  const _SongListSliverItems({required this.songs});
  final List<SongEntity> songs;

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final song = songs[index];
        return SongListTile(
          key: ValueKey(song.id),
          song: song,
          index: index,
          songList: songs,
        );
      }, childCount: songs.length),
    );
  }
}

// ── Sliver App Bar ─────────────────────────────────────────────────────────────

class _SongListSliverAppBar extends StatelessWidget {
  const _SongListSliverAppBar({
    required this.songsCount,
    required this.displayCount,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSortOptionSelected,
    required this.currentSortOption,
    required this.isSearching,
  });

  final int songsCount;
  final int displayCount;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<SortOption> onSortOptionSelected;
  final SortOption currentSortOption;
  final bool isSearching;

  @override
  Widget build(BuildContext context) {
    final double expandedHeight = 320.0;
    final double collapsedHeight =
        kToolbarHeight + MediaQuery.paddingOf(context).top;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      collapsedHeight: kToolbarHeight,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final top = constraints.biggest.height;
          final t =
              ((top - collapsedHeight) / (expandedHeight - collapsedHeight))
                  .clamp(0.0, 1.0);
          final contentOpacity = (t - 0.3).clamp(0.0, 1.0) / 0.7;
          final titleOpacity = (1.0 - t - 0.6).clamp(0.0, 0.4) / 0.4;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E2A78),
                  Color(0xFF0D1236),
                  AppPallete.backgroundColor,
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: expandedHeight,
                  child: Opacity(
                    opacity: contentOpacity,
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 47),
                            _SearchBar(
                              controller: searchController,
                              onChanged: onSearchChanged,
                              isSearching: isSearching,
                            ),
                            const Spacer(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppPallete.primaryGreen,
                                        Color(0xFF1E2A78),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.folder_open_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Local Files',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$displayCount tracks '
                                        '${displayCount != songsCount ? '(of $songsCount)' : '• Device Storage'}',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _ActionButton(
                                    icon: Icons.playlist_play_rounded,
                                    label: 'Playlists',
                                    onTap: () => context.router.push(
                                      const PlaylistListRoute(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _ActionButton(
                                    icon: Icons.favorite_rounded,
                                    label: 'Favorites',
                                    onTap: () => context.router.push(
                                      const FavoritesRoute(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  _ActionButton(
                                    icon: Icons.sort_rounded,
                                    label: currentSortOption.label,
                                    isActive: true,
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        backgroundColor:
                                            AppPallete.backgroundColor,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(24),
                                          ),
                                        ),
                                        builder: (context) => _SortBottomSheet(
                                          currentOption: currentSortOption,
                                          onOptionSelected:
                                              onSortOptionSelected,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: titleOpacity,
                    child: const Text(
                      'Local Songs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Sort Sheet ─────────────────────────────────────────────────────────────────

class _SortBottomSheet extends StatelessWidget {
  final SortOption currentOption;
  final ValueChanged<SortOption> onOptionSelected;

  const _SortBottomSheet({
    required this.currentOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sort By',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...SortOption.values.map((option) {
            final isSelected = option == currentOption;
            return ListTile(
              onTap: () {
                HapticFeedback.lightImpact();
                onOptionSelected(option);
                Navigator.pop(context);
              },
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppPallete.primaryGreen : Colors.grey,
              ),
              title: Text(
                option.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              contentPadding: EdgeInsets.zero,
            );
          }),
        ],
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isSearching;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    this.isSearching = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          cursorColor: AppPallete.primaryGreen,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 11),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white.withValues(alpha: 0.5),
              size: 22,
            ),
            suffixIcon: isSearching
                ? const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppPallete.primaryGreen,
                      ),
                    ),
                  )
                : controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: Colors.white54,
                    ),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
            hintText: 'Find in songs...',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

// ── Action Button ──────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? Colors.white.withValues(alpha: 0.1) : null,
            border: Border.all(
              color: isActive ? AppPallete.primaryGreen : Colors.white24,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? AppPallete.primaryGreen : Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? AppPallete.primaryGreen : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
