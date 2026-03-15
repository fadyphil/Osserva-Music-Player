import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_event.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_state.dart';
import 'package:music_player/features/music_player/presentation/widgets/lyrics_sheet.dart';
import 'package:music_player/features/music_player/presentation/widgets/queue_sheet.dart';
import 'package:music_player/features/music_player/presentation/widgets/sleep_timer_sheet.dart';
import 'package:music_player/features/playlists/presentation/widgets/add_to_playlist_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

@RoutePage()
class MusicPlayerPage extends StatefulWidget {
  final SongEntity song;
  const MusicPlayerPage({super.key, required this.song});

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  _MusicPlayerPageState();

  // @override
  // Tracks downward drag for physical dismiss feedback.
  double _dragOffset = 0;

  // The page moves at 40% of finger travel — feels anchored, not floaty.
  static const double _dragResistance = 0.6;

  // Commit dismiss vs snap back thresholds.
  static const double _dismissOffsetThreshold = 120;
  static const double _dismissVelocityThreshold = 600;

  void _handleDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy > 0) {
      setState(() {
        _dragOffset = (_dragOffset + details.delta.dy * _dragResistance).clamp(
          0,
          220,
        );
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > _dismissVelocityThreshold ||
        _dragOffset > _dismissOffsetThreshold) {
      // Kick off the route's own reverse slide animation.
      // The page is already partially translated so it continues fluidly.
      context.router.pop();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Vertical drag anywhere on the page triggers dismiss.
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: BlocListener<MusicPlayerBloc, MusicPlayerState>(
          listenWhen: (previous, current) =>
              previous.queueActionStatus != current.queueActionStatus,
          listener: (context, state) {
            if (state.queueActionStatus == QueueStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Queue updated'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state.queueActionStatus == QueueStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppPallete.background,
            body: SafeArea(
              child: Column(
                children: [
                  _DragHandle(onClose: () => context.router.pop()),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Spacer(),
                          _Artwork(),
                          Spacer(),
                          _SongInfo(),
                          SizedBox(height: 20),
                          _SmoothProgressBar(),
                          SizedBox(height: 30),
                          _PlayerControls(),
                          SizedBox(height: 40),
                          _UtilityIcons(),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Drag Handle + Header ───────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  final VoidCallback onClose;
  const _DragHandle({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// unneeded grey drag handle
        // Padding(
        //   padding: const EdgeInsets.only(top: 12, bottom: 4),
        //   child: Center(
        //     child: Container(
        //       width: 40,
        //       height: 4,
        //       decoration: BoxDecoration(
        //         color: Colors.white24,
        //         borderRadius: BorderRadius.circular(2),
        //       ),
        //     ),
        //   ),
        // ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppPallete.white,
                ),
                onPressed: onClose,
              ),
              const Expanded(
                child: Text(
                  'Now Playing',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppPallete.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              BlocSelector<MusicPlayerBloc, MusicPlayerState, SongEntity?>(
                selector: (state) => state.currentSong,
                builder: (context, song) {
                  return IconButton(
                    icon: const Icon(Icons.more_horiz, color: AppPallete.white),
                    onPressed: () {
                      if (song == null) return;
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
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Artwork ────────────────────────────────────────────────────────────────────

class _Artwork extends StatelessWidget {
  const _Artwork();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MusicPlayerBloc, MusicPlayerState, SongEntity?>(
      selector: (state) => state.currentSong,
      builder: (context, song) {
        if (song == null) {
          return const AspectRatio(
            aspectRatio: 1,
            child: _ArtworkPlaceholder(),
          );
        }
        return RepaintBoundary(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppPallete.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .3),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Hero(
                // Shared with mini player → smooth scale-up transition.
                tag: 'currentArtwork',
                // Hide this position during flight so there's no
                // visible artifact at the transition boundary.
                placeholderBuilder: (context, heroSize, child) {
                  return SizedBox.fromSize(size: heroSize);
                },
                flightShuttleBuilder:
                    (
                      flightContext,
                      animation,
                      flightDirection,
                      fromHeroContext,
                      toHeroContext,
                    ) {
                      // Always use the SOURCE hero's child — it already
                      // has artwork loaded. Using the destination's
                      // QueryArtworkWidget would trigger a fresh async
                      // load, momentarily showing the null placeholder.
                      final fromHero = fromHeroContext.widget as Hero;
                      return Material(
                        type: MaterialType.transparency,
                        child: fromHero.child,
                      );
                    },
                child: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  size: 800,
                  quality: 100,
                  artworkHeight: 800,
                  artworkWidth: 800,
                  artworkFit: BoxFit.cover,
                  keepOldArtwork: true,
                  artworkBorder: BorderRadius.zero,
                  nullArtworkWidget: const _ArtworkPlaceholder(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ArtworkPlaceholder extends StatelessWidget {
  const _ArtworkPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[800]!, Colors.grey[900]!],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, color: Colors.white30, size: 120),
      ),
    );
  }
}

// ── Song Info ──────────────────────────────────────────────────────────────────

class _SongInfo extends StatelessWidget {
  const _SongInfo();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MusicPlayerBloc, MusicPlayerState, SongEntity?>(
      selector: (state) => state.currentSong,
      builder: (context, song) {
        if (song == null) return const SizedBox(height: 60);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              song.title,
              style: const TextStyle(
                color: AppPallete.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              song.artist,
              style: const TextStyle(color: AppPallete.grey, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      },
    );
  }
}

// ── Progress Bar ───────────────────────────────────────────────────────────────

class _SmoothProgressBar extends StatefulWidget {
  const _SmoothProgressBar();

  @override
  State<_SmoothProgressBar> createState() => _SmoothProgressBarState();
}

class _SmoothProgressBarState extends State<_SmoothProgressBar> {
  double? _draggingValue;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      buildWhen: (previous, current) =>
          previous.position != current.position ||
          previous.duration != current.duration,
      builder: (context, state) {
        final max = state.duration.inSeconds.toDouble();
        final currentPos = state.position.inSeconds.toDouble().clamp(0.0, max);
        final value = _draggingValue ?? currentPos;

        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                activeTrackColor: AppPallete.accent,
                inactiveTrackColor: AppPallete.surface,
                thumbColor: AppPallete.white,
                trackShape: const _FullWidthTrackShape(),
              ),
              child: Slider(
                min: 0,
                max: max > 0 ? max : 1.0,
                value: value.clamp(0.0, max > 0 ? max : 1.0),
                onChanged: (val) => setState(() => _draggingValue = val),
                onChangeEnd: (val) {
                  context.read<MusicPlayerBloc>().add(
                    MusicPlayerEvent.seek(Duration(seconds: val.toInt())),
                  );
                  setState(() => _draggingValue = null);
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _fmt(Duration(seconds: value.toInt())),
                  style: const TextStyle(color: AppPallete.grey, fontSize: 12),
                ),
                Text(
                  _fmt(state.duration),
                  style: const TextStyle(color: AppPallete.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _FullWidthTrackShape extends RoundedRectSliderTrackShape {
  const _FullWidthTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

// ── Player Controls ────────────────────────────────────────────────────────────

class _PlayerControls extends StatelessWidget {
  const _PlayerControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocSelector<MusicPlayerBloc, MusicPlayerState, bool>(
          selector: (state) => state.isShuffling,
          builder: (context, isShuffling) => IconButton(
            icon: Icon(
              Icons.shuffle,
              color: isShuffling ? AppPallete.accent : AppPallete.white,
              size: 20,
            ),
            onPressed: () => context.read<MusicPlayerBloc>().add(
              const MusicPlayerEvent.toggleShuffle(),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            size: 32,
            color: AppPallete.white,
          ),
          onPressed: () => context.read<MusicPlayerBloc>().add(
            const MusicPlayerEvent.playPreviousSong(),
          ),
        ),
        BlocSelector<MusicPlayerBloc, MusicPlayerState, bool>(
          selector: (state) => state.isPlaying,
          builder: (context, isPlaying) => GestureDetector(
            onTap: () {
              final bloc = context.read<MusicPlayerBloc>();
              isPlaying
                  ? bloc.add(const MusicPlayerEvent.pause())
                  : bloc.add(const MusicPlayerEvent.resume());
            },
            child: Container(
              height: 64,
              width: 64,
              decoration: const BoxDecoration(
                color: AppPallete.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppPallete.white,
                size: 36,
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            size: 32,
            color: AppPallete.white,
          ),
          onPressed: () => context.read<MusicPlayerBloc>().add(
            const MusicPlayerEvent.playNextSong(),
          ),
        ),
        BlocSelector<MusicPlayerBloc, MusicPlayerState, int>(
          selector: (state) => state.loopMode,
          builder: (context, loopMode) => IconButton(
            icon: Icon(
              loopMode == 2 ? Icons.repeat_one : Icons.repeat,
              color: loopMode > 0 ? AppPallete.accent : AppPallete.white,
              size: 20,
            ),
            onPressed: () => context.read<MusicPlayerBloc>().add(
              const MusicPlayerEvent.cycleLoopMode(),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Utility Icons ──────────────────────────────────────────────────────────────

class _UtilityIcons extends StatelessWidget {
  const _UtilityIcons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BlocSelector<MusicPlayerBloc, MusicPlayerState, SongEntity?>(
          selector: (state) => state.currentSong,
          builder: (context, currentSong) {
            return BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                final isFavorite =
                    currentSong != null &&
                    state.maybeMap(
                      loaded: (s) => s.favoriteIds.contains(currentSong.id),
                      orElse: () => false,
                    );
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? AppPallete.accent : AppPallete.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    if (currentSong != null) {
                      context.read<FavoritesBloc>().add(
                        FavoritesEvent.toggleFavorite(currentSong),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
        BlocSelector<MusicPlayerBloc, MusicPlayerState, SongEntity?>(
          selector: (state) => state.currentSong,
          builder: (context, currentSong) {
            return IconButton(
              icon: const Icon(
                Icons.text_fields,
                color: AppPallete.grey,
                size: 20,
              ),
              onPressed: () {
                if (currentSong != null) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => LyricsSheet(song: currentSong),
                  );
                }
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.queue_music, color: AppPallete.grey, size: 20),
          onPressed: () {
            final musicPlayerBloc = context.read<MusicPlayerBloc>();
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              useRootNavigator: true,
              builder: (context) => BlocProvider.value(
                value: musicPlayerBloc,
                child: const FractionallySizedBox(
                  heightFactor: 0.6,
                  child: QueueSheet(),
                ),
              ),
            );
          },
        ),
        BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
          builder: (context, state) {
            final isTimerActive =
                state.timerRemaining != null || state.isEndTrackTimerActive;
            return IconButton(
              icon: Icon(
                Icons.timer_outlined,
                color: isTimerActive ? AppPallete.accent : AppPallete.grey,
                size: 20,
              ),
              onPressed: () {
                final musicPlayerBloc = context.read<MusicPlayerBloc>();
                showModalBottomSheet(
                  showDragHandle: false,
                  useRootNavigator: true,
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => BlocProvider.value(
                    value: musicPlayerBloc,
                    child: const SleepTimerSheet(),
                  ),
                );
              },
            );
          },
        ),
        const Spacer(),
        BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
          buildWhen: (previous, current) =>
              previous.currentSong?.id != current.currentSong?.id ||
              previous.playCounts != current.playCounts ||
              previous.currentGenre != current.currentGenre,
          builder: (context, state) {
            final song = state.currentSong;
            final playCount = song != null
                ? (state.playCounts[song.id] ?? 0)
                : 0;
            String genre = state.currentGenre;
            if (genre.isEmpty || genre.toLowerCase() == 'unknown') {
              genre = 'Mysterious';
            }
            return Text(
              '$playCount plays • $genre',
              style: const TextStyle(color: AppPallete.grey, fontSize: 12),
            );
          },
        ),
      ],
    );
  }
}
