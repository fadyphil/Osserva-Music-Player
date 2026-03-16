import 'dart:io';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/core/router/app_router.dart';
import 'package:osserva/core/theme/app_pallete.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/achievement_entity.dart';
import '../../../analytics/domain/entities/analytics_stats.dart';
import '../bloc/profile_bloc.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const ProfileEvent.loadProfile());
  }

  @override
  Widget build(BuildContext context) {
    // Assuming AppPallete.background is the very dark blue/black from screenshots
    // Assuming AppPallete.surface is the slightly lighter card color
    return Scaffold(
      backgroundColor: AppPallete.background,
      appBar: AppBar(
        backgroundColor: AppPallete.background,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppPallete.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.music_note, color: Colors.white),
          ),
        ),
        title: const Text(
          "Pulse",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {}, // Drawer or menu action
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: AppPallete.destructive,
                ),
              );
            },
            cacheCleared: () {
              context.router.replaceAll([OnboardingRoute()]);
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppPallete.accent),
            ),
            loaded: (user, achievements, stats) => _ProfileView(
              user: user,
              achievements: achievements,
              stats: stats,
            ),
            orElse: () => const Center(
              child: CircularProgressIndicator(color: AppPallete.accent),
            ),
          );
        },
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final UserEntity user;
  final List<AchievementEntity> achievements;
  final ListeningStats stats;

  const _ProfileView({
    required this.user,
    required this.achievements,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Profile Header (Image 3)
          _ProfileHeader(user: user),
          const SizedBox(height: 32),

          // 2. Navigation Layout Selector (Image 3)
          const _SectionHeader("Navigation Layout"),
          const SizedBox(height: 12),
          _NavigationLayoutSelector(selectedStyle: user.preferredNavBar),
          const SizedBox(height: 32),

          // 3. Maintenance / Cache (Image 2)
          const _SectionHeader("Maintenance"),
          const SizedBox(height: 12),
          const _MaintenanceSection(),
          const SizedBox(height: 32),

          // 4. All-Time Stats (Image 2)
          const _SectionHeader("All-Time Stats"),
          const SizedBox(height: 12),
          _AllTimeStatsGrid(stats: stats),
          const SizedBox(height: 32),

          // 5. Listening Insights (Image 1)
          const _SectionHeader("Listening Insights"),
          const SizedBox(height: 12),
          _ListeningInsightsList(stats: stats),
          const SizedBox(height: 32),

          // 6. Achievements & Suggestions (Image 4)
          const _SectionHeader("Achievements"),
          const SizedBox(height: 12),
          _AchievementsSection(achievements: achievements),
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION 1: HEADER (Matches Image 3)
// -----------------------------------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  final UserEntity user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final imageProvider = user.avatarUrl.isNotEmpty
        ? (user.avatarUrl.startsWith('http')
              ? NetworkImage(user.avatarUrl)
              : FileImage(File(user.avatarUrl)) as ImageProvider)
        : null;

    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppPallete.surface,
          backgroundImage: imageProvider,
          child: user.avatarUrl.isEmpty
              ? const Icon(
                  Icons.person_outline,
                  size: 40,
                  color: AppPallete.grey,
                )
              : null,
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your Profile", // Hardcoded per design, or use user.username
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppPallete.foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Offline listener since Jan 2025", // Example static text per design
              style: TextStyle(
                color: AppPallete.grey.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION 2: NAVIGATION LAYOUT (Matches Image 3)
// -----------------------------------------------------------------------------
class _NavigationLayoutSelector extends StatelessWidget {
  final NavBarStyle selectedStyle;
  const _NavigationLayoutSelector({required this.selectedStyle});

  @override
  Widget build(BuildContext context) {
    // We map the designs "Default" and "Minimal" to logical enums
    return Column(
      children: [
        _NavLayoutCard(
          title: "Default",
          description: "Balanced navigation with all core sections",
          isSelected:
              selectedStyle ==
              NavBarStyle.simple, // Mapping 'simple' to Default
          preview: const _NavPreviewSkeleton(isMinimal: false),
          onTap: () {
            context.read<ProfileBloc>().add(
              const ProfileEvent.changeNavBarStyle(NavBarStyle.simple),
            );
          },
        ),
        const SizedBox(height: 16),
        _NavLayoutCard(
          title: "Stylish",
          description: "Focus on music playback and library",
          isSelected:
              selectedStyle ==
              NavBarStyle.neural, // Mapping 'neural' to stylish
          preview: const _NavPreviewSkeleton(isMinimal: true),
          onTap: () {
            context.read<ProfileBloc>().add(
              const ProfileEvent.changeNavBarStyle(NavBarStyle.neural),
            );
          },
        ),
      ],
    );
  }
}

class _NavLayoutCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final Widget preview;
  final VoidCallback onTap;

  const _NavLayoutCard({
    required this.title,
    required this.description,
    required this.isSelected,
    required this.preview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPallete.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppPallete.accent : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppPallete.foreground,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_circle,
                    color: AppPallete.accent,
                    size: 18,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: AppPallete.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            // Visual Preview Area
            Container(
              height: 140,
              decoration: BoxDecoration(
                color: AppPallete.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppPallete.border.withValues(alpha: 0.3),
                ),
              ),
              child: preview,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavPreviewSkeleton extends StatelessWidget {
  final bool isMinimal;
  const _NavPreviewSkeleton({required this.isMinimal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fake Header
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(width: 20, height: 20, color: AppPallete.surface),
              const Spacer(),
              Container(width: 20, height: 20, color: AppPallete.surface),
            ],
          ),
        ),
        // Fake Content Lines
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 8,
                width: 100,
                decoration: BoxDecoration(
                  color: AppPallete.surface,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppPallete.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 8,
                width: 180,
                decoration: BoxDecoration(
                  color: AppPallete.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        // Fake Bottom Bar
        Container(
          height: 40,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppPallete.border, width: 0.5),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              isMinimal ? 3 : 4,
              (index) => Icon(
                Icons.circle,
                size: 8,
                color: index == 0 ? AppPallete.accent : AppPallete.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION 3: MAINTENANCE (Matches Image 2)
// -----------------------------------------------------------------------------
class _MaintenanceSection extends StatelessWidget {
  const _MaintenanceSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPallete.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Clear Cache",
                  style: TextStyle(
                    color: AppPallete.foreground,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Remove cached artwork, waveforms, and temporary analytics data",
                  style: TextStyle(
                    color: AppPallete.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Estimated cache size: ~42 MB", // In real app, calculate this
                  style: TextStyle(
                    color: AppPallete.grey.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          OutlinedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(const ProfileEvent.clearCache());
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppPallete.foreground,
              side: const BorderSide(color: AppPallete.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION 4: ALL-TIME STATS (Matches Image 2)
// -----------------------------------------------------------------------------
class _AllTimeStatsGrid extends StatelessWidget {
  final ListeningStats stats;
  const _AllTimeStatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _StatBox(
          icon: Icons.headset,
          label: "Total Plays",
          value: "${stats.totalSongsPlayed}", // e.g. 4,522
        ),
        _StatBox(
          icon: Icons.schedule,
          label: "Hours Listened",
          value:
              "${(stats.totalMinutes / 60).toStringAsFixed(0)}h", // e.g. 301h
        ),
        _StatBox(
          icon: Icons.trending_up,
          label: "Top Track",
          value: "Terminal Dreams", // Need a stats.topTrack field
          subValue: "165 plays",
        ),
        _StatBox(
          icon: Icons.bookmark_outline,
          label: "Top Genre",
          value: "Electronic", // Need a stats.topGenre field
          subValue: "342 plays",
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPallete.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppPallete.grey),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(color: AppPallete.grey, fontSize: 12),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppPallete.foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subValue != null) ...[
                const SizedBox(height: 4),
                Text(
                  subValue!,
                  style: TextStyle(
                    color: AppPallete.grey.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION 5: LISTENING INSIGHTS (Matches Image 1)
// -----------------------------------------------------------------------------
class _ListeningInsightsList extends StatelessWidget {
  final ListeningStats stats;
  const _ListeningInsightsList({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _InsightCard(
          icon: Icons.show_chart,
          title: "Most Active Period",
          mainText: "Weekday Afternoons",
          subText: "2-6 PM shows 40% higher activity than average",
        ),
        SizedBox(height: 12),
        _InsightCard(
          icon: Icons.headphones,
          title: "Listening Style",
          mainText: "Deep Focus",
          subText: "Long sessions with minimal skips. Avg 45min per session",
        ),
        SizedBox(height: 12),
        _InsightCard(
          icon: Icons.verified_outlined,
          title: "Top Genre Preference",
          mainText: "Electronic",
          subText: "8% of total listening time",
        ),
        SizedBox(height: 12),
        _InsightCard(
          icon: Icons.calendar_today,
          title: "Consistency Score",
          mainText: "High",
          subText: "Active 6.2 days per week on average",
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String mainText;
  final String subText;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.mainText,
    required this.subText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppPallete.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPallete.border.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppPallete.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppPallete.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  mainText,
                  style: const TextStyle(
                    color: AppPallete.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subText,
                  style: TextStyle(
                    color: AppPallete.grey.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SECTION 6: ACHIEVEMENTS & SUGGESTIONS (Matches Image 4)
// -----------------------------------------------------------------------------
class _AchievementsSection extends StatelessWidget {
  final List<AchievementEntity> achievements;
  const _AchievementsSection({required this.achievements});

  @override
  Widget build(BuildContext context) {
    // In a real scenario, use the list. Here mapping to the specific 4 from design
    final displayAchievements = [
      (
        title: "Century Club",
        sub: "100+ plays on a single track",
        icon: Icons.verified_outlined,
      ),
      (
        title: "Night Owl",
        sub: "50+ late night sessions",
        icon: Icons.nights_stay_outlined,
      ),
      (
        title: "Explorer",
        sub: "Listened to 5+ genres",
        icon: Icons.explore_outlined,
      ),
      (
        title: "Streak Master",
        sub: "30 day listening streak",
        icon: Icons.local_fire_department_outlined,
      ),
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 4,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final ach = displayAchievements[index];
            final bool isUnlocked =
                index < 3; // Mocking unlocked state based on image colors

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppPallete.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppPallete.border.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ach.icon,
                    color: isUnlocked
                        ? AppPallete.accent
                        : AppPallete.grey.withValues(alpha: 0.3),
                    size: 28,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ach.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isUnlocked
                          ? AppPallete.foreground
                          : AppPallete.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ach.sub,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppPallete.grey.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        // Suggestion Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppPallete.accent.withValues(alpha: 0.15),
                AppPallete.background,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppPallete.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.trending_up, color: AppPallete.accent, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Suggested Next Session",
                      style: TextStyle(
                        color: AppPallete.foreground,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Based on your patterns, you typically listen to Ambient tracks around this time. Your \"Silent Hours\" album might be a good choice.",
                      style: TextStyle(
                        color: AppPallete.grey.withValues(alpha: 0.8),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: SECTION HEADERS
// -----------------------------------------------------------------------------
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppPallete.grey,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
