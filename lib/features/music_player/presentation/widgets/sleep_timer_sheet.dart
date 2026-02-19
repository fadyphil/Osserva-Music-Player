import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_pallete.dart';
import '../bloc/music_player_bloc.dart';
import '../bloc/music_player_event.dart';
import '../bloc/music_player_state.dart';

class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  bool _showCustomPicker = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPallete.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showCustomPicker
            ? _CustomTimerPickerView(
                onBack: () => setState(() => _showCustomPicker = false),
              )
            : _PresetSelectionView(
                onCustomTap: () => setState(() => _showCustomPicker = true),
              ),
      ),
    );
  }
}

class _PresetSelectionView extends StatelessWidget {
  final VoidCallback onCustomTap;

  const _PresetSelectionView({required this.onCustomTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sleep Timer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Active Timer Indicator
                BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
                  builder: (context, state) {
                    if (state.timerRemaining == null &&
                        !state.isEndTrackTimerActive) {
                      return const SizedBox.shrink();
                    }

                    String text = "";
                    if (state.isEndTrackTimerActive) {
                      text = "Active: End of track";
                    } else {
                      final min =
                          state.timerRemaining!.inMinutes +
                          1; // Round up for display
                      text = "Active: $min minutes remaining";
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: AppPallete.accent,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            text,
                            style: const TextStyle(
                              color: AppPallete.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            ),
          ],
        ),
        const Divider(color: Colors.white10),
        const SizedBox(height: 20),

        // Grid of Presets
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: const [
            _TimerPresetCard(minutes: 10),
            _TimerPresetCard(minutes: 15),
            _TimerPresetCard(minutes: 20),
            _TimerPresetCard(minutes: 30),
            _TimerPresetCard(minutes: 45),
            _TimerPresetCard(minutes: 60),
          ],
        ),

        const SizedBox(height: 20),

        // Custom Time OR Cancel Button based on state
        BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
          builder: (context, state) {
            final isTimerActive =
                state.timerRemaining != null || state.isEndTrackTimerActive;

            if (isTimerActive) {
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<MusicPlayerBloc>().add(
                      const MusicPlayerEvent.cancelTimer(),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppPallete.destructive.withValues(alpha: 0.5),
                    ),
                    backgroundColor: AppPallete.destructive.withValues(
                      alpha: 0.1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(
                    Icons.close,
                    color: AppPallete.destructive,
                    size: 18,
                  ),
                  label: const Text(
                    "Cancel Timer",
                    style: TextStyle(
                      color: AppPallete.destructive,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            return InkWell(
              onTap: onCustomTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.white54, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Custom Time",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward, color: Colors.white24, size: 18),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TimerPresetCard extends StatelessWidget {
  final int minutes;

  const _TimerPresetCard({required this.minutes});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
      builder: (context, state) {
        // Check if this specific timer was the one set (optional logic,
        // usually we just check if any timer is running, but let's keep it simple style-wise)
        return InkWell(
          onTap: () {
            context.read<MusicPlayerBloc>().add(
              MusicPlayerEvent.setTimer(duration: Duration(minutes: minutes)),
            );
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$minutes",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "min",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CustomTimerPickerView extends StatefulWidget {
  final VoidCallback onBack;

  const _CustomTimerPickerView({required this.onBack});

  @override
  State<_CustomTimerPickerView> createState() => _CustomTimerPickerViewState();
}

class _CustomTimerPickerViewState extends State<_CustomTimerPickerView> {
  Duration _selectedDuration = const Duration(minutes: 30);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Sleep Timer",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white54, size: 20),
            ),
          ],
        ),
        const Divider(color: Colors.white10),

        const SizedBox(height: 20),

        // Cupertino Picker
        SizedBox(
          height: 160,
          child: CupertinoTheme(
            data: const CupertinoThemeData(brightness: Brightness.dark),
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: _selectedDuration,
              onTimerDurationChanged: (val) {
                setState(() => _selectedDuration = val);
              },
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton(
                onPressed: () {
                  if (_selectedDuration > Duration.zero) {
                    context.read<MusicPlayerBloc>().add(
                      MusicPlayerEvent.setTimer(duration: _selectedDuration),
                    );
                    Navigator.pop(context);
                  }
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Set Timer",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
