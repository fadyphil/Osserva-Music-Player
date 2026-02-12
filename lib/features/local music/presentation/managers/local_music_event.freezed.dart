// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'local_music_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LocalMusicEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalMusicEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocalMusicEvent()';
}


}

/// @nodoc
class $LocalMusicEventCopyWith<$Res>  {
$LocalMusicEventCopyWith(LocalMusicEvent _, $Res Function(LocalMusicEvent) __);
}


/// Adds pattern-matching-related methods to [LocalMusicEvent].
extension LocalMusicEventPatterns on LocalMusicEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetLocalSongs value)?  getLocalSongs,TResult Function( SearchSongs value)?  searchSongs,TResult Function( SortSongs value)?  sortSongs,TResult Function( DeleteSongEvent value)?  deleteSong,TResult Function( EditSongEvent value)?  editSong,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetLocalSongs() when getLocalSongs != null:
return getLocalSongs(_that);case SearchSongs() when searchSongs != null:
return searchSongs(_that);case SortSongs() when sortSongs != null:
return sortSongs(_that);case DeleteSongEvent() when deleteSong != null:
return deleteSong(_that);case EditSongEvent() when editSong != null:
return editSong(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetLocalSongs value)  getLocalSongs,required TResult Function( SearchSongs value)  searchSongs,required TResult Function( SortSongs value)  sortSongs,required TResult Function( DeleteSongEvent value)  deleteSong,required TResult Function( EditSongEvent value)  editSong,}){
final _that = this;
switch (_that) {
case GetLocalSongs():
return getLocalSongs(_that);case SearchSongs():
return searchSongs(_that);case SortSongs():
return sortSongs(_that);case DeleteSongEvent():
return deleteSong(_that);case EditSongEvent():
return editSong(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetLocalSongs value)?  getLocalSongs,TResult? Function( SearchSongs value)?  searchSongs,TResult? Function( SortSongs value)?  sortSongs,TResult? Function( DeleteSongEvent value)?  deleteSong,TResult? Function( EditSongEvent value)?  editSong,}){
final _that = this;
switch (_that) {
case GetLocalSongs() when getLocalSongs != null:
return getLocalSongs(_that);case SearchSongs() when searchSongs != null:
return searchSongs(_that);case SortSongs() when sortSongs != null:
return sortSongs(_that);case DeleteSongEvent() when deleteSong != null:
return deleteSong(_that);case EditSongEvent() when editSong != null:
return editSong(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  getLocalSongs,TResult Function( String query)?  searchSongs,TResult Function( SortOption option)?  sortSongs,TResult Function( SongEntity song)?  deleteSong,TResult Function( SongEntity song,  String? title,  String? artist,  String? album,  String? genre,  String? year,  Uint8List? artworkBytes)?  editSong,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetLocalSongs() when getLocalSongs != null:
return getLocalSongs();case SearchSongs() when searchSongs != null:
return searchSongs(_that.query);case SortSongs() when sortSongs != null:
return sortSongs(_that.option);case DeleteSongEvent() when deleteSong != null:
return deleteSong(_that.song);case EditSongEvent() when editSong != null:
return editSong(_that.song,_that.title,_that.artist,_that.album,_that.genre,_that.year,_that.artworkBytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  getLocalSongs,required TResult Function( String query)  searchSongs,required TResult Function( SortOption option)  sortSongs,required TResult Function( SongEntity song)  deleteSong,required TResult Function( SongEntity song,  String? title,  String? artist,  String? album,  String? genre,  String? year,  Uint8List? artworkBytes)  editSong,}) {final _that = this;
switch (_that) {
case GetLocalSongs():
return getLocalSongs();case SearchSongs():
return searchSongs(_that.query);case SortSongs():
return sortSongs(_that.option);case DeleteSongEvent():
return deleteSong(_that.song);case EditSongEvent():
return editSong(_that.song,_that.title,_that.artist,_that.album,_that.genre,_that.year,_that.artworkBytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  getLocalSongs,TResult? Function( String query)?  searchSongs,TResult? Function( SortOption option)?  sortSongs,TResult? Function( SongEntity song)?  deleteSong,TResult? Function( SongEntity song,  String? title,  String? artist,  String? album,  String? genre,  String? year,  Uint8List? artworkBytes)?  editSong,}) {final _that = this;
switch (_that) {
case GetLocalSongs() when getLocalSongs != null:
return getLocalSongs();case SearchSongs() when searchSongs != null:
return searchSongs(_that.query);case SortSongs() when sortSongs != null:
return sortSongs(_that.option);case DeleteSongEvent() when deleteSong != null:
return deleteSong(_that.song);case EditSongEvent() when editSong != null:
return editSong(_that.song,_that.title,_that.artist,_that.album,_that.genre,_that.year,_that.artworkBytes);case _:
  return null;

}
}

}

/// @nodoc


class GetLocalSongs implements LocalMusicEvent {
  const GetLocalSongs();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GetLocalSongs);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LocalMusicEvent.getLocalSongs()';
}


}




/// @nodoc


class SearchSongs implements LocalMusicEvent {
  const SearchSongs(this.query);
  

 final  String query;

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchSongsCopyWith<SearchSongs> get copyWith => _$SearchSongsCopyWithImpl<SearchSongs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchSongs&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,query);

@override
String toString() {
  return 'LocalMusicEvent.searchSongs(query: $query)';
}


}

/// @nodoc
abstract mixin class $SearchSongsCopyWith<$Res> implements $LocalMusicEventCopyWith<$Res> {
  factory $SearchSongsCopyWith(SearchSongs value, $Res Function(SearchSongs) _then) = _$SearchSongsCopyWithImpl;
@useResult
$Res call({
 String query
});




}
/// @nodoc
class _$SearchSongsCopyWithImpl<$Res>
    implements $SearchSongsCopyWith<$Res> {
  _$SearchSongsCopyWithImpl(this._self, this._then);

  final SearchSongs _self;
  final $Res Function(SearchSongs) _then;

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? query = null,}) {
  return _then(SearchSongs(
null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class SortSongs implements LocalMusicEvent {
  const SortSongs(this.option);
  

 final  SortOption option;

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SortSongsCopyWith<SortSongs> get copyWith => _$SortSongsCopyWithImpl<SortSongs>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SortSongs&&(identical(other.option, option) || other.option == option));
}


@override
int get hashCode => Object.hash(runtimeType,option);

@override
String toString() {
  return 'LocalMusicEvent.sortSongs(option: $option)';
}


}

/// @nodoc
abstract mixin class $SortSongsCopyWith<$Res> implements $LocalMusicEventCopyWith<$Res> {
  factory $SortSongsCopyWith(SortSongs value, $Res Function(SortSongs) _then) = _$SortSongsCopyWithImpl;
@useResult
$Res call({
 SortOption option
});




}
/// @nodoc
class _$SortSongsCopyWithImpl<$Res>
    implements $SortSongsCopyWith<$Res> {
  _$SortSongsCopyWithImpl(this._self, this._then);

  final SortSongs _self;
  final $Res Function(SortSongs) _then;

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? option = null,}) {
  return _then(SortSongs(
null == option ? _self.option : option // ignore: cast_nullable_to_non_nullable
as SortOption,
  ));
}


}

/// @nodoc


class DeleteSongEvent implements LocalMusicEvent {
  const DeleteSongEvent(this.song);
  

 final  SongEntity song;

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteSongEventCopyWith<DeleteSongEvent> get copyWith => _$DeleteSongEventCopyWithImpl<DeleteSongEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteSongEvent&&(identical(other.song, song) || other.song == song));
}


@override
int get hashCode => Object.hash(runtimeType,song);

@override
String toString() {
  return 'LocalMusicEvent.deleteSong(song: $song)';
}


}

/// @nodoc
abstract mixin class $DeleteSongEventCopyWith<$Res> implements $LocalMusicEventCopyWith<$Res> {
  factory $DeleteSongEventCopyWith(DeleteSongEvent value, $Res Function(DeleteSongEvent) _then) = _$DeleteSongEventCopyWithImpl;
@useResult
$Res call({
 SongEntity song
});


$SongEntityCopyWith<$Res> get song;

}
/// @nodoc
class _$DeleteSongEventCopyWithImpl<$Res>
    implements $DeleteSongEventCopyWith<$Res> {
  _$DeleteSongEventCopyWithImpl(this._self, this._then);

  final DeleteSongEvent _self;
  final $Res Function(DeleteSongEvent) _then;

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? song = null,}) {
  return _then(DeleteSongEvent(
null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as SongEntity,
  ));
}

/// Create a copy of LocalMusicEvent
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


class EditSongEvent implements LocalMusicEvent {
  const EditSongEvent({required this.song, this.title, this.artist, this.album, this.genre, this.year, this.artworkBytes});
  

 final  SongEntity song;
 final  String? title;
 final  String? artist;
 final  String? album;
 final  String? genre;
 final  String? year;
 final  Uint8List? artworkBytes;

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditSongEventCopyWith<EditSongEvent> get copyWith => _$EditSongEventCopyWithImpl<EditSongEvent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditSongEvent&&(identical(other.song, song) || other.song == song)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.artworkBytes, artworkBytes));
}


@override
int get hashCode => Object.hash(runtimeType,song,title,artist,album,genre,year,const DeepCollectionEquality().hash(artworkBytes));

@override
String toString() {
  return 'LocalMusicEvent.editSong(song: $song, title: $title, artist: $artist, album: $album, genre: $genre, year: $year, artworkBytes: $artworkBytes)';
}


}

/// @nodoc
abstract mixin class $EditSongEventCopyWith<$Res> implements $LocalMusicEventCopyWith<$Res> {
  factory $EditSongEventCopyWith(EditSongEvent value, $Res Function(EditSongEvent) _then) = _$EditSongEventCopyWithImpl;
@useResult
$Res call({
 SongEntity song, String? title, String? artist, String? album, String? genre, String? year, Uint8List? artworkBytes
});


$SongEntityCopyWith<$Res> get song;

}
/// @nodoc
class _$EditSongEventCopyWithImpl<$Res>
    implements $EditSongEventCopyWith<$Res> {
  _$EditSongEventCopyWithImpl(this._self, this._then);

  final EditSongEvent _self;
  final $Res Function(EditSongEvent) _then;

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? song = null,Object? title = freezed,Object? artist = freezed,Object? album = freezed,Object? genre = freezed,Object? year = freezed,Object? artworkBytes = freezed,}) {
  return _then(EditSongEvent(
song: null == song ? _self.song : song // ignore: cast_nullable_to_non_nullable
as SongEntity,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,artist: freezed == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String?,album: freezed == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as String?,artworkBytes: freezed == artworkBytes ? _self.artworkBytes : artworkBytes // ignore: cast_nullable_to_non_nullable
as Uint8List?,
  ));
}

/// Create a copy of LocalMusicEvent
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SongEntityCopyWith<$Res> get song {
  
  return $SongEntityCopyWith<$Res>(_self.song, (value) {
    return _then(_self.copyWith(song: value));
  });
}
}

// dart format on
