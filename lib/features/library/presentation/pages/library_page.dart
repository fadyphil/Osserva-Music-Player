import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/library/presentation/widgets/library_toggle_bar.dart';
import 'package:music_player/features/library/presentation/widgets/library_tracks_view.dart';
import 'package:music_player/features/library/presentation/widgets/library_playlists_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:music_player/features/local%20music/presentation/managers/local_music_state.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _isFABVisible = false;
  bool _isSearchOverlayVisible = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndFetch();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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
    super.build(context);

    return BlocProvider(
      create: (_) {
        final bloc = serviceLocator<LocalMusicBloc>();
        final prefs = serviceLocator<SharedPreferences>();
        final savedIndex = prefs.getInt('local_songs_sort_option');
        if (savedIndex != null &&
            savedIndex >= 0 &&
            savedIndex < SortOption.values.length) {
          bloc.add(LocalMusicEvent.sortSongs(SortOption.values[savedIndex]));
        }

        if (_hasPermission) {
          bloc.add(const LocalMusicEvent.getLocalSongs());
        }
        return bloc;
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: AppPallete.backgroundColor,
            body: !_hasPermission
                ? _PermissionRequestView(onGrant: _checkPermissionAndFetch)
                : CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        backgroundColor: AppPallete.backgroundColor,
                        elevation: 0,
                        scrolledUnderElevation: 0,
                        pinned: false,
                        floating: true,
                        snap: true,
                        title: const Text(
                          "Library",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.white,
                          ),
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
                                              "Clear",
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
                                setState(() {
                                  _viewMode = mode;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      if (_viewMode == LibraryViewMode.tracks)
                        const LibraryTracksSlivers()
                      else
                        const LibraryPlaylistsSlivers(),
                    ],
                  ),
            floatingActionButton: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _isFABVisible ? Offset.zero : const Offset(0, 2),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isFABVisible ? 1 : 0,
                child: FloatingActionButton(
                  backgroundColor: AppPallete.accent,
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    setState(() => _isSearchOverlayVisible = true);
                  },
                  child: const Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),

          // MacOS Style Search Overlay
          if (_isSearchOverlayVisible)
            _SearchOverlay(
              onClose: () => setState(() => _isSearchOverlayVisible = false),
            ),
        ],
      ),
    );
  }

  void _showSortSheet(BuildContext context, dynamic loadedState) {
    final bloc = context.read<LocalMusicBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPallete.surface,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _SortBottomSheet(
        currentOption: loadedState.sortOption,
        onOptionSelected: (option) {
          bloc.add(LocalMusicEvent.sortSongs(option));
          serviceLocator<SharedPreferences>().setInt(
            'local_songs_sort_option',
            SortOption.values.indexOf(option),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _SearchOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const _SearchOverlay({required this.onClose});

  @override
  State<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends State<_SearchOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _blurAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClose() async {
    await _animationController.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _blurAnimation.value,
              sigmaY: _blurAnimation.value,
            ),
            child: GestureDetector(
              onTap: _handleClose,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.only(top: 80, left: 20, right: 20),
                child: ScaleTransition(scale: _scaleAnimation, child: child),
              ),
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {}, // Prevent closing when tapping the search bar
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
                            child: BlocBuilder<LocalMusicBloc, LocalMusicState>(
                              builder: (context, state) {
                                final initialQuery = state.maybeMap(
                                  loaded: (s) => s.searchQuery,
                                  orElse: () => '',
                                );
                                return TextField(
                                  controller:
                                      TextEditingController(text: initialQuery)
                                        ..selection =
                                            TextSelection.fromPosition(
                                              TextSelection.collapsed(
                                                offset: initialQuery.length,
                                              ).base,
                                            ),
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
                                    hintText: "Search your library",
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.3,
                                      ),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onSubmitted: (_) => _handleClose(),
                                );
                              },
                            ),
                          ),
                          TextButton(
                            onPressed: _handleClose,
                            style: TextButton.styleFrom(
                              foregroundColor: AppPallete.accent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "Cancel",
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
              // Optional: Shortcut hint
              const Text(
                "Press 'Enter' to confirm or tap outside to close",
                style: TextStyle(
                  color: Colors.white24,
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
                  "Sort Tracks By",
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
            "Library Locked",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            "Permission required to access local files",
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onGrant,
            style: FilledButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
            ),
            child: const Text("Grant Access"),
          ),
        ],
      ),
    );
  }
}
