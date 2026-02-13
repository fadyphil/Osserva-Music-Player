import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_event.dart';
import 'package:music_player/features/playlists/presentation/widgets/add_to_playlist_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongListTile extends StatelessWidget {
  final SongEntity song;
  final int index;
  final List<SongEntity> songList;
  final int playCount;

  const SongListTile({
    super.key,
    required this.song,
    required this.index,
    required this.songList,
    this.playCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Slidable(
        key: ValueKey(song.id),
        groupTag: 0,
        startActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                context.read<MusicPlayerBloc>().add(
                  MusicPlayerEvent.addToQueue(song),
                );
              },
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: Colors.white,
              icon: Icons.queue_music,
              label: 'Queue',
            ),
          ],
        ),
        endActionPane: ActionPane(
          extentRatio: 0.3,
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                final localMusicBloc = context.read<LocalMusicBloc>();
                final favoritesBloc = context.read<FavoritesBloc>();
                final musicPlayerBloc = context.read<MusicPlayerBloc>();
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (context) => MultiBlocProvider(
                    providers: [
                      BlocProvider.value(value: localMusicBloc),
                      BlocProvider.value(value: favoritesBloc),
                      BlocProvider.value(value: musicPlayerBloc),
                    ],
                    child: SongActionsSheet(song: song),
                  ),
                );
              },
              backgroundColor: AppPallete.surface,
              foregroundColor: Colors.white,
              icon: Icons.more_horiz,
              label: 'Actions',
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.read<MusicPlayerBloc>().add(
                MusicPlayerEvent.initMusicQueue(
                  songs: songList,
                  currentIndex: index,
                ),
              );
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              final localMusicBloc = context.read<LocalMusicBloc>();
              final favoritesBloc = context.read<FavoritesBloc>();
              final musicPlayerBloc = context.read<MusicPlayerBloc>();
              showModalBottomSheet(
                context: context,
                useRootNavigator: true,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: localMusicBloc),
                    BlocProvider.value(value: favoritesBloc),
                    BlocProvider.value(value: musicPlayerBloc),
                  ],
                  child: SongActionsSheet(song: song),
                ),
              );
            },
            splashColor: AppPallete.primaryGreen.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Artwork
                  Container(
                    width: 52,
                    height: 52,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: AppPallete.cardColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: QueryArtworkWidget(
                      size: 200,
                      quality: 100,

                      id: song.id,

                      type: ArtworkType.AUDIO,

                      nullArtworkWidget: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.grey[800]!, Colors.grey[900]!],
                          ),
                        ),
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white30,
                        ),
                      ),

                      artworkFit: BoxFit.cover,
                      artworkHeight: 52,
                      artworkWidth: 52,
                      keepOldArtwork: true,
                      artworkBorder: BorderRadius.zero,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppPallete.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (song.artist.length > 20) const _ExplicitBadge(),
                            Flexible(
                              child: Text(
                                song.artist == '<unknown>'
                                    ? 'Unknown Artist'
                                    : song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppPallete.grey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Action Menu - Replaced with Favorite Button as requested implicitly by context
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatDuration(song.duration),
                        style: const TextStyle(
                          color: AppPallete.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$playCount plays",
                        style: TextStyle(
                          color: AppPallete.grey.withValues(alpha: 0.5),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(double durationMs) {
    final duration = Duration(milliseconds: durationMs.toInt());
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// Optimization: Extract small static widgets to be const
class _ExplicitBadge extends StatelessWidget {
  const _ExplicitBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(3),
      ),
      child: const Text(
        "E",
        style: TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
