import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/analytics/domain/usecases/get_all_song_play_counts.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';
import 'package:music_player/features/local_music/domain/usecases/delete_song.dart';
import 'package:music_player/features/local_music/domain/usecases/edit_song_metadata.dart';
import 'package:music_player/features/local_music/domain/usecases/get_local_songs_use_case.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_state.dart';
import 'package:stream_transform/stream_transform.dart'; // Add this package

// Custom Transformer to handle Debounce (Wait 300ms)
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

  LocalMusicBloc(
    this._getLocalSongsUseCase,
    this._getAllSongPlayCountsUseCase,
    this._deleteSongUseCase,
    this._editSongMetadataUseCase,
  ) : super(const LocalMusicState.initial()) {
    // 1. Initial Load
    on<GetLocalSongs>(_onGetLocalSongs);

    // 2. Search (With Debounce Transformer)
    on<SearchSongs>(
      _onSearchSongs,
      transformer: debounce(const Duration(milliseconds: 300)),
    );

    // 3. Sort
    on<SortSongs>(_onSortSongs);

    // 4. Delete
    on<DeleteSongEvent>(_onDeleteSong);

    // 5. Edit
    on<EditSongEvent>(_onEditSong);
  }

  Future<void> _onDeleteSong(
    DeleteSongEvent event,
    Emitter<LocalMusicState> emit,
  ) async {
    final result = await _deleteSongUseCase(event.song);
    result.fold(
      (failure) {
        // Ideally show a snackbar via listener, but here we might emit failure
        // For now, let's just log or emit failure if critical
        emit(LocalMusicState.failure(failure));
      },
      (success) {
        if (success) {
          add(const GetLocalSongs());
        }
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
    result.fold((failure) => emit(LocalMusicState.failure(failure)), (success) {
      if (success) {
        add(const GetLocalSongs());
      }
    });
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

    songsResult.fold((failure) => emit(LocalMusicState.failure(failure)), (
      songs,
    ) {
      final Map<int, int> counts = countsResult.fold(
        (l) => <int, int>{},
        (r) => r,
      );

      // Initial Process using defaults
      final processed = _processSongs(songs, '', SortOption.dateAdded, counts);

      emit(
        LocalMusicState.loaded(
          allSongs: songs,
          processedSongs: processed,
          playCounts: counts,
          searchQuery: '',
          sortOption: SortOption.dateAdded,
        ),
      );
    });
  }

  void _onSearchSongs(SearchSongs event, Emitter<LocalMusicState> emit) {
    state.mapOrNull(
      loaded: (currentState) {
        // 1. Set searching flag (optional, if you want to show spinner while processing)
        emit(currentState.copyWith(isSearching: true));

        // 2. Process logic
        final processed = _processSongs(
          currentState.allSongs,
          event.query,
          currentState.sortOption,
          currentState.playCounts,
        );

        // 3. Emit new data and turn off searching flag
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

  /// Pure Logic Helper: Filters and Sorts the list
  List<SongEntity> _processSongs(
    List<SongEntity> original,
    String query,
    SortOption sortOption,
    Map<int, int> playCounts,
  ) {
    // A. Filter
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

    // B. Sort
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
