import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist_entity.freezed.dart';

@freezed
abstract class PlaylistEntity with _$PlaylistEntity {
  const factory PlaylistEntity({
    required int id,
    required String name,
    required String description,
    String? imagePath,
    required DateTime createdAt,
    required DateTime updatedAt,
    required int totalSongs,
    required int totalDurationSeconds,
    required List<int> songIds,
  }) = _PlaylistEntity;
}
