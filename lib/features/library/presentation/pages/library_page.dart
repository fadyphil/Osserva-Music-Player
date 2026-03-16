import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/core/di/init_dependencies.dart';
import 'package:osserva/core/theme/app_pallete.dart';
import 'package:osserva/features/library/presentation/widgets/library_toggle_bar.dart';
import 'package:osserva/features/library/presentation/widgets/library_tracks_view.dart';
import 'package:osserva/features/library/presentation/widgets/library_playlists_view.dart';
import 'package:osserva/features/local_music/presentation/managers/local_music_bloc.dart';
import 'package:osserva/features/local_music/presentation/managers/local_music_event.dart';
import 'package:osserva/features/local_music/presentation/managers/local_music_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with AutomaticKeepAliveClientMixin {
  LibraryViewMode _viewMode = LibraryViewMode.tracks;
  bool _hasPermission = false;

  /// Held here so we can dispatch events from outside the BlocProvider tree
  /// (e.g. RefreshIndicator callback fires before build).
  late final LocalMusicBloc _bloc;

  final ScrollController _scrollController = ScrollController();
  bool _isFABVisible = false;
  bool _isSearchOverlayVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _bloc = serviceLocator<LocalMusicBloc>();
    _scrollController.addListener(_scrollListener);
    _checkPermissionAndFetch();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _bloc.close();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;
    final offset = _scrollController.offset;
    final direction = _scrollController.position.userScrollDirection;

    if (offset > 120) {
      if (direction == ScrollDirection.forward && !_isFABVisible) {
        setState(() => _isFABVisible = true);
      } else if (direction == ScrollDirection.reverse &&
          _isFABVisible &&
          offset < 500) {
        setState(() => _isFABVisible = false);
      } else if (offset > 600 && !_isFABVisible) {
        setState(() => _isFABVisible = true);
      }
    } else if (_isFABVisible) {
      setState(() => _isFABVisible = false);
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

    // Apply saved sort preference before fetching
    final prefs = serviceLocator<SharedPreferences>();
    final savedIndex = prefs.getInt('local_songs_sort_option');
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < SortOption.values.length) {
      _bloc.add(LocalMusicEvent.sortSongs(SortOption.values[savedIndex]));
    }

    _bloc.add(const LocalMusicEvent.getLocalSongs());
  }

  /// Called by RefreshIndicator and re-dispatches getLocalSongs.
  /// Returns a Future so the spinner knows when to stop.
  Future<void> _refresh() async {
    _bloc.add(const LocalMusicEvent.getLocalSongs());

    // Wait until the bloc leaves the loading state (success or error)
    await _bloc.stream.firstWhere(
      (state) => state.maybeMap(loading: (_) => false, orElse: () => true),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider.value(
      // Use the bloc we already created and own — avoids double-creation
      // and lets us dispatch events from _refresh() outside the tree.
      value: _bloc,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppPallete.backgroundColor,
            body: !_hasPermission
                ? _PermissionRequestView(onGrant: _checkPermissionAndFetch)
                : RefreshIndicator(
                    onRefresh: _refresh,
                    color: AppPallete.accent,
                    backgroundColor: AppPallete.surface,
                    displacement: 80,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                        // AlwaysScrollable ensures RefreshIndicator fires even
                        // when the list is shorter than the viewport
                      ),
                      slivers: [
                        SliverAppBar(
                          backgroundColor: AppPallete.backgroundColor,
                          elevation: 0,
                          scrolledUnderElevation: 0,
                          pinned: false,
                          floating: true,
                          snap: true,
                          title: BlocBuilder<LocalMusicBloc, LocalMusicState>(
                            builder: (context, state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Library',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          actions: [
                            if (_viewMode == LibraryViewMode.tracks)
                              BlocBuilder<LocalMusicBloc, LocalMusicState>(
                                builder: (context, state) {
                                  return state.maybeMap(
                                    loaded: (loadedState) {
                                      final hasSearch =
                                          loadedState.searchQuery.isNotEmpty;
                                      return Row(
                                        children: [
                                          if (hasSearch)
                                            TextButton(
                                              onPressed: () {
                                                context.read<LocalMusicBloc>().add(
                                                  const LocalMusicEvent.searchSongs(
                                                    '',
                                                  ),
                                                );
                                              },
                                              child: const Text(
                                                'Clear',
                                                style: TextStyle(
                                                  color: AppPallete.accent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.sort_rounded,
                                              color: Colors.white,
                                            ),
                                            onPressed: () => _showSortSheet(
                                              context,
                                              loadedState,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    orElse: () => const SizedBox.shrink(),
                                  );
                                },
                              ),
                            const SizedBox(width: 8),
                          ],
                        ),
                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              LibraryToggleBar(
                                currentMode: _viewMode,
                                onModeChanged: (mode) {
                                  HapticFeedback.lightImpact();
                                  setState(() => _viewMode = mode);
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),

                        // Pull-to-refresh hint (only shown in empty/initial state
                        // so the user discovers the gesture)
                        BlocBuilder<LocalMusicBloc, LocalMusicState>(
                          builder: (context, state) {
                            return state.maybeMap(
                              initial: (_) => SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 14,
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Pull down to refresh',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.25,
                                          ),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              orElse: () => const SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              ),
                            );
                          },
                        ),

                        if (_viewMode == LibraryViewMode.tracks)
                          const LibraryTracksSlivers()
                        else
                          const LibraryPlaylistsSlivers(),
                      ],
                    ),
                  ),
            floatingActionButton: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _isFABVisible ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isFABVisible ? 1 : 0,
                child: FloatingActionButton(
                  backgroundColor: AppPallete.accent,
                  onPressed: _isFABVisible
                      ? () {
                          HapticFeedback.mediumImpact();
                          setState(() => _isSearchOverlayVisible = true);
                        }
                      : null, // disable tap-through when invisible
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),

          if (_isSearchOverlayVisible)
            _SearchOverlay(
              onClose: () => setState(() => _isSearchOverlayVisible = false),
            ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context, dynamic loadedState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPallete.surface,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SortBottomSheet(
        currentOption: loadedState.sortOption,
        onOptionSelected: (option) {
          if (!_bloc.isClosed) {
            _bloc.add(LocalMusicEvent.sortSongs(option));
          }
          serviceLocator<SharedPreferences>().setInt(
            'local_songs_sort_option',
            SortOption.values.indexOf(option),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH OVERLAY
// ─────────────────────────────────────────────────────────────────────────────

class _SearchOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const _SearchOverlay({required this.onClose});

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _blur;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _blur = Tween<double>(
      begin: 0.0,
      end: 14.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();

    // Pre-fill with current search query
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<LocalMusicBloc>().state;
      final q = state.maybeMap(loaded: (s) => s.searchQuery, orElse: () => '');
      _textController.value = TextEditingValue(
        text: q,
        selection: TextSelection.collapsed(offset: q.length),
      );
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleClose() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => FadeTransition(
        opacity: _fade,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blur.value, sigmaY: _blur.value),
          child: GestureDetector(
            onTap: _handleClose,
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
              child: ScaleTransition(scale: _scale, child: child),
            ),
          ),
        ),
      ),
      child: GestureDetector(
        onTap: () {}, // absorb taps so overlay doesn't close
        child: Material(
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 550),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1E).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            color: AppPallete.accent,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              focusNode: _focusNode,
                              onChanged: (query) {
                                context.read<LocalMusicBloc>().add(
                                  LocalMusicEvent.searchSongs(query),
                                );
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                letterSpacing: -0.2,
                                fontWeight: FontWeight.w400,
                              ),
                              cursorColor: AppPallete.accent,
                              cursorWidth: 1.5,
                              cursorRadius: const Radius.circular(1),
                              decoration: InputDecoration(
                                hintText: 'Search your library',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              onSubmitted: (_) => _handleClose(),
                            ),
                          ),
                          // Clear button — only visible when field has text
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _textController,
                            builder: (_, value, _) {
                              if (value.text.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return GestureDetector(
                                onTap: () {
                                  _textController.clear();
                                  context.read<LocalMusicBloc>().add(
                                    const LocalMusicEvent.searchSongs(''),
                                  );
                                  _focusNode.requestFocus();
                                },
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.white.withValues(alpha: 0.4),
                                  size: 18,
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            onPressed: _handleClose,
                            style: TextButton.styleFrom(
                              foregroundColor: AppPallete.accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Press 'Enter' to confirm or tap outside to close",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.22),
                  fontSize: 12,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SORT SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _SortBottomSheet extends StatelessWidget {
  final SortOption currentOption;
  final ValueChanged<SortOption> onOptionSelected;

  const _SortBottomSheet({
    required this.currentOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Text(
                  'Sort Tracks By',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ...SortOption.values.map((option) {
                final isSelected = option == currentOption;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onOptionSelected(option);
                    Navigator.pop(context);
                  },
                  leading: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected ? AppPallete.accent : Colors.grey,
                  ),
                  title: Text(
                    option.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERMISSION REQUEST
// ─────────────────────────────────────────────────────────────────────────────

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
          const Text(
            'Library Locked',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Permission required to access local files',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onGrant,
            style: FilledButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
            ),
            child: const Text('Grant Access'),
          ),
        ],
      ),
    );
  }
}
