// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TimerState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimerState()';
}


}

/// @nodoc
class $TimerStateCopyWith<$Res>  {
$TimerStateCopyWith(TimerState _, $Res Function(TimerState) __);
}


/// Adds pattern-matching-related methods to [TimerState].
extension TimerStatePatterns on TimerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TimerIdle value)?  idle,TResult Function( TimerRunning value)?  running,TResult Function( TimerPaused value)?  paused,TResult Function( TimerCompleted value)?  completed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TimerIdle() when idle != null:
return idle(_that);case TimerRunning() when running != null:
return running(_that);case TimerPaused() when paused != null:
return paused(_that);case TimerCompleted() when completed != null:
return completed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TimerIdle value)  idle,required TResult Function( TimerRunning value)  running,required TResult Function( TimerPaused value)  paused,required TResult Function( TimerCompleted value)  completed,}){
final _that = this;
switch (_that) {
case TimerIdle():
return idle(_that);case TimerRunning():
return running(_that);case TimerPaused():
return paused(_that);case TimerCompleted():
return completed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TimerIdle value)?  idle,TResult? Function( TimerRunning value)?  running,TResult? Function( TimerPaused value)?  paused,TResult? Function( TimerCompleted value)?  completed,}){
final _that = this;
switch (_that) {
case TimerIdle() when idle != null:
return idle(_that);case TimerRunning() when running != null:
return running(_that);case TimerPaused() when paused != null:
return paused(_that);case TimerCompleted() when completed != null:
return completed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  idle,TResult Function( Duration remaining,  int distractionCount,  int resetCount,  bool adaptiveCheckInVisible)?  running,TResult Function( Duration remaining)?  paused,TResult Function()?  completed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TimerIdle() when idle != null:
return idle();case TimerRunning() when running != null:
return running(_that.remaining,_that.distractionCount,_that.resetCount,_that.adaptiveCheckInVisible);case TimerPaused() when paused != null:
return paused(_that.remaining);case TimerCompleted() when completed != null:
return completed();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  idle,required TResult Function( Duration remaining,  int distractionCount,  int resetCount,  bool adaptiveCheckInVisible)  running,required TResult Function( Duration remaining)  paused,required TResult Function()  completed,}) {final _that = this;
switch (_that) {
case TimerIdle():
return idle();case TimerRunning():
return running(_that.remaining,_that.distractionCount,_that.resetCount,_that.adaptiveCheckInVisible);case TimerPaused():
return paused(_that.remaining);case TimerCompleted():
return completed();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  idle,TResult? Function( Duration remaining,  int distractionCount,  int resetCount,  bool adaptiveCheckInVisible)?  running,TResult? Function( Duration remaining)?  paused,TResult? Function()?  completed,}) {final _that = this;
switch (_that) {
case TimerIdle() when idle != null:
return idle();case TimerRunning() when running != null:
return running(_that.remaining,_that.distractionCount,_that.resetCount,_that.adaptiveCheckInVisible);case TimerPaused() when paused != null:
return paused(_that.remaining);case TimerCompleted() when completed != null:
return completed();case _:
  return null;

}
}

}

/// @nodoc


class TimerIdle implements TimerState {
  const TimerIdle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerIdle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimerState.idle()';
}


}




/// @nodoc


class TimerRunning implements TimerState {
  const TimerRunning({required this.remaining, required this.distractionCount, required this.resetCount, this.adaptiveCheckInVisible = false});
  

 final  Duration remaining;
 final  int distractionCount;
 final  int resetCount;
@JsonKey() final  bool adaptiveCheckInVisible;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerRunningCopyWith<TimerRunning> get copyWith => _$TimerRunningCopyWithImpl<TimerRunning>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerRunning&&(identical(other.remaining, remaining) || other.remaining == remaining)&&(identical(other.distractionCount, distractionCount) || other.distractionCount == distractionCount)&&(identical(other.resetCount, resetCount) || other.resetCount == resetCount)&&(identical(other.adaptiveCheckInVisible, adaptiveCheckInVisible) || other.adaptiveCheckInVisible == adaptiveCheckInVisible));
}


@override
int get hashCode => Object.hash(runtimeType,remaining,distractionCount,resetCount,adaptiveCheckInVisible);

@override
String toString() {
  return 'TimerState.running(remaining: $remaining, distractionCount: $distractionCount, resetCount: $resetCount, adaptiveCheckInVisible: $adaptiveCheckInVisible)';
}


}

/// @nodoc
abstract mixin class $TimerRunningCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory $TimerRunningCopyWith(TimerRunning value, $Res Function(TimerRunning) _then) = _$TimerRunningCopyWithImpl;
@useResult
$Res call({
 Duration remaining, int distractionCount, int resetCount, bool adaptiveCheckInVisible
});




}
/// @nodoc
class _$TimerRunningCopyWithImpl<$Res>
    implements $TimerRunningCopyWith<$Res> {
  _$TimerRunningCopyWithImpl(this._self, this._then);

  final TimerRunning _self;
  final $Res Function(TimerRunning) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? remaining = null,Object? distractionCount = null,Object? resetCount = null,Object? adaptiveCheckInVisible = null,}) {
  return _then(TimerRunning(
remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Duration,distractionCount: null == distractionCount ? _self.distractionCount : distractionCount // ignore: cast_nullable_to_non_nullable
as int,resetCount: null == resetCount ? _self.resetCount : resetCount // ignore: cast_nullable_to_non_nullable
as int,adaptiveCheckInVisible: null == adaptiveCheckInVisible ? _self.adaptiveCheckInVisible : adaptiveCheckInVisible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class TimerPaused implements TimerState {
  const TimerPaused({required this.remaining});
  

 final  Duration remaining;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TimerPausedCopyWith<TimerPaused> get copyWith => _$TimerPausedCopyWithImpl<TimerPaused>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerPaused&&(identical(other.remaining, remaining) || other.remaining == remaining));
}


@override
int get hashCode => Object.hash(runtimeType,remaining);

@override
String toString() {
  return 'TimerState.paused(remaining: $remaining)';
}


}

/// @nodoc
abstract mixin class $TimerPausedCopyWith<$Res> implements $TimerStateCopyWith<$Res> {
  factory $TimerPausedCopyWith(TimerPaused value, $Res Function(TimerPaused) _then) = _$TimerPausedCopyWithImpl;
@useResult
$Res call({
 Duration remaining
});




}
/// @nodoc
class _$TimerPausedCopyWithImpl<$Res>
    implements $TimerPausedCopyWith<$Res> {
  _$TimerPausedCopyWithImpl(this._self, this._then);

  final TimerPaused _self;
  final $Res Function(TimerPaused) _then;

/// Create a copy of TimerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? remaining = null,}) {
  return _then(TimerPaused(
remaining: null == remaining ? _self.remaining : remaining // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

/// @nodoc


class TimerCompleted implements TimerState {
  const TimerCompleted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TimerCompleted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TimerState.completed()';
}


}




// dart format on
