import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_songs.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_analytics_stats.dart';
import 'package:music_player/features/artists/presentation/bloc/artist-details/artist_detail_event.dart';
import 'package:music_player/features/artists/presentation/bloc/artist-details/artist_detail_state.dart';

class ArtistDetailBloc extends Bloc<ArtistDetailEvent, ArtistDetailState> {
  final GetArtistSongs getArtistSongs;
  final GetArtistAnalyticsStats getArtistAnalyticsStats;

  ArtistDetailBloc(this.getArtistSongs, this.getArtistAnalyticsStats)
    : super(const ArtistDetailState.initial()) {
    on<LoadArtistSongs>((event, emit) async {
      emit(const ArtistDetailState.loading());

      final results = await Future.wait([
        getArtistSongs(event.artistId),
        getArtistAnalyticsStats(event.artistName),
      ]);

      final songResult = results[0] as Either;
      final statsResult = results[1] as Either;

      songResult.fold(
        (failure) => emit(ArtistDetailState.error(failure.message)),
        (songs) {
          statsResult.fold(
            (failure) => emit(ArtistDetailState.loaded(songs)),
            (stats) => emit(ArtistDetailState.loaded(songs, analytics: stats)),
          );
        },
      );
    });
  }
}
