import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osserva/features/analytics/domain/entities/play_log.dart';
import 'package:osserva/features/home/presentation/widgets/recently_played_list.dart';

void main() {
  final sampleLogs = [
    PlayLog(
      id: 1,
      songId: 101,
      songTitle: 'Song 1',
      artist: 'Artist 1',
      album: 'Album 1',
      genre: 'Genre 1',
      timestamp: DateTime.now(),
      durationListenedSeconds: 125, // 2:05
      isCompleted: true,
      sessionTimeOfDay: 'morning',
    ),
  ];

  testWidgets('RecentlyPlayedList displays songs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecentlyPlayedList(
            songs: sampleLogs,
            onPlay: (_) {},
            onSeeAll: () {},
          ),
        ),
      ),
    );

    expect(find.text('Recently Played'), findsOneWidget);
    expect(find.text('Song 1'), findsOneWidget);
    expect(find.textContaining('Artist 1'), findsOneWidget);
    expect(find.textContaining('Album 1'), findsOneWidget);
    // Duration verification: 125 seconds -> 2:05
    expect(find.text('2:05'), findsOneWidget);
  });
}
