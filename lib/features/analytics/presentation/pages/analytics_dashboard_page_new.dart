import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/features/analytics/domain/entities/analytics_enums.dart';
import 'package:music_player/features/analytics/domain/entities/analytics_stats.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';
import 'package:music_player/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:music_player/features/analytics/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:music_player/features/analytics/presentation/widgets/analytics_card.dart';
import 'package:music_player/features/analytics/presentation/widgets/genre_bar_chart.dart';
import 'package:music_player/features/analytics/presentation/widgets/new%20widgets/activity_by_time_card.dart';
import 'package:music_player/features/analytics/presentation/widgets/new%20widgets/genre_density_card.dart';
import 'package:music_player/features/analytics/presentation/widgets/new%20widgets/heatmap.dart';
import 'package:music_player/features/analytics/presentation/widgets/new%20widgets/recent_activity_card.dart';
import 'package:music_player/features/analytics/presentation/widgets/new%20widgets/temporal_distribution_chart.dart';
import 'package:music_player/features/analytics/presentation/widgets/new%20widgets/top_genres_horizontal_bar.dart';
import 'package:music_player/features/analytics/presentation/widgets/time_of_day_chart.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../../../../../../../core/di/init_dependencies.dart';
import '../../../../../../../core/theme/app_pallete.dart';

@RoutePage()
class AnalyticsDashboardPage extends StatelessWidget {
  const AnalyticsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<AnalyticsBloc>()
            ..add(
              const AnalyticsEvent.loadAnalyticsData(timeFrame: TimeFrame.week),
            ),
        ),
        BlocProvider(
          create: (_) =>
              serviceLocator<HistoryBloc>()
                ..add(const HistoryEvent.fetchAllHistory()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppPallete.background,
        body: const _AnalyticsBody(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// BODY
// ---------------------------------------------------------------------------

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          title: Text(
            'Insights',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
          backgroundColor: AppPallete.background,
          floating: true,
          pinned: true,
          elevation: 0,
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverToBoxAdapter(child: _TimeFrameTabs()),
        ),
        const SliverPadding(padding: EdgeInsets.only(top: 16)),
        BlocBuilder<AnalyticsBloc, AnalyticsState>(
          builder: (context, state) => state.map(
            initial: (_) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            loading: (_) => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppPallete.accent),
              ),
            ),
            failure: (f) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error: ${f.message}',
                  style: const TextStyle(color: AppPallete.destructive),
                ),
              ),
            ),
            loaded: (data) => BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, historyState) {
                final allLogs = historyState.maybeMap(
                  loaded: (s) => s.allHistory,
                  orElse: () => <PlayLog>[],
                );
                return _buildDashboard(context, data, allLogs);
              },
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
      ],
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    dynamic data,
    List<PlayLog> logs,
  ) {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 1. Hero stats (replaces confusing circular chart) ────────
              _ListeningHero(
                totalMinutes: data.stats.totalMinutes as int,
                totalSongs: data.stats.totalSongsPlayed as int,
                timeOfDayDistribution:
                    data.stats.timeOfDayDistribution as Map<String, int>,
              ),

              const SizedBox(height: 16),

              // ── 2. Activity card ─────────────────────────────────────────
              AnalyticsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppPallete.foreground,
                          ),
                        ),
                        Icon(Icons.timeline, color: AppPallete.chart1),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Time-of-day distribution chart (already real)
                    TimeOfDayChart(
                      distribution:
                          data.stats.timeOfDayDistribution as Map<String, int>,
                    ),
                    const SizedBox(height: 16),
                    // Donut breakdown — now wired to real data
                    ActivityByTimeCard(
                      distribution:
                          data.stats.timeOfDayDistribution as Map<String, int>,
                    ),
                    const SizedBox(height: 16),
                    // 7-day bar chart — from history logs
                    RecentActivityCard(logs: logs),
                    const SizedBox(height: 16),
                    // Heatmap grid — from history logs
                    HeatmapCard(logs: logs),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── 3. Listening trend line chart ─────────────────────────
              TemporalDistributionChart(logs: logs),

              const SizedBox(height: 16),

              // ── 4. Genre density bubbles ──────────────────────────────
              GenreDensityCard(topGenres: data.topGenres as List<TopItem>),

              const SizedBox(height: 16),

              // ── 5. Top genres ─────────────────────────────────────────
              AnalyticsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Top Genres',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.foreground,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GenreBarChart(genres: data.topGenres as List<TopItem>),
                    const SizedBox(height: 20),
                    TopGenresCard(genres: data.topGenres as List<TopItem>),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── 6. Top songs ──────────────────────────────────────────
              const Text(
                'Top Songs',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.foreground,
                ),
              ),
              const SizedBox(height: 12),
              ...(data.topSongs as List<TopItem>).asMap().entries.map(
                (e) => _TopSongTile(index: e.key + 1, item: e.value),
              ),

              const SizedBox(height: 24),

              // ── 7. Top artists ────────────────────────────────────────
              const Text(
                'Top Artists',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppPallete.foreground,
                ),
              ),
              const SizedBox(height: 12),
              ...(data.topArtists as List<TopItem>).asMap().entries.map(
                (e) => _TopArtistTile(index: e.key + 1, item: e.value),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
// LISTENING HERO  (replaces the confusing circular chart)
// ---------------------------------------------------------------------------

class _ListeningHero extends StatelessWidget {
  final int totalMinutes;
  final int totalSongs;
  final Map<String, int> timeOfDayDistribution;

  const _ListeningHero({
    required this.totalMinutes,
    required this.totalSongs,
    required this.timeOfDayDistribution,
  });

  String _fmtMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  Widget build(BuildContext context) {
    final morning = timeOfDayDistribution['morning'] ?? 0;
    final afternoon = timeOfDayDistribution['afternoon'] ?? 0;
    final night = timeOfDayDistribution['night'] ?? 0;
    final total = morning + afternoon + night;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1C6A).withValues(alpha: 0.35),
            const Color(0xFF16181D),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat row
          Row(
            children: [
              _StatBlock(
                label: 'Listening time',
                value: _fmtMinutes(totalMinutes),
                accent: const Color(0xFF1976D2),
              ),
              const SizedBox(width: 24),
              _StatBlock(
                label: 'Songs played',
                value: '$totalSongs',
                accent: const Color(0xFF9C27B0),
              ),
            ],
          ),
          if (total > 0) ...[
            const SizedBox(height: 20),
            // Stacked time-of-day bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 6,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final morningW = total > 0
                        ? constraints.maxWidth * morning / total
                        : 0.0;
                    final afternoonW = total > 0
                        ? constraints.maxWidth * afternoon / total
                        : 0.0;
                    final nightW = constraints.maxWidth - morningW - afternoonW;
                    return Row(
                      children: [
                        Container(
                          width: morningW,
                          color: const Color(0xFFFFB300),
                        ),
                        Container(
                          width: afternoonW,
                          color: const Color(0xFF1976D2),
                        ),
                        Container(
                          width: nightW,
                          color: const Color(0xFF9C27B0),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _Dot(color: const Color(0xFFFFB300), label: 'Morning $morning'),
                const SizedBox(width: 16),
                _Dot(
                  color: const Color(0xFF1976D2),
                  label: 'Afternoon $afternoon',
                ),
                const SizedBox(width: 16),
                _Dot(color: const Color(0xFF9C27B0), label: 'Night $night'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _StatBlock({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 11,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: accent.withValues(alpha: 0.5), blurRadius: 12),
          ],
        ),
      ),
    ],
  );
}

class _Dot extends StatelessWidget {
  final Color color;
  final String label;
  const _Dot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.45),
          fontSize: 11,
        ),
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// TIME FRAME TABS
// ---------------------------------------------------------------------------

class _TimeFrameTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        final selected = state.maybeMap(
          loaded: (s) => s.selectedTimeFrame,
          orElse: () => TimeFrame.week,
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _TabButton(
                label: 'Day',
                isSelected: selected == TimeFrame.day,
                onTap: () => _update(context, TimeFrame.day),
              ),
              _TabButton(
                label: 'Week',
                isSelected: selected == TimeFrame.week,
                onTap: () => _update(context, TimeFrame.week),
              ),
              _TabButton(
                label: 'Month',
                isSelected: selected == TimeFrame.month,
                onTap: () => _update(context, TimeFrame.month),
              ),
              _TabButton(
                label: 'All Time',
                isSelected: selected == TimeFrame.all,
                onTap: () => _update(context, TimeFrame.all),
              ),
            ],
          ),
        );
      },
    );
  }

  void _update(BuildContext context, TimeFrame frame) => context
      .read<AnalyticsBloc>()
      .add(AnalyticsEvent.loadAnalyticsData(timeFrame: frame));
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: isSelected ? AppPallete.accent : AppPallete.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppPallete.accent.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppPallete.grey,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// ENHANCED TOP SONG TILE
// ---------------------------------------------------------------------------

class _TopSongTile extends StatelessWidget {
  final int index;
  final TopItem item;
  const _TopSongTile({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    final isTop3 = index <= 3;
    final rankColors = [
      const Color(0xFFFFD700), // gold
      const Color(0xFFB0BEC5), // silver
      const Color(0xFFCD7F32), // bronze
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppPallete.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop3
              ? rankColors[index - 1].withValues(alpha: 0.25)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Rank badge
          SizedBox(
            width: 28,
            child: isTop3
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: rankColors[index - 1].withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#$index',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: rankColors[index - 1],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : Text(
                    '#$index',
                    style: const TextStyle(
                      color: AppPallete.grey,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Artwork
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: QueryArtworkWidget(
                id: int.tryParse(item.id) ?? 0,
                type: ArtworkType.AUDIO,
                artworkBorder: BorderRadius.circular(8),
                nullArtworkWidget: Container(
                  color: AppPallete.background,
                  child: const Icon(
                    Icons.music_note,
                    color: AppPallete.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppPallete.foreground,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 3),
                Text(
                  item.subtitle ?? 'Unknown Artist',
                  style: const TextStyle(color: AppPallete.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Play count pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppPallete.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${item.count}×',
              style: const TextStyle(
                color: AppPallete.accent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ENHANCED TOP ARTIST TILE
// ---------------------------------------------------------------------------

class _TopArtistTile extends StatelessWidget {
  final int index;
  final TopItem item;
  const _TopArtistTile({required this.index, required this.item});

  Color _avatarColor(String name) {
    final colors = [
      const Color(0xFF1976D2),
      const Color(0xFF9C27B0),
      const Color(0xFF00897B),
      const Color(0xFFE65100),
      const Color(0xFF37474F),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final initials = item.title.isNotEmpty
        ? item.title.split(' ').take(2).map((w) => w[0].toUpperCase()).join()
        : '?';
    final color = _avatarColor(item.title);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppPallete.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 24,
            child: Text(
              '#$index',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppPallete.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Avatar with initials
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.2),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              item.title,
              style: const TextStyle(
                color: AppPallete.foreground,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.count}',
                style: const TextStyle(
                  color: AppPallete.chart2,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                'plays',
                style: const TextStyle(color: AppPallete.grey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
