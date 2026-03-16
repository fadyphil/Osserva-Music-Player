import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/playlists/domain/entities/playlist_entity.dart';
import 'package:osserva/features/playlists/domain/usecases/add_song_to_playlist.dart'; // Import
import 'package:osserva/features/playlists/domain/usecases/create_playlist.dart';
import 'package:osserva/features/playlists/domain/usecases/delete_playlist.dart';
import 'package:osserva/features/playlists/domain/usecases/get_playlists.dart';

part 'playlist_event.dart';
part 'playlist_state.dart';
part 'playlist_bloc.freezed.dart';

class PlaylistBloc extends Bloc<PlaylistEvent, PlaylistState> {
  final GetPlaylists _getPlaylists;
  final CreatePlaylist _createPlaylist;
  final DeletePlaylist _deletePlaylist;
  final AddSongToPlaylist _addSongToPlaylist; // Add field

  PlaylistBloc({
    required GetPlaylists getPlaylists,
    required CreatePlaylist createPlaylist,
    required DeletePlaylist deletePlaylist,
    required AddSongToPlaylist addSongToPlaylist, // Add param
  }) : _getPlaylists = getPlaylists,
       _createPlaylist = createPlaylist,
       _deletePlaylist = deletePlaylist,
       _addSongToPlaylist = addSongToPlaylist,
       super(const PlaylistState.initial()) {
    on<_LoadPlaylists>(_onLoadPlaylists);
    on<_CreatePlaylist>(_onCreatePlaylist);
    on<_DeletePlaylist>(_onDeletePlaylist);
    on<_AddSongToPlaylist>(_onAddSongToPlaylist); // Add handler
  }

  Future<void> _onLoadPlaylists(
    _LoadPlaylists event,
    Emitter<PlaylistState> emit,
  ) async {
    emit(const PlaylistState.loading());
    final result = await _getPlaylists(NoParams());
    result.fold(
      (failure) => emit(PlaylistState.failure(failure.message)),
      (playlists) => emit(PlaylistState.loaded(playlists)),
    );
  }

  Future<void> _onCreatePlaylist(
    _CreatePlaylist event,
    Emitter<PlaylistState> emit,
  ) async {
    // Optimistic or reloading? Reloading is safer for ID generation.
    // We don't want to replace the whole list state with "loading" just for one add, ideally.
    // But for simplicity:
    final result = await _createPlaylist(
      CreatePlaylistParams(
        name: event.name,
        description: event.description,
        imagePath: event.imagePath,
      ),
    );

    result.fold((failure) => emit(PlaylistState.failure(failure.message)), (
      newPlaylist,
    ) {
      add(const PlaylistEvent.loadPlaylists());
    });
  }

  Future<void> _onDeletePlaylist(
    _DeletePlaylist event,
    Emitter<PlaylistState> emit,
  ) async {
    final result = await _deletePlaylist(event.playlistId);
    result.fold(
      (failure) => emit(PlaylistState.failure(failure.message)),
      (_) => add(const PlaylistEvent.loadPlaylists()),
    );
  }

  Future<void> _onAddSongToPlaylist(
    _AddSongToPlaylist event,
    Emitter<PlaylistState> emit,
  ) async {
    // We assume successful add for now or show error.
    // We ideally shouldn't reload the whole list just for a count update, but it's consistent.
    final result = await _addSongToPlaylist(
      AddSongToPlaylistParams(playlistId: event.playlistId, song: event.song),
    );

    result.fold(
      (failure) => emit(PlaylistState.failure(failure.message)),
      (_) => add(const PlaylistEvent.loadPlaylists()),
    );
  }
}
