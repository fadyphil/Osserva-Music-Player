import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/analytics/domain/usecases/get_all_song_play_counts.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';
import 'package:music_player/features/local_music/domain/usecases/delete_song.dart';
import 'package:music_player/features/local_music/domain/usecases/edit_song_metadata.dart';
import 'package:music_player/features/local_music/domain/usecases/get_local_songs_use_case.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_state.dart';
import 'package:stream_transform/stream_transform.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) {
    return events.debounce(duration).switchMap(mapper);
  };
}

class LocalMusicBloc extends Bloc<LocalMusicEvent, LocalMusicState> {
  final GetLocalSongsUseCase _getLocalSongsUseCase;
  final GetAllSongPlayCounts _getAllSongPlayCountsUseCase;
  final DeleteSong _deleteSongUseCase;
  final EditSongMetadata _editSongMetadataUseCase;

  // FIX: Sort preference not applied on first load.
  //
  // _onSortSongs calls state.mapOrNull(loaded: ...) which is a no-op when
  // state is still `initial`. By storing the desired sort as a field on the
  // bloc itself, _onGetLocalSongs picks it up regardless of dispatch order.
  // This means the page can safely dispatch SortSongs before GetLocalSongs
  // (to restore saved preferences) and the load will honour that choice.
  SortOption _pendingSort = SortOption.dateAdded;

  LocalMusicBloc(
    this._getLocalSongsUseCase,
    this._getAllSongPlayCountsUseCase,
    this._deleteSongUseCase,
    this._editSongMetadataUseCase,
  ) : super(const LocalMusicState.initial()) {
    on<GetLocalSongs>(_onGetLocalSongs);
    on<SearchSongs>(
      _onSearchSongs,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
    on<SortSongs>(_onSortSongs);
    on<DeleteSongEvent>(_onDeleteSong);
    on<EditSongEvent>(_onEditSong);
  }

  Future<void> _onDeleteSong(
    DeleteSongEvent event,
    Emitter<LocalMusicState> emit,
  ) async {
    final result = await _deleteSongUseCase(event.song);
    result.fold(
      (failure) => emit(LocalMusicState.failure(failure)),
      (success) {
        if (success) add(const GetLocalSongs());
      },
    );
  }

  Future<void> _onEditSong(
    EditSongEvent event,
    Emitter<LocalMusicState> emit,
  ) async {
    final result = await _editSongMetadataUseCase(
      EditSongMetadataParams(
        song: event.song,
        title: event.title,
        artist: event.artist,
        album: event.album,
        genre: event.genre,
        year: event.year,
        artworkBytes: event.artworkBytes,
      ),
    );
    result.fold(
      (failure) => emit(LocalMusicState.failure(failure)),
      (success) {
        if (success) add(const GetLocalSongs());
      },
    );
  }

  Future<void> _onGetLocalSongs(
    GetLocalSongs event,
    Emitter<LocalMusicState> emit,
  ) async {
    emit(const LocalMusicState.loading());

    final (songsResult, countsResult) = await (
      _getLocalSongsUseCase(NoParams()),
      _getAllSongPlayCountsUseCase(NoParams()),
    ).wait;

    songsResult.fold(
      (failure) => emit(LocalMusicState.failure(failure)),
      (songs) {
        final Map<int, int> counts = countsResult.fold(
          (l) => <int, int>{},
          (r) => r,
        );

        // Use _pendingSort so any SortSongs dispatched before the load
        // (e.g. restoring saved preference) is honoured.
        final processed = _processSongs(songs, '', _pendingSort, counts);

        emit(
          LocalMusicState.loaded(
            allSongs: songs,
            processedSongs: processed,
            playCounts: counts,
            searchQuery: '',
            sortOption: _pendingSort,
          ),
        );
      },
    );
  }

  void _onSearchSongs(SearchSongs event, Emitter<LocalMusicState> emit) {
    state.mapOrNull(
      loaded: (currentState) {
        emit(currentState.copyWith(isSearching: true));

        final processed = _processSongs(
          currentState.allSongs,
          event.query,
          currentState.sortOption,
          currentState.playCounts,
        );

        emit(
          currentState.copyWith(
            processedSongs: processed,
            searchQuery: event.query,
            isSearching: false,
          ),
        );
      },
    );
  }

  void _onSortSongs(SortSongs event, Emitter<LocalMusicState> emit) {
    // Always update _pendingSort so the preference is captured even if
    // this fires before the initial load completes.
    _pendingSort = event.option;

    state.mapOrNull(
      loaded: (currentState) {
        final processed = _processSongs(
          currentState.allSongs,
          currentState.searchQuery,
          event.option,
          currentState.playCounts,
        );

        emit(
          currentState.copyWith(
            processedSongs: processed,
            sortOption: event.option,
          ),
        );
      },
    );
  }

  List<SongEntity> _processSongs(
    List<SongEntity> original,
    String query,
    SortOption sortOption,
    Map<int, int> playCounts,
  ) {
    List<SongEntity> filtered;
    if (query.isEmpty) {
      filtered = List.of(original);
    } else {
      final lowerQuery = query.toLowerCase();
      filtered = original.where((song) {
        return song.title.toLowerCase().contains(lowerQuery) ||
            song.artist.toLowerCase().contains(lowerQuery);
      }).toList();
    }

    switch (sortOption) {
      case SortOption.titleAz:
        filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case SortOption.titleZa:
        filtered.sort(
          (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
        );
        break;
      case SortOption.artistAz:
        filtered.sort(
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
        break;
      case SortOption.dateAdded:
        filtered.sort((a, b) => b.id.compareTo(a.id));
        break;
      case SortOption.duration:
        filtered.sort((a, b) => b.duration.compareTo(a.duration));
        break;
      case SortOption.mostPlayed:
        filtered.sort((a, b) {
          final countA = playCounts[a.id] ?? 0;
          final countB = playCounts[b.id] ?? 0;
          return countB.compareTo(countA);
        });
        break;
    }

    return filtered;
  }
}
