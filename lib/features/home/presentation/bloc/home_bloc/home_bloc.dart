import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/features/local%20music/domain/repositories/music_repository.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final MusicRepository _musicRepository;

  HomeBloc({required MusicRepository musicRepository})
      : _musicRepository = musicRepository,
        super(const HomeState.initial()) {
    on<_LoadHomeData>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    _LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeState.loading());

    final result = await _musicRepository.getLocalSongs();

    result.fold(
      (failure) => emit(HomeState.failure(failure.message)),
      (songs) {
        final trackCount = songs.length;
        final greeting = _getGreeting();
        emit(HomeState.loaded(
          trackCount: trackCount,
          greeting: greeting,
        ));
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
