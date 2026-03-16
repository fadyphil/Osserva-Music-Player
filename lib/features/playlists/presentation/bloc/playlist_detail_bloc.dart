import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';
import 'package:osserva/features/playlists/domain/entities/playlist_entity.dart';
import 'package:osserva/features/playlists/domain/usecases/add_song_to_playlist.dart';
import 'package:osserva/features/playlists/domain/usecases/edit_playlist.dart';
import 'package:osserva/features/playlists/domain/usecases/get_playlist_songs.dart';
import 'package:osserva/features/playlists/domain/usecases/remove_song_from_playlist.dart';

part 'playlist_detail_event.dart';
part 'playlist_detail_state.dart';
part 'playlist_detail_bloc.freezed.dart';

class PlaylistDetailBloc
    extends Bloc<PlaylistDetailEvent, PlaylistDetailState> {
  final GetPlaylistSongs _getPlaylistSongs;
  final AddSongToPlaylist _addSongToPlaylist;
  final RemoveSongFromPlaylist _removeSongFromPlaylist;
  final EditPlaylist _editPlaylist;

  PlaylistDetailBloc({
    required GetPlaylistSongs getPlaylistSongs,
    required AddSongToPlaylist addSongToPlaylist,
    required RemoveSongFromPlaylist removeSongFromPlaylist,
    required EditPlaylist editPlaylist,
  }) : _getPlaylistSongs = getPlaylistSongs,
       _addSongToPlaylist = addSongToPlaylist,
       _removeSongFromPlaylist = removeSongFromPlaylist,
       _editPlaylist = editPlaylist,
       super(const PlaylistDetailState.initial()) {
    on<_LoadPlaylistDetail>(_onLoadPlaylistDetail);
    on<_AddSong>(_onAddSong);
    on<_RemoveSong>(_onRemoveSong);
    on<_EditPlaylistDetail>(_onEditPlaylistDetail);
  }

  Future<void> _onLoadPlaylistDetail(
    _LoadPlaylistDetail event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    emit(const PlaylistDetailState.loading());
    final result = await _getPlaylistSongs(event.playlist.id);
    result.fold(
      (failure) => emit(PlaylistDetailState.failure(failure.message)),
      (songs) => emit(
        PlaylistDetailState.loaded(playlist: event.playlist, songs: songs),
      ),
    );
  }

  Future<void> _onAddSong(
    _AddSong event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final result = await _addSongToPlaylist(
        AddSongToPlaylistParams(
          playlistId: currentState.playlist.id,
          song: event.song,
        ),
      );

      result.fold(
        (failure) => emit(PlaylistDetailState.failure(failure.message)),
        (_) {
          add(PlaylistDetailEvent.loadPlaylistDetail(currentState.playlist));
        },
      );
    }
  }

  Future<void> _onRemoveSong(
    _RemoveSong event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final result = await _removeSongFromPlaylist(
        RemoveSongFromPlaylistParams(
          playlistId: currentState.playlist.id,
          songId: event.songId,
        ),
      );

      result.fold(
        (failure) => emit(PlaylistDetailState.failure(failure.message)),
        (_) {
          add(PlaylistDetailEvent.loadPlaylistDetail(currentState.playlist));
        },
      );
    }
  }

  Future<void> _onEditPlaylistDetail(
    _EditPlaylistDetail event,
    Emitter<PlaylistDetailState> emit,
  ) async {
    final currentState = state;
    if (currentState is _Loaded) {
      final result = await _editPlaylist(
        EditPlaylistParams(
          id: currentState.playlist.id,
          name: event.name,
          description: event.description,
          imagePath: event.imagePath,
        ),
      );

      result.fold(
        (failure) => emit(PlaylistDetailState.failure(failure.message)),
        (updatedPlaylist) {
          // Keep songs, update playlist info
          emit(currentState.copyWith(playlist: updatedPlaylist));
        },
      );
    }
  }
}
