import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/artists/domain/usecases/get_artists.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_analytics_stats.dart';
import 'package:music_player/features/artists/presentation/bloc/artists/artists_event.dart';
import 'package:music_player/features/artists/presentation/bloc/artists/artists_state.dart';

class ArtistsBloc extends Bloc<ArtistsEvent, ArtistsState> {
  final GetArtists getArtists;
  final GetArtistAnalyticsStats getArtistAnalyticsStats;

  ArtistsBloc(this.getArtists, this.getArtistAnalyticsStats)
    : super(const ArtistsState.initial()) {
    on<LoadArtists>((event, emit) async {
      emit(const ArtistsState.loading());
      final result = await getArtists(NoParams());

      await result.fold(
        (failure) async => emit(ArtistsState.error(failure.message)),
        (artists) async {
          // Fetch analytics for each artist to show poetic descriptions in the list
          final updatedArtists = await Future.wait(
            artists.map((artist) async {
              final statsResult = await getArtistAnalyticsStats(artist.name);
              return statsResult.fold(
                (_) => artist,
                (stats) => artist.copyWith(analytics: stats),
              );
            }),
          );
          emit(ArtistsState.loaded(updatedArtists));
        },
      );
    });
  }
}
