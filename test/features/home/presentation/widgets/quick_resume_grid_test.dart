import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';
import 'package:music_player/features/home/presentation/widgets/quick_resume_grid.dart';

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
      durationListenedSeconds: 120,
      isCompleted: true,
      sessionTimeOfDay: 'morning',
    ),
    PlayLog(
      id: 2,
      songId: 102,
      songTitle: 'Song 2',
      artist: 'Artist 2',
      album: 'Album 2',
      genre: 'Genre 2',
      timestamp: DateTime.now(),
      durationListenedSeconds: 180,
      isCompleted: false,
      sessionTimeOfDay: 'evening',
    ),
  ];

  testWidgets('QuickResumeGrid displays songs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuickResumeGrid(
            songs: sampleLogs,
            onPlay: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Quick Resume'), findsOneWidget);
    expect(find.text('Song 1'), findsOneWidget);
    expect(find.text('Artist 1'), findsOneWidget);
    expect(find.text('Song 2'), findsOneWidget);
    // 2 cards
    expect(find.byIcon(Icons.play_arrow_outlined), findsWidgets);
  });
}