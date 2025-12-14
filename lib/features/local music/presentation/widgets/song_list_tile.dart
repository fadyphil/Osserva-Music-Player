import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_event.dart';
import 'package:music_player/features/playlists/presentation/widgets/add_to_playlist_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SongListTile extends StatelessWidget {
  final SongEntity song;
  final int index;
  final List<SongEntity> songList;

  const SongListTile({
    super.key,
    required this.song,
    required this.index,
    required this.songList,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(song.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              HapticFeedback.mediumImpact();
              context.read<MusicPlayerBloc>().add(MusicPlayerEvent.addToQueue(song));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added "${song.title}" to Queue'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppPallete.primaryGreen,
                ),
              );
            },
            backgroundColor: const Color(0xFF21B7CA),
            foregroundColor: Colors.white,
            icon: Icons.playlist_add,
            label: 'Queue',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              HapticFeedback.mediumImpact();
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (context) => AddToPlaylistSheet(song: song),
              );
            },
            backgroundColor: const Color(0xFF7F58FF),
            foregroundColor: Colors.white,
            icon: Icons.add_box,
            label: 'Playlist',
          ),
        ],
      ),
      child: RepaintBoundary(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              context.read<MusicPlayerBloc>().add(
                MusicPlayerEvent.initMusicQueue(
                  songs: songList,
                  currentIndex: index,
                ),
              );
            },
            splashColor: AppPallete.primaryGreen.withValues(alpha: 0.1),
            highlightColor: Colors.white.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              child: Row(
                children: [
                  // Artwork
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppPallete.cardColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: QueryArtworkWidget(
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
                      artworkBorder: BorderRadius.circular(4),
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
                            if (song.artist.length > 20)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
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
                              ),
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
                  FavoriteButton(song: song),
                ],
              ),
            ),
          ),
        ),
      )
      .animate(target: 1)
      .fadeIn(duration: 300.ms, curve: Curves.easeOut)
      .slideY(
        begin: 0.2,
        end: 0,
        duration: 400.ms,
        curve: Curves.easeOutBack,
      ),
    );
  }
}
