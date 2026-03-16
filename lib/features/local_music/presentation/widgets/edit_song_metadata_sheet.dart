import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/core/theme/app_pallete.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/local_music/presentation/managers/local_music_bloc.dart';
import 'package:osserva/features/local_music/presentation/managers/local_music_event.dart';
import 'package:on_audio_query/on_audio_query.dart';

class EditSongMetadataSheet extends StatefulWidget {
  final SongEntity song;

  const EditSongMetadataSheet({super.key, required this.song});

  @override
  State<EditSongMetadataSheet> createState() => _EditSongMetadataSheetState();
}

class _EditSongMetadataSheetState extends State<EditSongMetadataSheet> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;
  // I'll add Genre as extra if space permits, but stick to design first.

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(
      text: widget.song.artist == '<unknown>' ? '' : widget.song.artist,
    );
    _albumController = TextEditingController(
      text: widget.song.album == '<unknown>' ? '' : widget.song.album,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: AppPallete.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Edit Track",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white54),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Artwork Mock
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppPallete.cardColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QueryArtworkWidget(
                  id: widget.song.id,
                  type: ArtworkType.AUDIO,
                  artworkHeight: 80,
                  artworkWidth: 80,
                  artworkFit: BoxFit.cover,
                  nullArtworkWidget: const Icon(
                    Icons.music_note,
                    color: Colors.white24,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  // TOD: Implement Image Picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Change Artwork Not Implemented"),
                    ),
                  );
                },
                child: const Text(
                  "Change Artwork",
                  style: TextStyle(color: AppPallete.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Fields
          _buildTextField("Title", _titleController),
          const SizedBox(height: 16),
          _buildTextField("Artist", _artistController),
          const SizedBox(height: 16),
          _buildTextField("Album", _albumController),

          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    context.read<LocalMusicBloc>().add(
                      LocalMusicEvent.editSong(
                        song: widget.song,
                        title: _titleController.text,
                        artist: _artistController.text,
                        album: _albumController.text,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppPallete.cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
