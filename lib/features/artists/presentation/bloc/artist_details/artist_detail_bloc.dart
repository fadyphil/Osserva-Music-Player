import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/features/analytics/domain/entities/artist_stats.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_analytics_stats.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_songs.dart';
import 'package:music_player/features/artists/presentation/bloc/artist_details/artist_detail_event.dart';
import 'package:music_player/features/artists/presentation/bloc/artist_details/artist_detail_state.dart';

class ArtistDetailBloc extends Bloc<ArtistDetailEvent, ArtistDetailState> {
  final GetArtistSongs _getArtistSongs;
  final GetArtistAnalyticsStats _getArtistAnalyticsStats;

  ArtistDetailBloc(this._getArtistSongs, this._getArtistAnalyticsStats)
    : super(const ArtistDetailState.initial()) {
    on<LoadArtistSongs>(_onLoadArtistSongs);
  }

  Future<void> _onLoadArtistSongs(
    LoadArtistSongs event,
    Emitter<ArtistDetailState> emit,
  ) async {
    emit(const ArtistDetailState.loading());

    final (songsResult, statsResult) = await (
      _getArtistSongs(event.artistId),
      _getArtistAnalyticsStats(event.artistName),
    ).wait;

    songsResult.fold(
      (failure) => emit(ArtistDetailState.error(failure.message)),
      (songs) {
        final ArtistStats? stats = statsResult.fold((_) => null, (s) => s);
        emit(ArtistDetailState.loaded(songs, analytics: stats));
      },
    );
  }
}
