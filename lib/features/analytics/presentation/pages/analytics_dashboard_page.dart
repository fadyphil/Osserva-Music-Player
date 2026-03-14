// import 'package:auto_route/auto_route.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../../../core/di/init_dependencies.dart';
// import '../../../../core/theme/app_pallete.dart';
// import '../../domain/entities/analytics_enums.dart';
// import '../../domain/entities/analytics_stats.dart';
// import '../bloc/analytics_bloc.dart';
// import '../widgets/analytics_card.dart';
// import '../widgets/activity_by_time_card.dart';
// import '../widgets/genre_bar_chart.dart';
// import '../widgets/genre_density_card.dart';
// import '../widgets/heatmap.dart';
// import '../widgets/listening_time_chart.dart';
// import '../widgets/recent_activity_card.dart';
// import '../widgets/temporal_distribution_chart.dart';
// import '../widgets/time_of_day_chart.dart';
// import '../widgets/top_genres_horizontal_bar.dart';

// @RoutePage()
// class AnalyticsDashboardPage extends StatelessWidget {
//   const AnalyticsDashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => serviceLocator<AnalyticsBloc>()
//         ..add(
//           const AnalyticsEvent.loadAnalyticsData(timeFrame: TimeFrame.week),
//         ),
//       child: Scaffold(
//         backgroundColor: AppPallete.background,
//         body: const _AnalyticsBody(),
//       ),
//     );
//   }
// }

// class _AnalyticsBody extends StatelessWidget {
//   const _AnalyticsBody();

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         const SliverAppBar(
//           title: Text(
//             'Insights',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
//           ),
//           backgroundColor: AppPallete.background,
//           floating: true,
//           pinned: true,
//           elevation: 0,
//         ),
//         SliverPadding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           sliver: SliverToBoxAdapter(child: _TimeFrameTabs()),
//         ),
//         const SliverPadding(padding: EdgeInsets.only(top: 16)),
//         BlocBuilder<AnalyticsBloc, AnalyticsState>(
//           builder: (context, state) {
//             return state.map(
//               initial: (_) =>
//                   const SliverToBoxAdapter(child: SizedBox.shrink()),
//               loading: (_) => const SliverFillRemaining(
//                 child: Center(
//                   child: CircularProgressIndicator(
//                     color: AppPallete.accent,
//                   ),
//                 ),
//               ),
//               failure: (f) => SliverFillRemaining(
//                 child: Center(
//                   child: Text(
//                     'Error: ${f.message}',
//                     style: const TextStyle(color: AppPallete.destructive),
//                   ),
//                 ),
//               ),
//               loaded: (data) => _buildDashboard(context, data),
//             );
//           },
//         ),
//         const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
//       ],
//     );
//   }

//   Widget _buildDashboard(BuildContext context, dynamic data) {
//     return SliverList(
//       delegate: SliverChildListDelegate([
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 1. Hero Chart: Listening Time
//               AnalyticsCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Listening Time',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppPallete.foreground,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     ListeningTimeChart(
//                       totalMinutes: data.stats.totalMinutes,
//                       totalSongs: data.stats.totalSongsPlayed,
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // 2. Activity Trends (Time of Day)
//               AnalyticsCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Activity',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: AppPallete.foreground,
//                           ),
//                         ),
//                         Icon(Icons.timeline, color: AppPallete.chart1),
//                       ],
//                     ),
//                     const SizedBox(height: 20),
//                     TimeOfDayChart(
//                       distribution: data.stats.timeOfDayDistribution,
//                     ),
//                     const SizedBox(height: 16),
//                     const ActivityByTimeCard(),
//                     const SizedBox(height: 16),
//                     const RecentActivityCard(),
//                     const SizedBox(height: 16),
//                     const HeatmapCard(),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // 2.5. Temporal Distribution (Hardcoded for visualization)
//               const TemporalDistributionChart(),

//               const SizedBox(height: 16),

//               // 2.6. Genre Density (Hardcoded for visualization)
//               const GenreDensityCard(),

//               const SizedBox(height: 16),

//               // 3. Top Genres Bar Chart
//               AnalyticsCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Top Genres',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: AppPallete.foreground,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     GenreBarChart(genres: data.topGenres),
//                     const SizedBox(height: 20),
//                     const TopGenresCard(),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 16),

//               // 4. Top Songs List (Styled)
//               const Text(
//                 'Top Songs',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppPallete.foreground,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...(data.topSongs as List<TopItem>).asMap().entries.map(
//                 (e) => _TopSongTile(index: e.key + 1, item: e.value),
//               ),

//               const SizedBox(height: 24),

//               // 5. Top Artists List (Styled)
//               const Text(
//                 'Top Artists',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: AppPallete.foreground,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               ...(data.topArtists as List<TopItem>).asMap().entries.map(
//                 (e) => _TopArtistTile(index: e.key + 1, item: e.value),
//               ),
//             ],
//           ),
//         ),
//       ]),
//     );
//   }
// }

// class _TimeFrameTabs extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<AnalyticsBloc, AnalyticsState>(
//       builder: (context, state) {
//         final selected = state.maybeMap(
//           loaded: (state) => state.selectedTimeFrame,
//           orElse: () => TimeFrame.week,
//         );

//         return SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Row(
//             children: [
//               _TabButton(
//                 label: 'Day',
//                 isSelected: selected == TimeFrame.day,
//                 onTap: () => _update(context, TimeFrame.day),
//               ),
//               _TabButton(
//                 label: 'Week',
//                 isSelected: selected == TimeFrame.week,
//                 onTap: () => _update(context, TimeFrame.week),
//               ),
//               _TabButton(
//                 label: 'Month',
//                 isSelected: selected == TimeFrame.month,
//                 onTap: () => _update(context, TimeFrame.month),
//               ),
//               _TabButton(
//                 label: 'All Time',
//                 isSelected: selected == TimeFrame.all,
//                 onTap: () => _update(context, TimeFrame.all),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   void _update(BuildContext context, TimeFrame frame) {
//     context.read<AnalyticsBloc>().add(
//       AnalyticsEvent.loadAnalyticsData(timeFrame: frame),
//     );
//   }
// }

// class _TabButton extends StatelessWidget {
//   final String label;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _TabButton({
//     required this.label,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? AppPallete.accent : AppPallete.surface,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: isSelected
//               ? [
//                   BoxShadow(
//                     color: AppPallete.accent.withValues(alpha: 0.4),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : AppPallete.grey,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _TopSongTile extends StatelessWidget {
//   final int index;
//   final TopItem item;

//   const _TopSongTile({required this.index, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return AnalyticsCard(
//       height: 80,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Text(
//             '#$index',
//             style: const TextStyle(
//               color: AppPallete.grey,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: AppPallete.surface,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.music_note, color: AppPallete.foreground),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.title,
//                   style: const TextStyle(
//                     color: AppPallete.foreground,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 Text(
//                   item.subtitle ?? 'Unknown Artist',
//                   style: const TextStyle(color: AppPallete.grey, fontSize: 14),
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//             decoration: BoxDecoration(
//               color: AppPallete.surface,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Text(
//               '${item.count}',
//               style: const TextStyle(
//                 color: AppPallete.accent,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _TopArtistTile extends StatelessWidget {
//   final int index;
//   final TopItem item;

//   const _TopArtistTile({required this.index, required this.item});

//   @override
//   Widget build(BuildContext context) {
//     return AnalyticsCard(
//       height: 70,
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: AppPallete.surface,
//             ),
//             child: const Icon(Icons.person, color: AppPallete.grey, size: 20),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               item.title,
//               style: const TextStyle(
//                 color: AppPallete.foreground,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 16,
//               ),
//             ),
//           ),
//           Text(
//             '${item.count} plays',
//             style: const TextStyle(
//               color: AppPallete.chart2,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
