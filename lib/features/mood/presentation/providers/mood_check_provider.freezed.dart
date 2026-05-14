// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood_check_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MoodCheckState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoodCheckState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MoodCheckState()';
}


}

/// @nodoc
class $MoodCheckStateCopyWith<$Res>  {
$MoodCheckStateCopyWith(MoodCheckState _, $Res Function(MoodCheckState) __);
}


/// Adds pattern-matching-related methods to [MoodCheckState].
extension MoodCheckStatePatterns on MoodCheckState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MoodCheckPending value)?  pending,TResult Function( MoodCheckDone value)?  done,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MoodCheckPending() when pending != null:
return pending(_that);case MoodCheckDone() when done != null:
return done(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MoodCheckPending value)  pending,required TResult Function( MoodCheckDone value)  done,}){
final _that = this;
switch (_that) {
case MoodCheckPending():
return pending(_that);case MoodCheckDone():
return done(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MoodCheckPending value)?  pending,TResult? Function( MoodCheckDone value)?  done,}){
final _that = this;
switch (_that) {
case MoodCheckPending() when pending != null:
return pending(_that);case MoodCheckDone() when done != null:
return done(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  pending,TResult Function( int? suggestedMinutes)?  done,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MoodCheckPending() when pending != null:
return pending();case MoodCheckDone() when done != null:
return done(_that.suggestedMinutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  pending,required TResult Function( int? suggestedMinutes)  done,}) {final _that = this;
switch (_that) {
case MoodCheckPending():
return pending();case MoodCheckDone():
return done(_that.suggestedMinutes);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  pending,TResult? Function( int? suggestedMinutes)?  done,}) {final _that = this;
switch (_that) {
case MoodCheckPending() when pending != null:
return pending();case MoodCheckDone() when done != null:
return done(_that.suggestedMinutes);case _:
  return null;

}
}

}

/// @nodoc


class MoodCheckPending implements MoodCheckState {
  const MoodCheckPending();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoodCheckPending);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MoodCheckState.pending()';
}


}




/// @nodoc


class MoodCheckDone implements MoodCheckState {
  const MoodCheckDone({this.suggestedMinutes});
  

 final  int? suggestedMinutes;

/// Create a copy of MoodCheckState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoodCheckDoneCopyWith<MoodCheckDone> get copyWith => _$MoodCheckDoneCopyWithImpl<MoodCheckDone>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoodCheckDone&&(identical(other.suggestedMinutes, suggestedMinutes) || other.suggestedMinutes == suggestedMinutes));
}


@override
int get hashCode => Object.hash(runtimeType,suggestedMinutes);

@override
String toString() {
  return 'MoodCheckState.done(suggestedMinutes: $suggestedMinutes)';
}


}

/// @nodoc
abstract mixin class $MoodCheckDoneCopyWith<$Res> implements $MoodCheckStateCopyWith<$Res> {
  factory $MoodCheckDoneCopyWith(MoodCheckDone value, $Res Function(MoodCheckDone) _then) = _$MoodCheckDoneCopyWithImpl;
@useResult
$Res call({
 int? suggestedMinutes
});




}
/// @nodoc
class _$MoodCheckDoneCopyWithImpl<$Res>
    implements $MoodCheckDoneCopyWith<$Res> {
  _$MoodCheckDoneCopyWithImpl(this._self, this._then);

  final MoodCheckDone _self;
  final $Res Function(MoodCheckDone) _then;

/// Create a copy of MoodCheckState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? suggestedMinutes = freezed,}) {
  return _then(MoodCheckDone(
suggestedMinutes: freezed == suggestedMinutes ? _self.suggestedMinutes : suggestedMinutes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
