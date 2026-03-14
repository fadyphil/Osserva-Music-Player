import 'package:get_it/get_it.dart';
import 'package:music_player/features/artists/data/datasources/artist_local_datasource.dart';
import 'package:music_player/features/artists/data/repositories/artist_repository_impl.dart';
import 'package:music_player/features/artists/domain/repositories/artist_repository.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_analytics_stats.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_songs.dart';
import 'package:music_player/features/artists/domain/usecases/get_artists.dart';
import 'package:music_player/features/artists/presentation/bloc/artist_details/artist_detail_bloc.dart';
import 'package:music_player/features/artists/presentation/bloc/artists/artists_bloc.dart';

void registerArtistsDependencies(GetIt sl) {
  sl.registerLazySingleton<ArtistLocalDataSource>(
    () => ArtistLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ArtistRepository>(() => ArtistRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetArtists(sl()));
  sl.registerLazySingleton(() => GetArtistSongs(sl()));
  sl.registerLazySingleton(() => GetArtistAnalyticsStats(sl()));
  sl.registerFactory(() => ArtistsBloc(sl(), sl()));
  sl.registerFactory(() => ArtistDetailBloc(sl(), sl()));
}
