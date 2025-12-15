import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/router/app_router.dart'; // Import AppRouter
import 'package:music_player/features/local%20music/presentation/widgets/song_list_tile.dart'; // Import SongListTile
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Architecture Imports
import '../../../../core/di/init_dependencies.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../domain/entities/song_entity.dart';
import '../managers/local_music_bloc.dart';
import '../managers/local_music_event.dart';
import '../managers/local_music_state.dart';

enum SortOption {
  titleAz('Title (A-Z)'),
  titleZa('Title (Z-A)'),
  artistAz('Artist (A-Z)'),
  dateAdded('Last Added'), // Using ID as proxy
  duration('Duration'),
  mostPlayed('Most Played');

  final String label;
  const SortOption(this.label);
}

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
  Timer? _debounce;
  String _searchQuery = '';
  SortOption _currentSort = SortOption.dateAdded;
  bool _isSearching = false;
  static const String _sortPrefKey = 'local_songs_sort_option';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSortPreference();
  }

  Future<void> _loadSortPreference() async {
    final prefs = serviceLocator<SharedPreferences>();
    final savedIndex = prefs.getInt(_sortPrefKey);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < SortOption.values.length) {
      if (mounted) {
        setState(() {
          _currentSort = SortOption.values[savedIndex];
        });
      }
    }
    _initData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = true;
    });

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
          _isSearching = false;
        });
      }
    });
  }

  void _onSortChanged(SortOption option) {
    setState(() {
      _currentSort = option;
    });
    Navigator.pop(context);
    try {
      final prefs = serviceLocator<SharedPreferences>();
      prefs.setInt(_sortPrefKey, SortOption.values.indexOf(option));
    } catch (e) {
      debugPrint("Error saving sort preference: $e");
    }
  }

  List<SongEntity> _getFilteredAndSortedSongs(
    List<SongEntity> songs,
    Map<int, int> playCounts,
  ) {
    // 1. Filter
    List<SongEntity> filtered;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = songs.where((song) {
        return song.title.toLowerCase().contains(query) ||
            song.artist.toLowerCase().contains(query);
      }).toList();
    } else {
      filtered = List.of(songs);
    }

    // 2. Sort
    switch (_currentSort) {
      case SortOption.titleAz:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SortOption.titleZa:
        filtered.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case SortOption.artistAz:
        filtered.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
        break;
      case SortOption.dateAdded:
        // ID is a decent proxy for date added in MediaStore
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.duration:
        filtered.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case SortOption.mostPlayed:
        filtered.sort((a, b) {
          final countA = playCounts[a.id] ?? 0;
          final countB = playCounts[b.id] ?? 0;
          return countB.compareTo(countA); // Descending
        });
        break;
    }

    return filtered;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissionAndFetch();
    }
  }

  Future<void> _initData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionAndFetch();
    });
  }

  Future<void> _checkPermissionAndFetch() async {
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
    return BlocProvider(
      create: (_) {
        final bloc = serviceLocator<LocalMusicBloc>();
        if (_hasPermission) {
          bloc.add(const LocalMusicEvent.getLocalSongs());
        }
        return bloc;
      },
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: Stack(
          children: [
            if (!_hasPermission)
              _PermissionRequestView(onGrant: _checkPermissionAndFetch),
            if (_hasPermission)
              BlocBuilder<LocalMusicBloc, LocalMusicState>(
                builder: (context, state) {
                  return state.when(
                    initial: () =>
                        const Center(child: CircularProgressIndicator()),
                    loading: () => const Center(
                      child: CircularProgressIndicator(
                        color: AppPallete.gradientTop,
                      ),
                    ),
                    failure: (failure) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "Unable to load songs.\n${failure.message}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                    loaded: (songs, playCounts) {
                      final processedSongs = _getFilteredAndSortedSongs(
                        songs,
                        playCounts,
                      );

                      return _SliverSongLayout(
                        songs: processedSongs,
                        totalSongs: songs.length,
                        searchController: _searchController,
                        onSearchChanged: _onSearchChanged,
                        onSortOptionSelected: _onSortChanged,
                        currentSortOption: _currentSort,
                        isSearching: _isSearching,
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
                color: AppPallete.cardColor,
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
              "Access Your Library",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "We need permission to scan your device for local audio files to play them.",
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
                "Grant Access",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: openAppSettings,
              child: const Text(
                "Open Settings",
                style: TextStyle(color: AppPallete.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
              isFiltered ? "No Matches Found" : "No Songs Found",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? "Try adjusting your search query."
                  : "Add some audio files to your device\nto see them here.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }
}

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
          // Use public widget
          key: ValueKey(song.id),
          song: song,
          index: index,
          songList: songs,
        );
      }, childCount: songs.length),
    );
  }
}

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
      collapsedHeight: kToolbarHeight, // Explicitly set to avoid jumps
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent, // Handled by the container

      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final top = constraints.biggest.height;
          // t represents the percentage of expansion (1.0 = fully expanded, 0.0 = collapsed)
          final t =
              ((top - collapsedHeight) / (expandedHeight - collapsedHeight))
                  .clamp(0.0, 1.0);

          // Opacity for expanded content (fades out quickly)
          final contentOpacity = (t - 0.3).clamp(0.0, 1.0) / 0.7;
          // Opacity for collapsed title (fades in at the end)
          final titleOpacity = (1.0 - t - 0.6).clamp(0.0, 0.4) / 0.4;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E2A78), // Deep Blue
                  Color(0xFF0D1236), // Darker Blue
                  AppPallete.backgroundColor, // Black
                ],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Expanded Content
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
                            const SizedBox(height: 16),
                            _SearchBar(
                              controller: searchController,
                              onChanged: onSearchChanged,
                              isSearching: isSearching,
                            ),
                            const Spacer(),
                            // Dynamic Hero Content
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
                                        "Local Files",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "$displayCount tracks ${displayCount != songsCount ? '(of $songsCount)' : '• Device Storage'}",
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
                            // Action Row
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _ActionButton(
                                    icon: Icons.playlist_play_rounded,
                                    label: "Playlists",
                                    onTap: () {
                                      context.router.push(
                                        const PlaylistListRoute(),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  _ActionButton(
                                    icon: Icons.favorite_rounded,
                                    label: "Favorites",
                                    onTap: () {
                                      context.router.push(
                                        const FavoritesRoute(),
                                      );
                                    },
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

                // Collapsed Title
                Positioned(
                  bottom: 14,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: titleOpacity,
                    child: const Text(
                      "Local Songs",
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
            "Sort By",
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
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
              contentPadding: const EdgeInsets.symmetric(
                vertical: 11,
              ), // Center vertically
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
              hintText: "Find in songs...",
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}

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
