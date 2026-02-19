import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/home/domain/entities/home_tab.dart';

class PulseBottomNavBar extends StatelessWidget {
  final HomeTab selectedTab;
  final ValueChanged<HomeTab> onTabSelected;

  const PulseBottomNavBar({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
  });

  void _handleTap(HomeTab tab) {
    if (selectedTab != tab) {
      HapticFeedback.lightImpact();
      onTabSelected(tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64, // h-16
      decoration: const BoxDecoration(
        color: AppPallete.background,
        border: Border(
          top: BorderSide(color: AppPallete.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _PulseTabItem(
            label: "Home",
            icon: Icons.home_filled,
            isSelected: selectedTab == HomeTab.songs,
            onTap: () => _handleTap(HomeTab.songs),
          ),
          _PulseTabItem(
            label: "Library",
            icon: Icons.library_music,
            isSelected: selectedTab == HomeTab.library,
            onTap: () => _handleTap(HomeTab.library),
          ),
          _PulseTabItem(
            label: "Artists",
            icon: Icons.people,
            isSelected: selectedTab == HomeTab.artists,
            onTap: () => _handleTap(HomeTab.artists),
          ),
          _PulseTabItem(
            label: "Analytics",
            icon: Icons.bar_chart, // Mapping 'ListMusic' or 'BarChart'
            isSelected: selectedTab == HomeTab.analytics,
            onTap: () => _handleTap(HomeTab.analytics),
          ),
          _PulseTabItem(
            label: "Profile",
            icon: Icons.person, // Mapping 'User'
            isSelected: selectedTab == HomeTab.profile,
            onTap: () => _handleTap(HomeTab.profile),
          ),
        ],
      ),
    );
  }
}

class _PulseTabItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PulseTabItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppPallete.accent : AppPallete.grey;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 20, // w-5 h-5
            ),
            const SizedBox(height: 4), // mb-1 equivalent
            Text(
              label,
              style: TextStyle(
                fontSize: 12, // text-xs
                color: color,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
