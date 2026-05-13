// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Session {

 String get id; String get userId; String? get taskId; int get targetDurationMinutes; SessionStatus get status; int get distractionCount; int get resetCount; bool get manualWorkMode; DateTime get startedAt; DateTime? get completedAt;
/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SessionCopyWith<Session> get copyWith => _$SessionCopyWithImpl<Session>(this as Session, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Session&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.targetDurationMinutes, targetDurationMinutes) || other.targetDurationMinutes == targetDurationMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.distractionCount, distractionCount) || other.distractionCount == distractionCount)&&(identical(other.resetCount, resetCount) || other.resetCount == resetCount)&&(identical(other.manualWorkMode, manualWorkMode) || other.manualWorkMode == manualWorkMode)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,taskId,targetDurationMinutes,status,distractionCount,resetCount,manualWorkMode,startedAt,completedAt);

@override
String toString() {
  return 'Session(id: $id, userId: $userId, taskId: $taskId, targetDurationMinutes: $targetDurationMinutes, status: $status, distractionCount: $distractionCount, resetCount: $resetCount, manualWorkMode: $manualWorkMode, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class $SessionCopyWith<$Res>  {
  factory $SessionCopyWith(Session value, $Res Function(Session) _then) = _$SessionCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String? taskId, int targetDurationMinutes, SessionStatus status, int distractionCount, int resetCount, bool manualWorkMode, DateTime startedAt, DateTime? completedAt
});




}
/// @nodoc
class _$SessionCopyWithImpl<$Res>
    implements $SessionCopyWith<$Res> {
  _$SessionCopyWithImpl(this._self, this._then);

  final Session _self;
  final $Res Function(Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? taskId = freezed,Object? targetDurationMinutes = null,Object? status = null,Object? distractionCount = null,Object? resetCount = null,Object? manualWorkMode = null,Object? startedAt = null,Object? completedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String?,targetDurationMinutes: null == targetDurationMinutes ? _self.targetDurationMinutes : targetDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,distractionCount: null == distractionCount ? _self.distractionCount : distractionCount // ignore: cast_nullable_to_non_nullable
as int,resetCount: null == resetCount ? _self.resetCount : resetCount // ignore: cast_nullable_to_non_nullable
as int,manualWorkMode: null == manualWorkMode ? _self.manualWorkMode : manualWorkMode // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Session].
extension SessionPatterns on Session {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Session value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Session value)  $default,){
final _that = this;
switch (_that) {
case _Session():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Session value)?  $default,){
final _that = this;
switch (_that) {
case _Session() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String? taskId,  int targetDurationMinutes,  SessionStatus status,  int distractionCount,  int resetCount,  bool manualWorkMode,  DateTime startedAt,  DateTime? completedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.userId,_that.taskId,_that.targetDurationMinutes,_that.status,_that.distractionCount,_that.resetCount,_that.manualWorkMode,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String? taskId,  int targetDurationMinutes,  SessionStatus status,  int distractionCount,  int resetCount,  bool manualWorkMode,  DateTime startedAt,  DateTime? completedAt)  $default,) {final _that = this;
switch (_that) {
case _Session():
return $default(_that.id,_that.userId,_that.taskId,_that.targetDurationMinutes,_that.status,_that.distractionCount,_that.resetCount,_that.manualWorkMode,_that.startedAt,_that.completedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String? taskId,  int targetDurationMinutes,  SessionStatus status,  int distractionCount,  int resetCount,  bool manualWorkMode,  DateTime startedAt,  DateTime? completedAt)?  $default,) {final _that = this;
switch (_that) {
case _Session() when $default != null:
return $default(_that.id,_that.userId,_that.taskId,_that.targetDurationMinutes,_that.status,_that.distractionCount,_that.resetCount,_that.manualWorkMode,_that.startedAt,_that.completedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Session implements Session {
  const _Session({required this.id, required this.userId, this.taskId, required this.targetDurationMinutes, required this.status, required this.distractionCount, required this.resetCount, required this.manualWorkMode, required this.startedAt, this.completedAt});
  

@override final  String id;
@override final  String userId;
@override final  String? taskId;
@override final  int targetDurationMinutes;
@override final  SessionStatus status;
@override final  int distractionCount;
@override final  int resetCount;
@override final  bool manualWorkMode;
@override final  DateTime startedAt;
@override final  DateTime? completedAt;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SessionCopyWith<_Session> get copyWith => __$SessionCopyWithImpl<_Session>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Session&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.targetDurationMinutes, targetDurationMinutes) || other.targetDurationMinutes == targetDurationMinutes)&&(identical(other.status, status) || other.status == status)&&(identical(other.distractionCount, distractionCount) || other.distractionCount == distractionCount)&&(identical(other.resetCount, resetCount) || other.resetCount == resetCount)&&(identical(other.manualWorkMode, manualWorkMode) || other.manualWorkMode == manualWorkMode)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt));
}


@override
int get hashCode => Object.hash(runtimeType,id,userId,taskId,targetDurationMinutes,status,distractionCount,resetCount,manualWorkMode,startedAt,completedAt);

@override
String toString() {
  return 'Session(id: $id, userId: $userId, taskId: $taskId, targetDurationMinutes: $targetDurationMinutes, status: $status, distractionCount: $distractionCount, resetCount: $resetCount, manualWorkMode: $manualWorkMode, startedAt: $startedAt, completedAt: $completedAt)';
}


}

/// @nodoc
abstract mixin class _$SessionCopyWith<$Res> implements $SessionCopyWith<$Res> {
  factory _$SessionCopyWith(_Session value, $Res Function(_Session) _then) = __$SessionCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String? taskId, int targetDurationMinutes, SessionStatus status, int distractionCount, int resetCount, bool manualWorkMode, DateTime startedAt, DateTime? completedAt
});




}
/// @nodoc
class __$SessionCopyWithImpl<$Res>
    implements _$SessionCopyWith<$Res> {
  __$SessionCopyWithImpl(this._self, this._then);

  final _Session _self;
  final $Res Function(_Session) _then;

/// Create a copy of Session
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? taskId = freezed,Object? targetDurationMinutes = null,Object? status = null,Object? distractionCount = null,Object? resetCount = null,Object? manualWorkMode = null,Object? startedAt = null,Object? completedAt = freezed,}) {
  return _then(_Session(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String?,targetDurationMinutes: null == targetDurationMinutes ? _self.targetDurationMinutes : targetDurationMinutes // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SessionStatus,distractionCount: null == distractionCount ? _self.distractionCount : distractionCount // ignore: cast_nullable_to_non_nullable
as int,resetCount: null == resetCount ? _self.resetCount : resetCount // ignore: cast_nullable_to_non_nullable
as int,manualWorkMode: null == manualWorkMode ? _self.manualWorkMode : manualWorkMode // ignore: cast_nullable_to_non_nullable
as bool,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,completedAt: freezed == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
