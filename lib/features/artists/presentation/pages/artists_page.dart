import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/core/di/init_dependencies.dart';
import 'package:osserva/features/artists/presentation/bloc/artists/artists_bloc.dart';
import 'package:osserva/features/artists/presentation/bloc/artists/artists_event.dart';
import 'package:osserva/features/artists/presentation/bloc/artists/artists_state.dart';
import 'package:osserva/features/artists/presentation/widgets/artist_card.dart';

@RoutePage()
class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<ArtistsBloc>()..add(const ArtistsEvent.loadArtists()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(' Artists'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: BlocBuilder<ArtistsBloc, ArtistsState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (msg) => Center(child: Text('Error: $msg')),
              loaded: (artists) {
                if (artists.isEmpty) {
                  return const Center(child: Text('No artists found.'));
                }
                return ListView.builder(
                  itemCount: artists.length,
                  itemBuilder: (context, index) {
                    return ArtistCard(artist: artists[index]);
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
