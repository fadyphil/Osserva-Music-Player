import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';

part 'playlist_model.freezed.dart';
part 'playlist_model.g.dart';

@freezed
abstract class PlaylistModel with _$PlaylistModel {
  const factory PlaylistModel({
    required int id,
    required String name,
    required String description,
    @JsonKey(name: 'image_path') String? imagePath,
    @JsonKey(name: 'created_at') required int createdAt,
    @JsonKey(name: 'updated_at') required int updatedAt,
    // These might be computed or joined, for now let's assume they are stored or derived
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(0)
    int totalSongs,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default(0)
    int totalDurationSeconds,
    @JsonKey(includeFromJson: false, includeToJson: false)
    @Default([])
    List<int> songIds,
  }) = _PlaylistModel;

  factory PlaylistModel.fromJson(Map<String, dynamic> json) =>
      _$PlaylistModelFromJson(json);
}

extension PlaylistModelX on PlaylistModel {
  PlaylistEntity toEntity() {
    return PlaylistEntity(
      id: id,
      name: name,
      description: description,
      imagePath: imagePath,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(updatedAt),
      totalSongs: totalSongs,
      totalDurationSeconds: totalDurationSeconds,
      songIds: songIds,
    );
  }
}
