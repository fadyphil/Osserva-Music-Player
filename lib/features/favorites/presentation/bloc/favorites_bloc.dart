import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/favorites/domain/usecases/add_favorite.dart';
import 'package:music_player/features/favorites/domain/usecases/get_favorite_songs.dart';
import 'package:music_player/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';
part 'favorites_bloc.freezed.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteSongs _getFavoriteSongs;
  final AddFavorite _addFavorite;
  final RemoveFavorite _removeFavorite;

  FavoritesBloc({
    required GetFavoriteSongs getFavoriteSongs,
    required AddFavorite addFavorite,
    required RemoveFavorite removeFavorite,
  }) : _getFavoriteSongs = getFavoriteSongs,
       _addFavorite = addFavorite,
       _removeFavorite = removeFavorite,
       super(const FavoritesState.initial()) {
    on<_LoadFavorites>(_onLoadFavorites);
    on<_ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(_LoadFavorites event, Emitter<FavoritesState> emit) async {
    emit(const FavoritesState.loading());
    final result = await _getFavoriteSongs(NoParams());
    
    result.fold(
      (failure) => emit(FavoritesState.failure(failure.message)),
      (songs) {
        final ids = songs.map((e) => e.id).toSet();
        emit(FavoritesState.loaded(favoriteIds: ids, favoriteSongs: songs));
      },
    );
  }

  Future<void> _onToggleFavorite(_ToggleFavorite event, Emitter<FavoritesState> emit) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final isFavorite = currentState.favoriteIds.contains(event.song.id);
      
      // Optimistic Update
      Set<int> newIds = Set.from(currentState.favoriteIds);
      List<SongEntity> newSongs = List.from(currentState.favoriteSongs);
      
      if (isFavorite) {
        newIds.remove(event.song.id);
        newSongs.removeWhere((s) => s.id == event.song.id);
      } else {
        newIds.add(event.song.id);
        newSongs.insert(0, event.song); // Add to top
      }
      
      emit(currentState.copyWith(favoriteIds: newIds, favoriteSongs: newSongs));
      
      // Perform Side Effect
      final result = isFavorite 
          ? await _removeFavorite(event.song.id)
          : await _addFavorite(event.song);
          
      result.fold(
        (failure) {
          // Revert on failure
          emit(currentState); // Or emit failure state (but that clears list). 
          // Better: Emit failure event or just revert silently?
          // Let's revert and show error (if we had a snackbar listener).
          // For now, simple revert.
        },
        (_) {},
      );
    }
  }
}
