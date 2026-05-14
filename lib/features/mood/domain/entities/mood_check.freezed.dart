// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood_check.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MoodCheck {

 String get id; String get userId; String? get sessionId; int get moodLevel; DateTime get checkedAt;
/// Create a copy of MoodCheck
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoodCheckCopyWith<MoodCheck> get copyWith => _$MoodCheckCopyWithImpl<MoodCheck>(this as MoodCheck, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoodCheck&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.moodLevel, moodLevel) || other.moodLevel == moodLevel)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,sessionId,moodLevel,checkedAt);

@override
String toString() {
  return 'MoodCheck(id: $id, userId: $userId, sessionId: $sessionId, moodLevel: $moodLevel, checkedAt: $checkedAt)';
}


}

/// @nodoc
abstract mixin class $MoodCheckCopyWith<$Res>  {
  factory $MoodCheckCopyWith(MoodCheck value, $Res Function(MoodCheck) _then) = _$MoodCheckCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? sessionId, int moodLevel, DateTime checkedAt
});




}
/// @nodoc
class _$MoodCheckCopyWithImpl<$Res>
    implements $MoodCheckCopyWith<$Res> {
  _$MoodCheckCopyWithImpl(this._self, this._then);

  final MoodCheck _self;
  final $Res Function(MoodCheck) _then;

/// Create a copy of MoodCheck
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? sessionId = freezed,Object? moodLevel = null,Object? checkedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,moodLevel: null == moodLevel ? _self.moodLevel : moodLevel // ignore: cast_nullable_to_non_nullable
as int,checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [MoodCheck].
extension MoodCheckPatterns on MoodCheck {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoodCheck value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoodCheck() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoodCheck value)  $default,){
final _that = this;
switch (_that) {
case _MoodCheck():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoodCheck value)?  $default,){
final _that = this;
switch (_that) {
case _MoodCheck() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? sessionId,  int moodLevel,  DateTime checkedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoodCheck() when $default != null:
return $default(_that.id,_that.userId,_that.sessionId,_that.moodLevel,_that.checkedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? sessionId,  int moodLevel,  DateTime checkedAt)  $default,) {final _that = this;
switch (_that) {
case _MoodCheck():
return $default(_that.id,_that.userId,_that.sessionId,_that.moodLevel,_that.checkedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? sessionId,  int moodLevel,  DateTime checkedAt)?  $default,) {final _that = this;
switch (_that) {
case _MoodCheck() when $default != null:
return $default(_that.id,_that.userId,_that.sessionId,_that.moodLevel,_that.checkedAt);case _:
  return null;

}
}

}

/// @nodoc


class _MoodCheck implements MoodCheck {
  const _MoodCheck({required this.id, required this.userId, this.sessionId, required this.moodLevel, required this.checkedAt});
  

@override final  String id;
@override final  String userId;
@override final  String? sessionId;
@override final  int moodLevel;
@override final  DateTime checkedAt;

/// Create a copy of MoodCheck
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoodCheckCopyWith<_MoodCheck> get copyWith => __$MoodCheckCopyWithImpl<_MoodCheck>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoodCheck&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.moodLevel, moodLevel) || other.moodLevel == moodLevel)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,sessionId,moodLevel,checkedAt);

@override
String toString() {
  return 'MoodCheck(id: $id, userId: $userId, sessionId: $sessionId, moodLevel: $moodLevel, checkedAt: $checkedAt)';
}


}

/// @nodoc
abstract mixin class _$MoodCheckCopyWith<$Res> implements $MoodCheckCopyWith<$Res> {
  factory _$MoodCheckCopyWith(_MoodCheck value, $Res Function(_MoodCheck) _then) = __$MoodCheckCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? sessionId, int moodLevel, DateTime checkedAt
});




}
/// @nodoc
class __$MoodCheckCopyWithImpl<$Res>
    implements _$MoodCheckCopyWith<$Res> {
  __$MoodCheckCopyWithImpl(this._self, this._then);

  final _MoodCheck _self;
  final $Res Function(_MoodCheck) _then;

/// Create a copy of MoodCheck
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? sessionId = freezed,Object? moodLevel = null,Object? checkedAt = null,}) {
  return _then(_MoodCheck(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,moodLevel: null == moodLevel ? _self.moodLevel : moodLevel // ignore: cast_nullable_to_non_nullable
as int,checkedAt: null == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
