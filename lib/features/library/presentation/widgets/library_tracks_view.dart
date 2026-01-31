import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_state.dart';
import 'package:music_player/features/local%20music/presentation/widgets/song_list_tile.dart';
import 'package:music_player/features/library/presentation/widgets/library_stats_row.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryTracksView extends StatefulWidget {
  const LibraryTracksView({super.key});

  @override
  State<LibraryTracksView> createState() => _LibraryTracksViewState();
}

class _LibraryTracksViewState extends State<LibraryTracksView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocalMusicBloc, LocalMusicState>(
      listener: (context, state) {
        // Sync search controller if needed
      },
      builder: (context, state) {
        return state.maybeMap(
          orElse: () => const Center(child: CircularProgressIndicator()),
          failure: (f) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Error loading songs: ${f.failure.message}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<LocalMusicBloc>().add(const LocalMusicEvent.getLocalSongs());
                  },
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
          loaded: (loadedState) {
            final songs = loadedState.processedSongs;
            final allSongs = loadedState.allSongs;
            
            // Calculate stats dynamically from the full list
            final artistCount = allSongs.map((e) => e.artist).toSet().length;
            final albumCount = allSongs.map((e) => e.album).toSet().length;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Search Bar Pinned
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  backgroundColor: AppPallete.backgroundColor,
                  automaticallyImplyLeading: false,
                  toolbarHeight: 70,
                  flexibleSpace: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        context.read<LocalMusicBloc>().add(
                          LocalMusicEvent.searchSongs(query),
                        );
                      },
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Search tracks, artists, albums...",
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        filled: true,
                        fillColor: AppPallete.cardColor,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // Filter Chips
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _FilterChip(
                          label: "Title",
                          isActive: loadedState.sortOption == SortOption.titleAz,
                          onTap: () => _updateSort(context, SortOption.titleAz),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: "Artist",
                          isActive: loadedState.sortOption == SortOption.artistAz,
                          onTap: () => _updateSort(context, SortOption.artistAz),
                        ),
                        const SizedBox(width: 8),
                         _FilterChip(
                          label: "Date",
                          isActive: loadedState.sortOption == SortOption.dateAdded,
                          onTap: () => _updateSort(context, SortOption.dateAdded),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Stats Row
                SliverToBoxAdapter(
                  child: LibraryStatsRow(
                    trackCount: allSongs.length,
                    artistCount: artistCount,
                    albumCount: albumCount,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Header Text
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "All Tracks",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "${songs.length} tracks",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // The List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = songs[index];
                      return SongListTile(
                        key: ValueKey(song.id),
                        song: song,
                        index: index,
                        songList: songs,
                        playCount: loadedState.playCounts[song.id] ?? 0,
                      );
                    },
                    childCount: songs.length,
                  ),
                ),
                
                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          },
        );
      },
    );
  }

  void _updateSort(BuildContext context, SortOption option) {
    context.read<LocalMusicBloc>().add(LocalMusicEvent.sortSongs(option));
     serviceLocator<SharedPreferences>().setInt(
       'local_songs_sort_option',
       SortOption.values.indexOf(option),
     );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppPallete.primaryColor : AppPallete.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppPallete.grey,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
