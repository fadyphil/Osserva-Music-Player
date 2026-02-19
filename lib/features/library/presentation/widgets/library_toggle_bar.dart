import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_pallete.dart';

enum LibraryViewMode { tracks, playlists }

class LibraryToggleBar extends StatelessWidget {
  final LibraryViewMode currentMode;
  final ValueChanged<LibraryViewMode> onModeChanged;

  const LibraryToggleBar({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _ToggleButton(
            label: "Tracks",
            isActive: currentMode == LibraryViewMode.tracks,
            onTap: () => onModeChanged(LibraryViewMode.tracks),
          ),
          const SizedBox(width: 12),
          _ToggleButton(
            label: "Playlists",
            isActive: currentMode == LibraryViewMode.playlists,
            onTap: () => onModeChanged(LibraryViewMode.playlists),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
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
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppPallete.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppPallete.grey,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
