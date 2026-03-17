import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:home_widget/home_widget.dart';

class OsWidgetManager {
  static Future<void> initialize(AudioHandler audioHandler) async {
    HomeWidget.registerInteractivityCallback((uri) async {
      if (uri == null) return;

      if (uri.host == 'playPause') {
        final playing = audioHandler.playbackState.value.playing;
        if (playing) {
          await audioHandler.pause();
        } else {
          await audioHandler.play();
        }
      } else if (uri.host == 'next') {
        await audioHandler.skipToNext();
      } else if (uri.host == 'previous') {
        await audioHandler.skipToPrevious();
      }
    });
  }
}
