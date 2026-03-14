import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist_stats.freezed.dart';

@freezed
abstract class ArtistStats with _$ArtistStats {
  const factory ArtistStats({
    required String artistName,
    required int totalPlays,
    required int totalDurationSeconds,
    required int sessions,
    String? dominantTimeOfDay,
  }) = _ArtistStats;
}
