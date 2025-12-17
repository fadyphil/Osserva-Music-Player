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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( GetLocalSongs value)?  getLocalSongs,TResult Function( SearchSongs value)?  searchSongs,TResult Function( SortSongs value)?  sortSongs,required TResult orElse(),}){
final _that = this;
switch (_that) {
case GetLocalSongs() when getLocalSongs != null:
return getLocalSongs(_that);case SearchSongs() when searchSongs != null:
return searchSongs(_that);case SortSongs() when sortSongs != null:
return sortSongs(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( GetLocalSongs value)  getLocalSongs,required TResult Function( SearchSongs value)  searchSongs,required TResult Function( SortSongs value)  sortSongs,}){
final _that = this;
switch (_that) {
case GetLocalSongs():
return getLocalSongs(_that);case SearchSongs():
return searchSongs(_that);case SortSongs():
return sortSongs(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( GetLocalSongs value)?  getLocalSongs,TResult? Function( SearchSongs value)?  searchSongs,TResult? Function( SortSongs value)?  sortSongs,}){
final _that = this;
switch (_that) {
case GetLocalSongs() when getLocalSongs != null:
return getLocalSongs(_that);case SearchSongs() when searchSongs != null:
return searchSongs(_that);case SortSongs() when sortSongs != null:
return sortSongs(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  getLocalSongs,TResult Function( String query)?  searchSongs,TResult Function( SortOption option)?  sortSongs,required TResult orElse(),}) {final _that = this;
switch (_that) {
case GetLocalSongs() when getLocalSongs != null:
return getLocalSongs();case SearchSongs() when searchSongs != null:
return searchSongs(_that.query);case SortSongs() when sortSongs != null:
return sortSongs(_that.option);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  getLocalSongs,required TResult Function( String query)  searchSongs,required TResult Function( SortOption option)  sortSongs,}) {final _that = this;
switch (_that) {
case GetLocalSongs():
return getLocalSongs();case SearchSongs():
return searchSongs(_that.query);case SortSongs():
return sortSongs(_that.option);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  getLocalSongs,TResult? Function( String query)?  searchSongs,TResult? Function( SortOption option)?  sortSongs,}) {final _that = this;
switch (_that) {
case GetLocalSongs() when getLocalSongs != null:
return getLocalSongs();case SearchSongs() when searchSongs != null:
return searchSongs(_that.query);case SortSongs() when sortSongs != null:
return sortSongs(_that.option);case _:
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

// dart format on
