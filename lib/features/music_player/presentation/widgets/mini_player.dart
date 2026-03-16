import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/core/router/app_router.dart';
import 'package:osserva/core/theme/app_pallete.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_event.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_state.dart';
import 'package:on_audio_query/on_audio_query.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  late PageController _pageController;
  int _lastKnownIndex = 0;
  bool _isUserScrolling = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openPlayer(BuildContext context) {
    // Push on the ROOT router so MusicPlayerRoute sits above everything —
    // including the Scaffold that contains this mini player and the nav bar.
    context.router.root.push(
      MusicPlayerRoute(
        song: context.read<MusicPlayerBloc>().state.currentSong!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MusicPlayerBloc, MusicPlayerState>(
      listenWhen: (previous, current) =>
          previous.currentIndex != current.currentIndex,
      listener: (context, state) {
        if (_pageController.hasClients && !_isUserScrolling) {
          final currentPage = _pageController.page?.round() ?? 0;
          if (currentPage != state.currentIndex) {
            _lastKnownIndex = state.currentIndex;
            _pageController.jumpToPage(state.currentIndex);
          }
        }
      },
      child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
        buildWhen: (previous, current) =>
            previous.currentSong != current.currentSong ||
            previous.queue != current.queue,
        builder: (context, state) {
          final song = state.currentSong;
          if (song == null) return const SizedBox.shrink();

          if (_pageController.hasClients &&
              !_isUserScrolling &&
              (_pageController.page?.round() ?? 0) != state.currentIndex) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_pageController.hasClients && !_isUserScrolling) {
                _pageController.jumpToPage(state.currentIndex);
              }
            });
          }

          final queue = state.queue.isEmpty ? [song] : state.queue;
          final itemCount = queue.length;

          return GestureDetector(
            onTap: () => _openPlayer(context),
            // Swipe up opens the player. Threshold -200 (upward) to avoid
            // false positives from micro-drags. The PageView inside handles
            // horizontal swipes independently so there's no axis conflict.
            onVerticalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) < -200) {
                _openPlayer(context);
              }
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 66,
              decoration: BoxDecoration(
                color: AppPallete.cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // Artwork — Hero tag shared with MusicPlayerPage
                        // so the artwork expands smoothly into the full player.
                        Hero(
                          tag: 'currentArtwork',
                          // Hide the source position during flight so there's
                          // no visible artifact at the transition boundary.
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
                          child: Container(
                            width: 50,
                            height: 50,
                            margin: const EdgeInsets.only(left: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: AppPallete.grey,
                            ),
                            child: QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              nullArtworkWidget: const Icon(
                                Icons.music_note,
                                color: AppPallete.white,
                              ),
                              artworkHeight: 50,
                              artworkWidth: 50,
                              artworkBorder: BorderRadius.circular(4),
                              artworkFit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: NotificationListener<UserScrollNotification>(
                            onNotification: (notification) {
                              _isUserScrolling =
                                  notification.direction !=
                                  ScrollDirection.idle;
                              return false;
                            },
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: itemCount,
                              physics: const BouncingScrollPhysics(),
                              onPageChanged: (index) {
                                if (index != _lastKnownIndex) {
                                  _lastKnownIndex = index;
                                  context.read<MusicPlayerBloc>().add(
                                    MusicPlayerEvent.initMusicQueue(
                                      songs: queue,
                                      currentIndex: index,
                                    ),
                                  );
                                }
                              },
                              itemBuilder: (context, index) {
                                final itemSong = queue[index];
                                return RepaintBoundary(
                                  child: AnimatedBuilder(
                                    animation: _pageController,
                                    builder: (context, child) {
                                      double opacity = 1.0;
                                      if (_pageController
                                          .position
                                          .haveDimensions) {
                                        final page = _pageController.page ?? 0;
                                        final dist = (page - index).abs();
                                        opacity = (1 - (dist * dist * dist))
                                            .clamp(0.0, 1.0);
                                      }
                                      return Opacity(
                                        opacity: opacity,
                                        child: child,
                                      );
                                    },
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            itemSong.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppPallete.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            itemSong.artist,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppPallete.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        const _PlayPauseButton(),
                      ],
                    ),
                  ),
                  const _MiniPlayerProgressBar(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MusicPlayerBloc, MusicPlayerState, bool>(
      selector: (state) => state.isPlaying,
      builder: (context, isPlaying) {
        return IconButton(
          onPressed: () {
            final bloc = context.read<MusicPlayerBloc>();
            isPlaying
                ? bloc.add(const MusicPlayerEvent.pause())
                : bloc.add(const MusicPlayerEvent.resume());
          },
          icon: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppPallete.white,
          ),
        );
      },
    );
  }
}

class _MiniPlayerProgressBar extends StatelessWidget {
  const _MiniPlayerProgressBar();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      buildWhen: (previous, current) =>
          previous.position != current.position ||
          previous.duration != current.duration,
      builder: (context, state) {
        if (state.duration.inSeconds <= 0) return const SizedBox.shrink();
        final value = (state.position.inSeconds / state.duration.inSeconds)
            .clamp(0.0, 1.0);
        return LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(
            AppPallete.primaryGreen,
          ),
          minHeight: 2,
        );
      },
    );
  }
}
