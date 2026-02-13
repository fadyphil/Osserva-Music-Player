import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_state.dart';
import 'package:music_player/features/local%20music/presentation/widgets/song_list_tile.dart';
import 'package:music_player/features/library/presentation/widgets/library_stats_row.dart';

class LibraryTracksSlivers extends StatefulWidget {
  const LibraryTracksSlivers({super.key});

  @override
  State<LibraryTracksSlivers> createState() => _LibraryTracksSliversState();
}

class _LibraryTracksSliversState extends State<LibraryTracksSlivers> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LocalMusicBloc, LocalMusicState>(
      listener: (context, state) {
        state.maybeMap(
          loaded: (s) {
            if (_searchController.text != s.searchQuery) {
              _searchController.text = s.searchQuery;
              // Maintain cursor at the end
              _searchController.selection = TextSelection.fromPosition(
                TextSelection.collapsed(offset: s.searchQuery.length).base,
              );
            }
          },
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.maybeMap(
          orElse: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          failure: (f) => SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
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
                      context
                          .read<LocalMusicBloc>()
                          .add(const LocalMusicEvent.getLocalSongs());
                    },
                    child: const Text("Retry"),
                  )
                ],
              ),
            ),
          ),
          loaded: (loadedState) {
            final songs = loadedState.processedSongs;
            final allSongs = loadedState.allSongs;
            final hasSearch = loadedState.searchQuery.isNotEmpty;

            final artistCount = allSongs.map((e) => e.artist).toSet().length;
            final albumCount = allSongs.map((e) => e.album).toSet().length;

            return SliverMainAxisGroup(
              slivers: [
                // Non-sticky Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        context.read<LocalMusicBloc>().add(
                              LocalMusicEvent.searchSongs(query),
                            );
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: "Search your library...",
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.3),
                          size: 20,
                        ),
                        suffixIcon: hasSearch
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white54, size: 18),
                                onPressed: () {
                                  context.read<LocalMusicBloc>().add(
                                        const LocalMusicEvent.searchSongs(''),
                                      );
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppPallete.cardColor,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              hasSearch ? "Search Results" : "All Tracks",
                              style: const TextStyle(
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
                        if (hasSearch) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Found for '${loadedState.searchQuery}'",
                            style: TextStyle(
                              color: AppPallete.accent.withValues(alpha: 0.7),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // The List
                if (songs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 64, color: Colors.white.withValues(alpha: 0.1)),
                          const SizedBox(height: 16),
                          const Text(
                            "No matching tracks found",
                            style: TextStyle(color: AppPallete.grey),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              context.read<LocalMusicBloc>().add(
                                    const LocalMusicEvent.searchSongs(''),
                                  );
                            },
                            child: const Text("Clear Search"),
                          ),
                        ],
                      ),
                    ),
                  )
                else
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

                // Bottom Padding for MiniPlayer
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            );
          },
        );
      },
    );
  }
}
