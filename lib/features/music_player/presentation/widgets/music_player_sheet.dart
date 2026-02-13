import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/playlists/presentation/widgets/add_to_playlist_sheet.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../../../../core/theme/app_pallete.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';
import '../bloc/music_player_state.dart';

class MusicPlayerSheet extends StatelessWidget {
  const MusicPlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
      listenWhen: (previous, current) =>
          previous.queueActionStatus != current.queueActionStatus,
      listener: (context, state) {
        if (state.queueActionStatus == QueueStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Queue updated successfully!'),
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
        appBar: AppBar(
          backgroundColor: AppPallete.background,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppPallete.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Now Playing",
            style: TextStyle(
              color: AppPallete.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          centerTitle: true,
          actions: [
            BlocSelector<MusicPlayerBloc, MusicPlayerState, SongEntity?>(
              selector: (state) => state.currentSong,
              builder: (context, song) {
                return IconButton(
                  icon: const Icon(
                    Icons.more_horiz,
                    color: AppPallete.white,
                  ),
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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // 1. ARTWORK
              const _Artwork(),
              const Spacer(),
              // 2. SONG INFO
              const _SongInfo(),
              const SizedBox(height: 20),
              // 3. PROGRESS BAR
              const _SmoothProgressBar(),
              const SizedBox(height: 30),
              // 4. CONTROLS
              const _PlayerControls(),
              const SizedBox(height: 40),
              // 5. UTILITY ICONS
              const _UtilityIcons(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

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
                onChanged: (val) {
                  setState(() => _draggingValue = val);
                },
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
                  _formatDuration(Duration(seconds: value.toInt())),
                  style: const TextStyle(color: AppPallete.grey, fontSize: 12),
                ),
                Text(
                  _formatDuration(state.duration),
                  style: const TextStyle(color: AppPallete.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

class _PlayerControls extends StatelessWidget {
  const _PlayerControls();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        BlocSelector<MusicPlayerBloc, MusicPlayerState, bool>(
          selector: (state) => state.isShuffling,
          builder: (context, isShuffling) {
            return IconButton(
              icon: Icon(
                Icons.shuffle,
                color: isShuffling ? AppPallete.accent : AppPallete.white,
                size: 20,
              ),
              onPressed: () {
                context.read<MusicPlayerBloc>().add(
                  const MusicPlayerEvent.toggleShuffle(),
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_previous_rounded,
            size: 32,
            color: AppPallete.white,
          ),
          onPressed: () {
            context.read<MusicPlayerBloc>().add(
              const MusicPlayerEvent.playPreviousSong(),
            );
          },
        ),
        BlocSelector<MusicPlayerBloc, MusicPlayerState, bool>(
          selector: (state) => state.isPlaying,
          builder: (context, isPlaying) {
            return GestureDetector(
              onTap: () {
                final bloc = context.read<MusicPlayerBloc>();
                if (isPlaying) {
                  bloc.add(const MusicPlayerEvent.pause());
                } else {
                  bloc.add(const MusicPlayerEvent.resume());
                }
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
            );
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.skip_next_rounded,
            size: 32,
            color: AppPallete.white,
          ),
          onPressed: () {
            context.read<MusicPlayerBloc>().add(
              const MusicPlayerEvent.playNextSong(),
            );
          },
        ),
        BlocSelector<MusicPlayerBloc, MusicPlayerState, int>(
          selector: (state) => state.loopMode,
          builder: (context, loopMode) {
            return IconButton(
              icon: Icon(
                loopMode == 0
                    ? Icons.repeat
                    : (loopMode == 2 ? Icons.repeat_one : Icons.repeat),
                color: loopMode > 0 ? AppPallete.accent : AppPallete.white,
                size: 20,
              ),
              onPressed: () {
                context.read<MusicPlayerBloc>().add(
                  const MusicPlayerEvent.cycleLoopMode(),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _UtilityIcons extends StatelessWidget {
  const _UtilityIcons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.favorite_border,
            color: AppPallete.grey,
            size: 20,
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.text_fields, color: AppPallete.grey, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.queue_music, color: AppPallete.grey, size: 20),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.timer_outlined,
            color: AppPallete.grey,
            size: 20,
          ),
          onPressed: () {},
        ),
        const Spacer(),
        BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
          buildWhen: (previous, current) =>
              previous.currentSong?.id != current.currentSong?.id ||
              previous.playCounts != current.playCounts ||
              previous.currentGenre != current.currentGenre,
          builder: (context, state) {
            final song = state.currentSong;
            final playCount = (song != null)
                ? (state.playCounts[song.id] ?? 0)
                : 0;

            String genre = state.currentGenre;
            if (genre.isEmpty || genre.toLowerCase() == 'unknown') {
              genre = "Mysterious";
            }

            return Text(
              "$playCount plays • $genre",
              style: const TextStyle(color: AppPallete.grey, fontSize: 12),
            );
          },
        ),
      ],
    );
  }
}
