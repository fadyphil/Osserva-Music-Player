// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'music_player_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MusicPlayerEvent implements DiagnosticableTreeMixin {




@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MusicPlayerEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent()';
}


}

/// @nodoc
class $MusicPlayerEventCopyWith<$Res>  {
$MusicPlayerEventCopyWith(MusicPlayerEvent _, $Res Function(MusicPlayerEvent) __);
}


/// Adds pattern-matching-related methods to [MusicPlayerEvent].
extension MusicPlayerEventPatterns on MusicPlayerEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _InitMusicQueue value)?  initMusicQueue,TResult Function( _PlaySong value)?  playSong,TResult Function( _PlaySongById value)?  playSongById,TResult Function( _Pause value)?  pause,TResult Function( _Resume value)?  resume,TResult Function( _Seek value)?  seek,TResult Function( _PreviousSong value)?  playPreviousSong,TResult Function( _NextSong value)?  playNextSong,TResult Function( _ToggleShuffle value)?  toggleShuffle,TResult Function( _CycleLoopMode value)?  cycleLoopMode,TResult Function( _UpdatePosition value)?  updatePosition,TResult Function( _UpdateDuration value)?  updateDuration,TResult Function( _UpdatePlayerState value)?  updatePlayerState,TResult Function( _UpdateShuffleState value)?  updateShuffleState,TResult Function( _UpdateLoopState value)?  updateLoopState,TResult Function( _UpdateCurrentSong value)?  updateCurrentSong,TResult Function( _UpdatePlayCounts value)?  updatePlayCounts,TResult Function( _SongFinished value)?  songFinished,TResult Function( _AddToQueue value)?  addToQueue,TResult Function( _RemoveFromQueue value)?  removeFromQueue,TResult Function( _ReorderQueue value)?  reorderQueue,TResult Function( _PlayQueueItem value)?  playQueueItem,TResult Function( _AddToPlaylist value)?  addToPlaylist,TResult Function( _QueueUpdated value)?  queueUpdated,TResult Function( _PlayNext value)?  playNextinQueue,TResult Function( _SetTimer value)?  setTimer,TResult Function( _SetEndTrackTimer value)?  setEndTrackTimer,TResult Function( _CancelTimer value)?  cancelTimer,TResult Function( _TickTimer value)?  tickTimer,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InitMusicQueue() when initMusicQueue != null:
return initMusicQueue(_that);case _PlaySong() when playSong != null:
return playSong(_that);case _PlaySongById() when playSongById != null:
return playSongById(_that);case _Pause() when pause != null:
return pause(_that);case _Resume() when resume != null:
return resume(_that);case _Seek() when seek != null:
return seek(_that);case _PreviousSong() when playPreviousSong != null:
return playPreviousSong(_that);case _NextSong() when playNextSong != null:
return playNextSong(_that);case _ToggleShuffle() when toggleShuffle != null:
return toggleShuffle(_that);case _CycleLoopMode() when cycleLoopMode != null:
return cycleLoopMode(_that);case _UpdatePosition() when updatePosition != null:
return updatePosition(_that);case _UpdateDuration() when updateDuration != null:
return updateDuration(_that);case _UpdatePlayerState() when updatePlayerState != null:
return updatePlayerState(_that);case _UpdateShuffleState() when updateShuffleState != null:
return updateShuffleState(_that);case _UpdateLoopState() when updateLoopState != null:
return updateLoopState(_that);case _UpdateCurrentSong() when updateCurrentSong != null:
return updateCurrentSong(_that);case _UpdatePlayCounts() when updatePlayCounts != null:
return updatePlayCounts(_that);case _SongFinished() when songFinished != null:
return songFinished(_that);case _AddToQueue() when addToQueue != null:
return addToQueue(_that);case _RemoveFromQueue() when removeFromQueue != null:
return removeFromQueue(_that);case _ReorderQueue() when reorderQueue != null:
return reorderQueue(_that);case _PlayQueueItem() when playQueueItem != null:
return playQueueItem(_that);case _AddToPlaylist() when addToPlaylist != null:
return addToPlaylist(_that);case _QueueUpdated() when queueUpdated != null:
return queueUpdated(_that);case _PlayNext() when playNextinQueue != null:
return playNextinQueue(_that);case _SetTimer() when setTimer != null:
return setTimer(_that);case _SetEndTrackTimer() when setEndTrackTimer != null:
return setEndTrackTimer(_that);case _CancelTimer() when cancelTimer != null:
return cancelTimer(_that);case _TickTimer() when tickTimer != null:
return tickTimer(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _InitMusicQueue value)  initMusicQueue,required TResult Function( _PlaySong value)  playSong,required TResult Function( _PlaySongById value)  playSongById,required TResult Function( _Pause value)  pause,required TResult Function( _Resume value)  resume,required TResult Function( _Seek value)  seek,required TResult Function( _PreviousSong value)  playPreviousSong,required TResult Function( _NextSong value)  playNextSong,required TResult Function( _ToggleShuffle value)  toggleShuffle,required TResult Function( _CycleLoopMode value)  cycleLoopMode,required TResult Function( _UpdatePosition value)  updatePosition,required TResult Function( _UpdateDuration value)  updateDuration,required TResult Function( _UpdatePlayerState value)  updatePlayerState,required TResult Function( _UpdateShuffleState value)  updateShuffleState,required TResult Function( _UpdateLoopState value)  updateLoopState,required TResult Function( _UpdateCurrentSong value)  updateCurrentSong,required TResult Function( _UpdatePlayCounts value)  updatePlayCounts,required TResult Function( _SongFinished value)  songFinished,required TResult Function( _AddToQueue value)  addToQueue,required TResult Function( _RemoveFromQueue value)  removeFromQueue,required TResult Function( _ReorderQueue value)  reorderQueue,required TResult Function( _PlayQueueItem value)  playQueueItem,required TResult Function( _AddToPlaylist value)  addToPlaylist,required TResult Function( _QueueUpdated value)  queueUpdated,required TResult Function( _PlayNext value)  playNextinQueue,required TResult Function( _SetTimer value)  setTimer,required TResult Function( _SetEndTrackTimer value)  setEndTrackTimer,required TResult Function( _CancelTimer value)  cancelTimer,required TResult Function( _TickTimer value)  tickTimer,}){
final _that = this;
switch (_that) {
case _InitMusicQueue():
return initMusicQueue(_that);case _PlaySong():
return playSong(_that);case _PlaySongById():
return playSongById(_that);case _Pause():
return pause(_that);case _Resume():
return resume(_that);case _Seek():
return seek(_that);case _PreviousSong():
return playPreviousSong(_that);case _NextSong():
return playNextSong(_that);case _ToggleShuffle():
return toggleShuffle(_that);case _CycleLoopMode():
return cycleLoopMode(_that);case _UpdatePosition():
return updatePosition(_that);case _UpdateDuration():
return updateDuration(_that);case _UpdatePlayerState():
return updatePlayerState(_that);case _UpdateShuffleState():
return updateShuffleState(_that);case _UpdateLoopState():
return updateLoopState(_that);case _UpdateCurrentSong():
return updateCurrentSong(_that);case _UpdatePlayCounts():
return updatePlayCounts(_that);case _SongFinished():
return songFinished(_that);case _AddToQueue():
return addToQueue(_that);case _RemoveFromQueue():
return removeFromQueue(_that);case _ReorderQueue():
return reorderQueue(_that);case _PlayQueueItem():
return playQueueItem(_that);case _AddToPlaylist():
return addToPlaylist(_that);case _QueueUpdated():
return queueUpdated(_that);case _PlayNext():
return playNextinQueue(_that);case _SetTimer():
return setTimer(_that);case _SetEndTrackTimer():
return setEndTrackTimer(_that);case _CancelTimer():
return cancelTimer(_that);case _TickTimer():
return tickTimer(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _InitMusicQueue value)?  initMusicQueue,TResult? Function( _PlaySong value)?  playSong,TResult? Function( _PlaySongById value)?  playSongById,TResult? Function( _Pause value)?  pause,TResult? Function( _Resume value)?  resume,TResult? Function( _Seek value)?  seek,TResult? Function( _PreviousSong value)?  playPreviousSong,TResult? Function( _NextSong value)?  playNextSong,TResult? Function( _ToggleShuffle value)?  toggleShuffle,TResult? Function( _CycleLoopMode value)?  cycleLoopMode,TResult? Function( _UpdatePosition value)?  updatePosition,TResult? Function( _UpdateDuration value)?  updateDuration,TResult? Function( _UpdatePlayerState value)?  updatePlayerState,TResult? Function( _UpdateShuffleState value)?  updateShuffleState,TResult? Function( _UpdateLoopState value)?  updateLoopState,TResult? Function( _UpdateCurrentSong value)?  updateCurrentSong,TResult? Function( _UpdatePlayCounts value)?  updatePlayCounts,TResult? Function( _SongFinished value)?  songFinished,TResult? Function( _AddToQueue value)?  addToQueue,TResult? Function( _RemoveFromQueue value)?  removeFromQueue,TResult? Function( _ReorderQueue value)?  reorderQueue,TResult? Function( _PlayQueueItem value)?  playQueueItem,TResult? Function( _AddToPlaylist value)?  addToPlaylist,TResult? Function( _QueueUpdated value)?  queueUpdated,TResult? Function( _PlayNext value)?  playNextinQueue,TResult? Function( _SetTimer value)?  setTimer,TResult? Function( _SetEndTrackTimer value)?  setEndTrackTimer,TResult? Function( _CancelTimer value)?  cancelTimer,TResult? Function( _TickTimer value)?  tickTimer,}){
final _that = this;
switch (_that) {
case _InitMusicQueue() when initMusicQueue != null:
return initMusicQueue(_that);case _PlaySong() when playSong != null:
return playSong(_that);case _PlaySongById() when playSongById != null:
return playSongById(_that);case _Pause() when pause != null:
return pause(_that);case _Resume() when resume != null:
return resume(_that);case _Seek() when seek != null:
return seek(_that);case _PreviousSong() when playPreviousSong != null:
return playPreviousSong(_that);case _NextSong() when playNextSong != null:
return playNextSong(_that);case _ToggleShuffle() when toggleShuffle != null:
return toggleShuffle(_that);case _CycleLoopMode() when cycleLoopMode != null:
return cycleLoopMode(_that);case _UpdatePosition() when updatePosition != null:
return updatePosition(_that);case _UpdateDuration() when updateDuration != null:
return updateDuration(_that);case _UpdatePlayerState() when updatePlayerState != null:
return updatePlayerState(_that);case _UpdateShuffleState() when updateShuffleState != null:
return updateShuffleState(_that);case _UpdateLoopState() when updateLoopState != null:
return updateLoopState(_that);case _UpdateCurrentSong() when updateCurrentSong != null:
return updateCurrentSong(_that);case _UpdatePlayCounts() when updatePlayCounts != null:
return updatePlayCounts(_that);case _SongFinished() when songFinished != null:
return songFinished(_that);case _AddToQueue() when addToQueue != null:
return addToQueue(_that);case _RemoveFromQueue() when removeFromQueue != null:
return removeFromQueue(_that);case _ReorderQueue() when reorderQueue != null:
return reorderQueue(_that);case _PlayQueueItem() when playQueueItem != null:
return playQueueItem(_that);case _AddToPlaylist() when addToPlaylist != null:
return addToPlaylist(_that);case _QueueUpdated() when queueUpdated != null:
return queueUpdated(_that);case _PlayNext() when playNextinQueue != null:
return playNextinQueue(_that);case _SetTimer() when setTimer != null:
return setTimer(_that);case _SetEndTrackTimer() when setEndTrackTimer != null:
return setEndTrackTimer(_that);case _CancelTimer() when cancelTimer != null:
return cancelTimer(_that);case _TickTimer() when tickTimer != null:
return tickTimer(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<SongEntity> songs,  int currentIndex)?  initMusicQueue,TResult Function( SongEntity song)?  playSong,TResult Function( int songId)?  playSongById,TResult Function()?  pause,TResult Function()?  resume,TResult Function( Duration position)?  seek,TResult Function()?  playPreviousSong,TResult Function()?  playNextSong,TResult Function()?  toggleShuffle,TResult Function()?  cycleLoopMode,TResult Function( Duration position)?  updatePosition,TResult Function( Duration duration)?  updateDuration,TResult Function( bool isPlaying)?  updatePlayerState,TResult Function( bool isShuffleModeEnabled)?  updateShuffleState,TResult Function( int loopMode)?  updateLoopState,TResult Function( SongEntity song)?  updateCurrentSong,TResult Function( Map<int, int> playCounts)?  updatePlayCounts,TResult Function()?  songFinished,TResult Function( SongEntity song)?  addToQueue,TResult Function( int index)?  removeFromQueue,TResult Function( int oldIndex,  int newIndex)?  reorderQueue,TResult Function( int index)?  playQueueItem,TResult Function( SongEntity song)?  addToPlaylist,TResult Function( List<SongEntity> queue)?  queueUpdated,TResult Function( SongEntity song)?  playNextinQueue,TResult Function( Duration duration)?  setTimer,TResult Function( bool active)?  setEndTrackTimer,TResult Function()?  cancelTimer,TResult Function()?  tickTimer,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InitMusicQueue() when initMusicQueue != null:
return initMusicQueue(_that.songs,_that.currentIndex);case _PlaySong() when playSong != null:
return playSong(_that.song);case _PlaySongById() when playSongById != null:
return playSongById(_that.songId);case _Pause() when pause != null:
return pause();case _Resume() when resume != null:
return resume();case _Seek() when seek != null:
return seek(_that.position);case _PreviousSong() when playPreviousSong != null:
return playPreviousSong();case _NextSong() when playNextSong != null:
return playNextSong();case _ToggleShuffle() when toggleShuffle != null:
return toggleShuffle();case _CycleLoopMode() when cycleLoopMode != null:
return cycleLoopMode();case _UpdatePosition() when updatePosition != null:
return updatePosition(_that.position);case _UpdateDuration() when updateDuration != null:
return updateDuration(_that.duration);case _UpdatePlayerState() when updatePlayerState != null:
return updatePlayerState(_that.isPlaying);case _UpdateShuffleState() when updateShuffleState != null:
return updateShuffleState(_that.isShuffleModeEnabled);case _UpdateLoopState() when updateLoopState != null:
return updateLoopState(_that.loopMode);case _UpdateCurrentSong() when updateCurrentSong != null:
return updateCurrentSong(_that.song);case _UpdatePlayCounts() when updatePlayCounts != null:
return updatePlayCounts(_that.playCounts);case _SongFinished() when songFinished != null:
return songFinished();case _AddToQueue() when addToQueue != null:
return addToQueue(_that.song);case _RemoveFromQueue() when removeFromQueue != null:
return removeFromQueue(_that.index);case _ReorderQueue() when reorderQueue != null:
return reorderQueue(_that.oldIndex,_that.newIndex);case _PlayQueueItem() when playQueueItem != null:
return playQueueItem(_that.index);case _AddToPlaylist() when addToPlaylist != null:
return addToPlaylist(_that.song);case _QueueUpdated() when queueUpdated != null:
return queueUpdated(_that.queue);case _PlayNext() when playNextinQueue != null:
return playNextinQueue(_that.song);case _SetTimer() when setTimer != null:
return setTimer(_that.duration);case _SetEndTrackTimer() when setEndTrackTimer != null:
return setEndTrackTimer(_that.active);case _CancelTimer() when cancelTimer != null:
return cancelTimer();case _TickTimer() when tickTimer != null:
return tickTimer();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<SongEntity> songs,  int currentIndex)  initMusicQueue,required TResult Function( SongEntity song)  playSong,required TResult Function( int songId)  playSongById,required TResult Function()  pause,required TResult Function()  resume,required TResult Function( Duration position)  seek,required TResult Function()  playPreviousSong,required TResult Function()  playNextSong,required TResult Function()  toggleShuffle,required TResult Function()  cycleLoopMode,required TResult Function( Duration position)  updatePosition,required TResult Function( Duration duration)  updateDuration,required TResult Function( bool isPlaying)  updatePlayerState,required TResult Function( bool isShuffleModeEnabled)  updateShuffleState,required TResult Function( int loopMode)  updateLoopState,required TResult Function( SongEntity song)  updateCurrentSong,required TResult Function( Map<int, int> playCounts)  updatePlayCounts,required TResult Function()  songFinished,required TResult Function( SongEntity song)  addToQueue,required TResult Function( int index)  removeFromQueue,required TResult Function( int oldIndex,  int newIndex)  reorderQueue,required TResult Function( int index)  playQueueItem,required TResult Function( SongEntity song)  addToPlaylist,required TResult Function( List<SongEntity> queue)  queueUpdated,required TResult Function( SongEntity song)  playNextinQueue,required TResult Function( Duration duration)  setTimer,required TResult Function( bool active)  setEndTrackTimer,required TResult Function()  cancelTimer,required TResult Function()  tickTimer,}) {final _that = this;
switch (_that) {
case _InitMusicQueue():
return initMusicQueue(_that.songs,_that.currentIndex);case _PlaySong():
return playSong(_that.song);case _PlaySongById():
return playSongById(_that.songId);case _Pause():
return pause();case _Resume():
return resume();case _Seek():
return seek(_that.position);case _PreviousSong():
return playPreviousSong();case _NextSong():
return playNextSong();case _ToggleShuffle():
return toggleShuffle();case _CycleLoopMode():
return cycleLoopMode();case _UpdatePosition():
return updatePosition(_that.position);case _UpdateDuration():
return updateDuration(_that.duration);case _UpdatePlayerState():
return updatePlayerState(_that.isPlaying);case _UpdateShuffleState():
return updateShuffleState(_that.isShuffleModeEnabled);case _UpdateLoopState():
return updateLoopState(_that.loopMode);case _UpdateCurrentSong():
return updateCurrentSong(_that.song);case _UpdatePlayCounts():
return updatePlayCounts(_that.playCounts);case _SongFinished():
return songFinished();case _AddToQueue():
return addToQueue(_that.song);case _RemoveFromQueue():
return removeFromQueue(_that.index);case _ReorderQueue():
return reorderQueue(_that.oldIndex,_that.newIndex);case _PlayQueueItem():
return playQueueItem(_that.index);case _AddToPlaylist():
return addToPlaylist(_that.song);case _QueueUpdated():
return queueUpdated(_that.queue);case _PlayNext():
return playNextinQueue(_that.song);case _SetTimer():
return setTimer(_that.duration);case _SetEndTrackTimer():
return setEndTrackTimer(_that.active);case _CancelTimer():
return cancelTimer();case _TickTimer():
return tickTimer();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<SongEntity> songs,  int currentIndex)?  initMusicQueue,TResult? Function( SongEntity song)?  playSong,TResult? Function( int songId)?  playSongById,TResult? Function()?  pause,TResult? Function()?  resume,TResult? Function( Duration position)?  seek,TResult? Function()?  playPreviousSong,TResult? Function()?  playNextSong,TResult? Function()?  toggleShuffle,TResult? Function()?  cycleLoopMode,TResult? Function( Duration position)?  updatePosition,TResult? Function( Duration duration)?  updateDuration,TResult? Function( bool isPlaying)?  updatePlayerState,TResult? Function( bool isShuffleModeEnabled)?  updateShuffleState,TResult? Function( int loopMode)?  updateLoopState,TResult? Function( SongEntity song)?  updateCurrentSong,TResult? Function( Map<int, int> playCounts)?  updatePlayCounts,TResult? Function()?  songFinished,TResult? Function( SongEntity song)?  addToQueue,TResult? Function( int index)?  removeFromQueue,TResult? Function( int oldIndex,  int newIndex)?  reorderQueue,TResult? Function( int index)?  playQueueItem,TResult? Function( SongEntity song)?  addToPlaylist,TResult? Function( List<SongEntity> queue)?  queueUpdated,TResult? Function( SongEntity song)?  playNextinQueue,TResult? Function( Duration duration)?  setTimer,TResult? Function( bool active)?  setEndTrackTimer,TResult? Function()?  cancelTimer,TResult? Function()?  tickTimer,}) {final _that = this;
switch (_that) {
case _InitMusicQueue() when initMusicQueue != null:
return initMusicQueue(_that.songs,_that.currentIndex);case _PlaySong() when playSong != null:
return playSong(_that.song);case _PlaySongById() when playSongById != null:
return playSongById(_that.songId);case _Pause() when pause != null:
return pause();case _Resume() when resume != null:
return resume();case _Seek() when seek != null:
return seek(_that.position);case _PreviousSong() when playPreviousSong != null:
return playPreviousSong();case _NextSong() when playNextSong != null:
return playNextSong();case _ToggleShuffle() when toggleShuffle != null:
return toggleShuffle();case _CycleLoopMode() when cycleLoopMode != null:
return cycleLoopMode();case _UpdatePosition() when updatePosition != null:
return updatePosition(_that.position);case _UpdateDuration() when updateDuration != null:
return updateDuration(_that.duration);case _UpdatePlayerState() when updatePlayerState != null:
return updatePlayerState(_that.isPlaying);case _UpdateShuffleState() when updateShuffleState != null:
return updateShuffleState(_that.isShuffleModeEnabled);case _UpdateLoopState() when updateLoopState != null:
return updateLoopState(_that.loopMode);case _UpdateCurrentSong() when updateCurrentSong != null:
return updateCurrentSong(_that.song);case _UpdatePlayCounts() when updatePlayCounts != null:
return updatePlayCounts(_that.playCounts);case _SongFinished() when songFinished != null:
return songFinished();case _AddToQueue() when addToQueue != null:
return addToQueue(_that.song);case _RemoveFromQueue() when removeFromQueue != null:
return removeFromQueue(_that.index);case _ReorderQueue() when reorderQueue != null:
return reorderQueue(_that.oldIndex,_that.newIndex);case _PlayQueueItem() when playQueueItem != null:
return playQueueItem(_that.index);case _AddToPlaylist() when addToPlaylist != null:
return addToPlaylist(_that.song);case _QueueUpdated() when queueUpdated != null:
return queueUpdated(_that.queue);case _PlayNext() when playNextinQueue != null:
return playNextinQueue(_that.song);case _SetTimer() when setTimer != null:
return setTimer(_that.duration);case _SetEndTrackTimer() when setEndTrackTimer != null:
return setEndTrackTimer(_that.active);case _CancelTimer() when cancelTimer != null:
return cancelTimer();case _TickTimer() when tickTimer != null:
return tickTimer();case _:
  return null;

}
}

}

/// @nodoc


class _InitMusicQueue with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _InitMusicQueue({required final  List<SongEntity> songs, required this.currentIndex}): _songs = songs;
  

 final  List<SongEntity> _songs;
 List<SongEntity> get songs {
  if (_songs is EqualUnmodifiableListView) return _songs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_songs);
}

 final  int currentIndex;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InitMusicQueueCopyWith<_InitMusicQueue> get copyWith => __$InitMusicQueueCopyWithImpl<_InitMusicQueue>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.initMusicQueue'))
    ..add(DiagnosticsProperty('songs', songs))..add(DiagnosticsProperty('currentIndex', currentIndex));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InitMusicQueue&&const DeepCollectionEquality().equals(other._songs, _songs)&&(identical(other.currentIndex, currentIndex) || other.currentIndex == currentIndex));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_songs),currentIndex);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.initMusicQueue(songs: $songs, currentIndex: $currentIndex)';
}


}

/// @nodoc
abstract mixin class _$InitMusicQueueCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$InitMusicQueueCopyWith(_InitMusicQueue value, $Res Function(_InitMusicQueue) _then) = __$InitMusicQueueCopyWithImpl;
@useResult
$Res call({
 List<SongEntity> songs, int currentIndex
});




}
/// @nodoc
class __$InitMusicQueueCopyWithImpl<$Res>
    implements _$InitMusicQueueCopyWith<$Res> {
  __$InitMusicQueueCopyWithImpl(this._self, this._then);

  final _InitMusicQueue _self;
  final $Res Function(_InitMusicQueue) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? songs = null,Object? currentIndex = null,}) {
  return _then(_InitMusicQueue(
songs: null == songs ? _self._songs : songs // ignore: cast_nullable_to_non_nullable
as List<SongEntity>,currentIndex: null == currentIndex ? _self.currentIndex : currentIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _PlaySong with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _PlaySong({required this.song});
  

 final  SongEntity song;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaySongCopyWith<_PlaySong> get copyWith => __$PlaySongCopyWithImpl<_PlaySong>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.playSong'))
    ..add(DiagnosticsProperty('song', song));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaySong&&(identical(other.song, song) || other.song == song));
}


@override
int get hashCode => Object.hash(runtimeType,song);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.playSong(song: $song)';
}


}

/// @nodoc
abstract mixin class _$PlaySongCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$PlaySongCopyWith(_PlaySong value, $Res Function(_PlaySong) _then) = __$PlaySongCopyWithImpl;
@useResult
$Res call({
 SongEntity song
});


$SongEntityCopyWith<$Res> get song;

}
/// @nodoc
class __$PlaySongCopyWithImpl<$Res>
    implements _$PlaySongCopyWith<$Res> {
  __$PlaySongCopyWithImpl(this._self, this._then);

  final _PlaySong _self;
  final $Res Function(_PlaySong) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? song = null,}) {
  return _then(_PlaySong(
song: null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as SongEntity,
  ));
}

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongEntityCopyWith<$Res> get song {
  
  return $SongEntityCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}

/// @nodoc


class _PlaySongById with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _PlaySongById({required this.songId});
  

 final  int songId;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaySongByIdCopyWith<_PlaySongById> get copyWith => __$PlaySongByIdCopyWithImpl<_PlaySongById>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.playSongById'))
    ..add(DiagnosticsProperty('songId', songId));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaySongById&&(identical(other.songId, songId) || other.songId == songId));
}


@override
int get hashCode => Object.hash(runtimeType,songId);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.playSongById(songId: $songId)';
}


}

/// @nodoc
abstract mixin class _$PlaySongByIdCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$PlaySongByIdCopyWith(_PlaySongById value, $Res Function(_PlaySongById) _then) = __$PlaySongByIdCopyWithImpl;
@useResult
$Res call({
 int songId
});




}
/// @nodoc
class __$PlaySongByIdCopyWithImpl<$Res>
    implements _$PlaySongByIdCopyWith<$Res> {
  __$PlaySongByIdCopyWithImpl(this._self, this._then);

  final _PlaySongById _self;
  final $Res Function(_PlaySongById) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? songId = null,}) {
  return _then(_PlaySongById(
songId: null == songId ? _self.songId : songId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Pause with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _Pause();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.pause'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Pause);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.pause()';
}


}




/// @nodoc


class _Resume with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _Resume();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.resume'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Resume);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.resume()';
}


}




/// @nodoc


class _Seek with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _Seek(this.position);
  

 final  Duration position;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SeekCopyWith<_Seek> get copyWith => __$SeekCopyWithImpl<_Seek>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.seek'))
    ..add(DiagnosticsProperty('position', position));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Seek&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,position);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.seek(position: $position)';
}


}

/// @nodoc
abstract mixin class _$SeekCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$SeekCopyWith(_Seek value, $Res Function(_Seek) _then) = __$SeekCopyWithImpl;
@useResult
$Res call({
 Duration position
});




}
/// @nodoc
class __$SeekCopyWithImpl<$Res>
    implements _$SeekCopyWith<$Res> {
  __$SeekCopyWithImpl(this._self, this._then);

  final _Seek _self;
  final $Res Function(_Seek) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,}) {
  return _then(_Seek(
null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class _PreviousSong with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _PreviousSong();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.playPreviousSong'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreviousSong);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.playPreviousSong()';
}


}




/// @nodoc


class _NextSong with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _NextSong();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.playNextSong'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NextSong);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.playNextSong()';
}


}




/// @nodoc


class _ToggleShuffle with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _ToggleShuffle();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.toggleShuffle'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ToggleShuffle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.toggleShuffle()';
}


}




/// @nodoc


class _CycleLoopMode with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _CycleLoopMode();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.cycleLoopMode'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CycleLoopMode);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.cycleLoopMode()';
}


}




/// @nodoc


class _UpdatePosition with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _UpdatePosition(this.position);
  

 final  Duration position;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePositionCopyWith<_UpdatePosition> get copyWith => __$UpdatePositionCopyWithImpl<_UpdatePosition>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.updatePosition'))
    ..add(DiagnosticsProperty('position', position));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePosition&&(identical(other.position, position) || other.position == position));
}


@override
int get hashCode => Object.hash(runtimeType,position);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.updatePosition(position: $position)';
}


}

/// @nodoc
abstract mixin class _$UpdatePositionCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$UpdatePositionCopyWith(_UpdatePosition value, $Res Function(_UpdatePosition) _then) = __$UpdatePositionCopyWithImpl;
@useResult
$Res call({
 Duration position
});




}
/// @nodoc
class __$UpdatePositionCopyWithImpl<$Res>
    implements _$UpdatePositionCopyWith<$Res> {
  __$UpdatePositionCopyWithImpl(this._self, this._then);

  final _UpdatePosition _self;
  final $Res Function(_UpdatePosition) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? position = null,}) {
  return _then(_UpdatePosition(
null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class _UpdateDuration with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _UpdateDuration(this.duration);
  

 final  Duration duration;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateDurationCopyWith<_UpdateDuration> get copyWith => __$UpdateDurationCopyWithImpl<_UpdateDuration>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.updateDuration'))
    ..add(DiagnosticsProperty('duration', duration));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateDuration&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode => Object.hash(runtimeType,duration);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.updateDuration(duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$UpdateDurationCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$UpdateDurationCopyWith(_UpdateDuration value, $Res Function(_UpdateDuration) _then) = __$UpdateDurationCopyWithImpl;
@useResult
$Res call({
 Duration duration
});




}
/// @nodoc
class __$UpdateDurationCopyWithImpl<$Res>
    implements _$UpdateDurationCopyWith<$Res> {
  __$UpdateDurationCopyWithImpl(this._self, this._then);

  final _UpdateDuration _self;
  final $Res Function(_UpdateDuration) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? duration = null,}) {
  return _then(_UpdateDuration(
null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class _UpdatePlayerState with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _UpdatePlayerState(this.isPlaying);
  

 final  bool isPlaying;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePlayerStateCopyWith<_UpdatePlayerState> get copyWith => __$UpdatePlayerStateCopyWithImpl<_UpdatePlayerState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.updatePlayerState'))
    ..add(DiagnosticsProperty('isPlaying', isPlaying));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePlayerState&&(identical(other.isPlaying, isPlaying) || other.isPlaying == isPlaying));
}


@override
int get hashCode => Object.hash(runtimeType,isPlaying);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.updatePlayerState(isPlaying: $isPlaying)';
}


}

/// @nodoc
abstract mixin class _$UpdatePlayerStateCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$UpdatePlayerStateCopyWith(_UpdatePlayerState value, $Res Function(_UpdatePlayerState) _then) = __$UpdatePlayerStateCopyWithImpl;
@useResult
$Res call({
 bool isPlaying
});




}
/// @nodoc
class __$UpdatePlayerStateCopyWithImpl<$Res>
    implements _$UpdatePlayerStateCopyWith<$Res> {
  __$UpdatePlayerStateCopyWithImpl(this._self, this._then);

  final _UpdatePlayerState _self;
  final $Res Function(_UpdatePlayerState) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isPlaying = null,}) {
  return _then(_UpdatePlayerState(
null == isPlaying ? _self.isPlaying : isPlaying // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _UpdateShuffleState with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _UpdateShuffleState(this.isShuffleModeEnabled);
  

 final  bool isShuffleModeEnabled;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateShuffleStateCopyWith<_UpdateShuffleState> get copyWith => __$UpdateShuffleStateCopyWithImpl<_UpdateShuffleState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.updateShuffleState'))
    ..add(DiagnosticsProperty('isShuffleModeEnabled', isShuffleModeEnabled));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateShuffleState&&(identical(other.isShuffleModeEnabled, isShuffleModeEnabled) || other.isShuffleModeEnabled == isShuffleModeEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,isShuffleModeEnabled);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.updateShuffleState(isShuffleModeEnabled: $isShuffleModeEnabled)';
}


}

/// @nodoc
abstract mixin class _$UpdateShuffleStateCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$UpdateShuffleStateCopyWith(_UpdateShuffleState value, $Res Function(_UpdateShuffleState) _then) = __$UpdateShuffleStateCopyWithImpl;
@useResult
$Res call({
 bool isShuffleModeEnabled
});




}
/// @nodoc
class __$UpdateShuffleStateCopyWithImpl<$Res>
    implements _$UpdateShuffleStateCopyWith<$Res> {
  __$UpdateShuffleStateCopyWithImpl(this._self, this._then);

  final _UpdateShuffleState _self;
  final $Res Function(_UpdateShuffleState) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? isShuffleModeEnabled = null,}) {
  return _then(_UpdateShuffleState(
null == isShuffleModeEnabled ? _self.isShuffleModeEnabled : isShuffleModeEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _UpdateLoopState with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _UpdateLoopState(this.loopMode);
  

 final  int loopMode;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateLoopStateCopyWith<_UpdateLoopState> get copyWith => __$UpdateLoopStateCopyWithImpl<_UpdateLoopState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.updateLoopState'))
    ..add(DiagnosticsProperty('loopMode', loopMode));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateLoopState&&(identical(other.loopMode, loopMode) || other.loopMode == loopMode));
}


@override
int get hashCode => Object.hash(runtimeType,loopMode);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.updateLoopState(loopMode: $loopMode)';
}


}

/// @nodoc
abstract mixin class _$UpdateLoopStateCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$UpdateLoopStateCopyWith(_UpdateLoopState value, $Res Function(_UpdateLoopState) _then) = __$UpdateLoopStateCopyWithImpl;
@useResult
$Res call({
 int loopMode
});




}
/// @nodoc
class __$UpdateLoopStateCopyWithImpl<$Res>
    implements _$UpdateLoopStateCopyWith<$Res> {
  __$UpdateLoopStateCopyWithImpl(this._self, this._then);

  final _UpdateLoopState _self;
  final $Res Function(_UpdateLoopState) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? loopMode = null,}) {
  return _then(_UpdateLoopState(
null == loopMode ? _self.loopMode : loopMode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _UpdateCurrentSong with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _UpdateCurrentSong(this.song);
  

 final  SongEntity song;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateCurrentSongCopyWith<_UpdateCurrentSong> get copyWith => __$UpdateCurrentSongCopyWithImpl<_UpdateCurrentSong>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.updateCurrentSong'))
    ..add(DiagnosticsProperty('song', song));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateCurrentSong&&(identical(other.song, song) || other.song == song));
}


@override
int get hashCode => Object.hash(runtimeType,song);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.updateCurrentSong(song: $song)';
}


}

/// @nodoc
abstract mixin class _$UpdateCurrentSongCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$UpdateCurrentSongCopyWith(_UpdateCurrentSong value, $Res Function(_UpdateCurrentSong) _then) = __$UpdateCurrentSongCopyWithImpl;
@useResult
$Res call({
 SongEntity song
});


$SongEntityCopyWith<$Res> get song;

}
/// @nodoc
class __$UpdateCurrentSongCopyWithImpl<$Res>
    implements _$UpdateCurrentSongCopyWith<$Res> {
  __$UpdateCurrentSongCopyWithImpl(this._self, this._then);

  final _UpdateCurrentSong _self;
  final $Res Function(_UpdateCurrentSong) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? song = null,}) {
  return _then(_UpdateCurrentSong(
null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as SongEntity,
  ));
}

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongEntityCopyWith<$Res> get song {
  
  return $SongEntityCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}

/// @nodoc


class _UpdatePlayCounts with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _UpdatePlayCounts(final  Map<int, int> playCounts): _playCounts = playCounts;
  

 final  Map<int, int> _playCounts;
 Map<int, int> get playCounts {
  if (_playCounts is EqualUnmodifiableMapView) return _playCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_playCounts);
}


/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdatePlayCountsCopyWith<_UpdatePlayCounts> get copyWith => __$UpdatePlayCountsCopyWithImpl<_UpdatePlayCounts>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.updatePlayCounts'))
    ..add(DiagnosticsProperty('playCounts', playCounts));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdatePlayCounts&&const DeepCollectionEquality().equals(other._playCounts, _playCounts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_playCounts));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.updatePlayCounts(playCounts: $playCounts)';
}


}

/// @nodoc
abstract mixin class _$UpdatePlayCountsCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$UpdatePlayCountsCopyWith(_UpdatePlayCounts value, $Res Function(_UpdatePlayCounts) _then) = __$UpdatePlayCountsCopyWithImpl;
@useResult
$Res call({
 Map<int, int> playCounts
});




}
/// @nodoc
class __$UpdatePlayCountsCopyWithImpl<$Res>
    implements _$UpdatePlayCountsCopyWith<$Res> {
  __$UpdatePlayCountsCopyWithImpl(this._self, this._then);

  final _UpdatePlayCounts _self;
  final $Res Function(_UpdatePlayCounts) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? playCounts = null,}) {
  return _then(_UpdatePlayCounts(
null == playCounts ? _self._playCounts : playCounts // ignore: cast_nullable_to_non_nullable
as Map<int, int>,
  ));
}


}

/// @nodoc


class _SongFinished with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _SongFinished();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.songFinished'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SongFinished);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.songFinished()';
}


}




/// @nodoc


class _AddToQueue with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _AddToQueue(this.song);
  

 final  SongEntity song;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddToQueueCopyWith<_AddToQueue> get copyWith => __$AddToQueueCopyWithImpl<_AddToQueue>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.addToQueue'))
    ..add(DiagnosticsProperty('song', song));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddToQueue&&(identical(other.song, song) || other.song == song));
}


@override
int get hashCode => Object.hash(runtimeType,song);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.addToQueue(song: $song)';
}


}

/// @nodoc
abstract mixin class _$AddToQueueCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$AddToQueueCopyWith(_AddToQueue value, $Res Function(_AddToQueue) _then) = __$AddToQueueCopyWithImpl;
@useResult
$Res call({
 SongEntity song
});


$SongEntityCopyWith<$Res> get song;

}
/// @nodoc
class __$AddToQueueCopyWithImpl<$Res>
    implements _$AddToQueueCopyWith<$Res> {
  __$AddToQueueCopyWithImpl(this._self, this._then);

  final _AddToQueue _self;
  final $Res Function(_AddToQueue) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? song = null,}) {
  return _then(_AddToQueue(
null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as SongEntity,
  ));
}

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongEntityCopyWith<$Res> get song {
  
  return $SongEntityCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}

/// @nodoc


class _RemoveFromQueue with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _RemoveFromQueue(this.index);
  

 final  int index;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoveFromQueueCopyWith<_RemoveFromQueue> get copyWith => __$RemoveFromQueueCopyWithImpl<_RemoveFromQueue>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.removeFromQueue'))
    ..add(DiagnosticsProperty('index', index));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoveFromQueue&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,index);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.removeFromQueue(index: $index)';
}


}

/// @nodoc
abstract mixin class _$RemoveFromQueueCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$RemoveFromQueueCopyWith(_RemoveFromQueue value, $Res Function(_RemoveFromQueue) _then) = __$RemoveFromQueueCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class __$RemoveFromQueueCopyWithImpl<$Res>
    implements _$RemoveFromQueueCopyWith<$Res> {
  __$RemoveFromQueueCopyWithImpl(this._self, this._then);

  final _RemoveFromQueue _self;
  final $Res Function(_RemoveFromQueue) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(_RemoveFromQueue(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _ReorderQueue with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _ReorderQueue(this.oldIndex, this.newIndex);
  

 final  int oldIndex;
 final  int newIndex;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReorderQueueCopyWith<_ReorderQueue> get copyWith => __$ReorderQueueCopyWithImpl<_ReorderQueue>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.reorderQueue'))
    ..add(DiagnosticsProperty('oldIndex', oldIndex))..add(DiagnosticsProperty('newIndex', newIndex));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReorderQueue&&(identical(other.oldIndex, oldIndex) || other.oldIndex == oldIndex)&&(identical(other.newIndex, newIndex) || other.newIndex == newIndex));
}


@override
int get hashCode => Object.hash(runtimeType,oldIndex,newIndex);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.reorderQueue(oldIndex: $oldIndex, newIndex: $newIndex)';
}


}

/// @nodoc
abstract mixin class _$ReorderQueueCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$ReorderQueueCopyWith(_ReorderQueue value, $Res Function(_ReorderQueue) _then) = __$ReorderQueueCopyWithImpl;
@useResult
$Res call({
 int oldIndex, int newIndex
});




}
/// @nodoc
class __$ReorderQueueCopyWithImpl<$Res>
    implements _$ReorderQueueCopyWith<$Res> {
  __$ReorderQueueCopyWithImpl(this._self, this._then);

  final _ReorderQueue _self;
  final $Res Function(_ReorderQueue) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? oldIndex = null,Object? newIndex = null,}) {
  return _then(_ReorderQueue(
null == oldIndex ? _self.oldIndex : oldIndex // ignore: cast_nullable_to_non_nullable
as int,null == newIndex ? _self.newIndex : newIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _PlayQueueItem with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _PlayQueueItem(this.index);
  

 final  int index;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayQueueItemCopyWith<_PlayQueueItem> get copyWith => __$PlayQueueItemCopyWithImpl<_PlayQueueItem>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.playQueueItem'))
    ..add(DiagnosticsProperty('index', index));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayQueueItem&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode => Object.hash(runtimeType,index);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.playQueueItem(index: $index)';
}


}

/// @nodoc
abstract mixin class _$PlayQueueItemCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$PlayQueueItemCopyWith(_PlayQueueItem value, $Res Function(_PlayQueueItem) _then) = __$PlayQueueItemCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class __$PlayQueueItemCopyWithImpl<$Res>
    implements _$PlayQueueItemCopyWith<$Res> {
  __$PlayQueueItemCopyWithImpl(this._self, this._then);

  final _PlayQueueItem _self;
  final $Res Function(_PlayQueueItem) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(_PlayQueueItem(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _AddToPlaylist with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _AddToPlaylist(this.song);
  

 final  SongEntity song;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AddToPlaylistCopyWith<_AddToPlaylist> get copyWith => __$AddToPlaylistCopyWithImpl<_AddToPlaylist>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.addToPlaylist'))
    ..add(DiagnosticsProperty('song', song));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AddToPlaylist&&(identical(other.song, song) || other.song == song));
}


@override
int get hashCode => Object.hash(runtimeType,song);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.addToPlaylist(song: $song)';
}


}

/// @nodoc
abstract mixin class _$AddToPlaylistCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$AddToPlaylistCopyWith(_AddToPlaylist value, $Res Function(_AddToPlaylist) _then) = __$AddToPlaylistCopyWithImpl;
@useResult
$Res call({
 SongEntity song
});


$SongEntityCopyWith<$Res> get song;

}
/// @nodoc
class __$AddToPlaylistCopyWithImpl<$Res>
    implements _$AddToPlaylistCopyWith<$Res> {
  __$AddToPlaylistCopyWithImpl(this._self, this._then);

  final _AddToPlaylist _self;
  final $Res Function(_AddToPlaylist) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? song = null,}) {
  return _then(_AddToPlaylist(
null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as SongEntity,
  ));
}

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongEntityCopyWith<$Res> get song {
  
  return $SongEntityCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}

/// @nodoc


class _QueueUpdated with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _QueueUpdated(final  List<SongEntity> queue): _queue = queue;
  

 final  List<SongEntity> _queue;
 List<SongEntity> get queue {
  if (_queue is EqualUnmodifiableListView) return _queue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_queue);
}


/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QueueUpdatedCopyWith<_QueueUpdated> get copyWith => __$QueueUpdatedCopyWithImpl<_QueueUpdated>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.queueUpdated'))
    ..add(DiagnosticsProperty('queue', queue));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QueueUpdated&&const DeepCollectionEquality().equals(other._queue, _queue));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_queue));

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.queueUpdated(queue: $queue)';
}


}

/// @nodoc
abstract mixin class _$QueueUpdatedCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$QueueUpdatedCopyWith(_QueueUpdated value, $Res Function(_QueueUpdated) _then) = __$QueueUpdatedCopyWithImpl;
@useResult
$Res call({
 List<SongEntity> queue
});




}
/// @nodoc
class __$QueueUpdatedCopyWithImpl<$Res>
    implements _$QueueUpdatedCopyWith<$Res> {
  __$QueueUpdatedCopyWithImpl(this._self, this._then);

  final _QueueUpdated _self;
  final $Res Function(_QueueUpdated) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? queue = null,}) {
  return _then(_QueueUpdated(
null == queue ? _self._queue : queue // ignore: cast_nullable_to_non_nullable
as List<SongEntity>,
  ));
}


}

/// @nodoc


class _PlayNext with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _PlayNext(this.song);
  

 final  SongEntity song;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlayNextCopyWith<_PlayNext> get copyWith => __$PlayNextCopyWithImpl<_PlayNext>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.playNextinQueue'))
    ..add(DiagnosticsProperty('song', song));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlayNext&&(identical(other.song, song) || other.song == song));
}


@override
int get hashCode => Object.hash(runtimeType,song);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.playNextinQueue(song: $song)';
}


}

/// @nodoc
abstract mixin class _$PlayNextCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$PlayNextCopyWith(_PlayNext value, $Res Function(_PlayNext) _then) = __$PlayNextCopyWithImpl;
@useResult
$Res call({
 SongEntity song
});


$SongEntityCopyWith<$Res> get song;

}
/// @nodoc
class __$PlayNextCopyWithImpl<$Res>
    implements _$PlayNextCopyWith<$Res> {
  __$PlayNextCopyWithImpl(this._self, this._then);

  final _PlayNext _self;
  final $Res Function(_PlayNext) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? song = null,}) {
  return _then(_PlayNext(
null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as SongEntity,
  ));
}

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongEntityCopyWith<$Res> get song {
  
  return $SongEntityCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}

/// @nodoc


class _SetTimer with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _SetTimer({required this.duration});
  

 final  Duration duration;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetTimerCopyWith<_SetTimer> get copyWith => __$SetTimerCopyWithImpl<_SetTimer>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.setTimer'))
    ..add(DiagnosticsProperty('duration', duration));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetTimer&&(identical(other.duration, duration) || other.duration == duration));
}


@override
int get hashCode => Object.hash(runtimeType,duration);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.setTimer(duration: $duration)';
}


}

/// @nodoc
abstract mixin class _$SetTimerCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$SetTimerCopyWith(_SetTimer value, $Res Function(_SetTimer) _then) = __$SetTimerCopyWithImpl;
@useResult
$Res call({
 Duration duration
});




}
/// @nodoc
class __$SetTimerCopyWithImpl<$Res>
    implements _$SetTimerCopyWith<$Res> {
  __$SetTimerCopyWithImpl(this._self, this._then);

  final _SetTimer _self;
  final $Res Function(_SetTimer) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? duration = null,}) {
  return _then(_SetTimer(
duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class _SetEndTrackTimer with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _SetEndTrackTimer({required this.active});
  

 final  bool active;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SetEndTrackTimerCopyWith<_SetEndTrackTimer> get copyWith => __$SetEndTrackTimerCopyWithImpl<_SetEndTrackTimer>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.setEndTrackTimer'))
    ..add(DiagnosticsProperty('active', active));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SetEndTrackTimer&&(identical(other.active, active) || other.active == active));
}


@override
int get hashCode => Object.hash(runtimeType,active);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.setEndTrackTimer(active: $active)';
}


}

/// @nodoc
abstract mixin class _$SetEndTrackTimerCopyWith<$Res> implements $MusicPlayerEventCopyWith<$Res> {
  factory _$SetEndTrackTimerCopyWith(_SetEndTrackTimer value, $Res Function(_SetEndTrackTimer) _then) = __$SetEndTrackTimerCopyWithImpl;
@useResult
$Res call({
 bool active
});




}
/// @nodoc
class __$SetEndTrackTimerCopyWithImpl<$Res>
    implements _$SetEndTrackTimerCopyWith<$Res> {
  __$SetEndTrackTimerCopyWithImpl(this._self, this._then);

  final _SetEndTrackTimer _self;
  final $Res Function(_SetEndTrackTimer) _then;

/// Create a copy of MusicPlayerEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? active = null,}) {
  return _then(_SetEndTrackTimer(
active: null == active ? _self.active : active // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class _CancelTimer with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _CancelTimer();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.cancelTimer'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CancelTimer);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.cancelTimer()';
}


}




/// @nodoc


class _TickTimer with DiagnosticableTreeMixin implements MusicPlayerEvent {
  const _TickTimer();
  





@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'MusicPlayerEvent.tickTimer'))
    ;
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TickTimer);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'MusicPlayerEvent.tickTimer()';
}


}




// dart format on
