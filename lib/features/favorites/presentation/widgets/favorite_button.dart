import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';

class FavoriteButton extends StatelessWidget {
  final SongEntity song;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const FavoriteButton({
    super.key,
    required this.song,
    this.size = 24,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBloc, FavoritesState>(
      builder: (context, state) {
        bool isFav = false;
        state.maybeWhen(
          loaded: (ids, _) => isFav = ids.contains(song.id),
          orElse: () {},
        );

        return IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            context.read<FavoritesBloc>().add(
              FavoritesEvent.toggleFavorite(song),
            );
          },
          icon:
              Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav
                        ? (activeColor ?? Colors.redAccent)
                        : (inactiveColor ?? Colors.white54),
                    size: size,
                  )
                  .animate(target: isFav ? 1 : 0)
                  .scale(
                    duration: 200.ms,
                    curve: Curves.easeOutBack,
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.2, 1.2),
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1.0, 1.0),
                  ),
        );
      },
    );
  }
}
