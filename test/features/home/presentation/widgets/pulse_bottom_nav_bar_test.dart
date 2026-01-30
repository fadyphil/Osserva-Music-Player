import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:music_player/features/home/domain/entities/home_tab.dart';
import 'package:music_player/features/home/presentation/widgets/pulse_bottom_nav_bar.dart';

void main() {
  testWidgets('PulseBottomNavBar displays correct tabs and handles taps', (tester) async {
    HomeTab selectedTab = HomeTab.songs;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: StatefulBuilder(
            builder: (context, setState) {
              return PulseBottomNavBar(
                selectedTab: selectedTab,
                onTabSelected: (tab) {
                  setState(() {
                    selectedTab = tab;
                  });
                },
              );
            },
          ),
        ),
      ),
    );

    // Verify tabs exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Initial state: Home selected
    // Visual verification is hard without golden tests, but we can verify interaction.

    // Tap Analytics
    await tester.tap(find.text('Analytics'));
    await tester.pump();

    expect(selectedTab, HomeTab.analytics);

    // Tap Profile
    await tester.tap(find.text('Profile'));
    await tester.pump();

    expect(selectedTab, HomeTab.profile);
  });
}
