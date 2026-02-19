import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:music_player/core/theme/app_pallete.dart';

class HomeHeader extends StatelessWidget {
  final String greeting;
  final int trackCount;

  const HomeHeader({
    super.key,
    required this.greeting,
    required this.trackCount,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('MMMM d, yyyy').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: AppPallete.accent,
                   borderRadius: BorderRadius.circular(8),
                 ),
                 child: const Icon(Icons.music_note, color: AppPallete.white, size: 20),
              ),
              IconButton(
                icon: const Icon(Icons.menu, color: AppPallete.white), // Menu icon is white in design? No, usually foreground.
                color: AppPallete.foreground,
                onPressed: () {
                   // Open drawer or settings
                },
              )
            ],
          ),
          const SizedBox(height: 24),
          Text(
            greeting,
            style: const TextStyle(
              fontSize: 24, // text-2xl
              fontWeight: FontWeight.w500, // font-medium
              color: AppPallete.foreground,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$date • $trackCount tracks offline',
            style: const TextStyle(
              fontSize: 14, // text-sm
              color: AppPallete.grey,
            ),
          ),
        ],
      ),
    );
  }
}
