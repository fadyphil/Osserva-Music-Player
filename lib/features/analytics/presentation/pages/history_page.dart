import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';
import 'package:music_player/features/analytics/presentation/bloc/history_bloc/history_bloc.dart';

@RoutePage()
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<HistoryBloc>()..add(const HistoryEvent.fetchAllHistory()),
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppPallete.backgroundColor,
          title: const Text('Listening History'),
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => const SizedBox.shrink(),
              loading: (_) => const Center(child: CircularProgressIndicator()),
              failure: (f) => Center(child: Text('Error: ${f.message}')),
              loaded: (data) {
                if (data.allHistory.isEmpty) {
                  return const Center(child: Text('No history yet.'));
                }
                
                // Group by Date
                final grouped = _groupByDate(data.allHistory);
                final dates = grouped.keys.toList();

                return ListView.builder(
                  itemCount: dates.length,
                  itemBuilder: (context, index) {
                    final date = dates[index];
                    final logs = grouped[date]!;
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _formatDate(date),
                            style: const TextStyle(
                              color: AppPallete.primaryGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ...logs.map((log) => ListTile(
                          leading: const Icon(Icons.music_note, color: Colors.white54),
                          title: Text(log.songTitle, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            '${log.artist} • ${DateFormat('hh:mm a').format(log.timestamp)}',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        )),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Map<DateTime, List<PlayLog>> _groupByDate(List<PlayLog> logs) {
    final Map<DateTime, List<PlayLog>> map = {};
    for (var log in logs) {
      final date = DateTime(log.timestamp.year, log.timestamp.month, log.timestamp.day);
      if (!map.containsKey(date)) {
        map[date] = [];
      }
      map[date]!.add(log);
    }
    return map;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return DateFormat('MMMM d, yyyy').format(date);
  }
}
