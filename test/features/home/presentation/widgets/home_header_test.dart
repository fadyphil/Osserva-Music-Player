import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osserva/features/home/presentation/widgets/home_header.dart';

void main() {
  testWidgets('HomeHeader displays greeting and track count', (tester) async {
    const greeting = 'Good morning';
    const trackCount = 123;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HomeHeader(greeting: greeting, trackCount: trackCount),
        ),
      ),
    );

    expect(find.text(greeting), findsOneWidget);
    expect(find.textContaining('$trackCount tracks offline'), findsOneWidget);
    expect(find.byIcon(Icons.music_note), findsOneWidget);
  });
}
