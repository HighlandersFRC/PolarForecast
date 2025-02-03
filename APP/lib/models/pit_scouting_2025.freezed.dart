// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pit_scouting_2025.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PitScouting2025 _$PitScouting2025FromJson(Map<String, dynamic> json) {
  return _PitScouting2025.fromJson(json);
}

/// @nodoc
mixin _$PitScouting2025 {
  String get user_id => throw _privateConstructorUsedError;
  int get team_number => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  String get event_code => throw _privateConstructorUsedError;
  PitData2025 get data => throw _privateConstructorUsedError;

  /// Serializes this PitScouting2025 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PitScouting2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PitScouting2025CopyWith<PitScouting2025> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PitScouting2025CopyWith<$Res> {
  factory $PitScouting2025CopyWith(
          PitScouting2025 value, $Res Function(PitScouting2025) then) =
      _$PitScouting2025CopyWithImpl<$Res, PitScouting2025>;
  @useResult
  $Res call(
      {String user_id,
      int team_number,
      int time,
      String event_code,
      PitData2025 data});

  $PitData2025CopyWith<$Res> get data;
}

/// @nodoc
class _$PitScouting2025CopyWithImpl<$Res, $Val extends PitScouting2025>
    implements $PitScouting2025CopyWith<$Res> {
  _$PitScouting2025CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PitScouting2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? team_number = null,
    Object? time = null,
    Object? event_code = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PitData2025,
    ) as $Val);
  }

  /// Create a copy of PitScouting2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PitData2025CopyWith<$Res> get data {
    return $PitData2025CopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PitScouting2025ImplCopyWith<$Res>
    implements $PitScouting2025CopyWith<$Res> {
  factory _$$PitScouting2025ImplCopyWith(_$PitScouting2025Impl value,
          $Res Function(_$PitScouting2025Impl) then) =
      __$$PitScouting2025ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String user_id,
      int team_number,
      int time,
      String event_code,
      PitData2025 data});

  @override
  $PitData2025CopyWith<$Res> get data;
}

/// @nodoc
class __$$PitScouting2025ImplCopyWithImpl<$Res>
    extends _$PitScouting2025CopyWithImpl<$Res, _$PitScouting2025Impl>
    implements _$$PitScouting2025ImplCopyWith<$Res> {
  __$$PitScouting2025ImplCopyWithImpl(
      _$PitScouting2025Impl _value, $Res Function(_$PitScouting2025Impl) _then)
      : super(_value, _then);

  /// Create a copy of PitScouting2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? team_number = null,
    Object? time = null,
    Object? event_code = null,
    Object? data = null,
  }) {
    return _then(_$PitScouting2025Impl(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PitData2025,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PitScouting2025Impl implements _PitScouting2025 {
  const _$PitScouting2025Impl(
      {required this.user_id,
      required this.team_number,
      required this.time,
      required this.event_code,
      required this.data});

  factory _$PitScouting2025Impl.fromJson(Map<String, dynamic> json) =>
      _$$PitScouting2025ImplFromJson(json);

  @override
  final String user_id;
  @override
  final int team_number;
  @override
  final int time;
  @override
  final String event_code;
  @override
  final PitData2025 data;

  @override
  String toString() {
    return 'PitScouting2025(user_id: $user_id, team_number: $team_number, time: $time, event_code: $event_code, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PitScouting2025Impl &&
            (identical(other.user_id, user_id) || other.user_id == user_id) &&
            (identical(other.team_number, team_number) ||
                other.team_number == team_number) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.event_code, event_code) ||
                other.event_code == event_code) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, user_id, team_number, time, event_code, data);

  /// Create a copy of PitScouting2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PitScouting2025ImplCopyWith<_$PitScouting2025Impl> get copyWith =>
      __$$PitScouting2025ImplCopyWithImpl<_$PitScouting2025Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PitScouting2025ImplToJson(
      this,
    );
  }
}

abstract class _PitScouting2025 implements PitScouting2025 {
  const factory _PitScouting2025(
      {required final String user_id,
      required final int team_number,
      required final int time,
      required final String event_code,
      required final PitData2025 data}) = _$PitScouting2025Impl;

  factory _PitScouting2025.fromJson(Map<String, dynamic> json) =
      _$PitScouting2025Impl.fromJson;

  @override
  String get user_id;
  @override
  int get team_number;
  @override
  int get time;
  @override
  String get event_code;
  @override
  PitData2025 get data;

  /// Create a copy of PitScouting2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PitScouting2025ImplCopyWith<_$PitScouting2025Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

PitData2025 _$PitData2025FromJson(Map<String, dynamic> json) {
  return _PitData2025.fromJson(json);
}

/// @nodoc
mixin _$PitData2025 {
  int get driver_experience_events => throw _privateConstructorUsedError;
  String get drive_train => throw _privateConstructorUsedError;
  bool get can_score_coral => throw _privateConstructorUsedError;
  List<int> get coral_levels => throw _privateConstructorUsedError;
  bool get can_score_processor => throw _privateConstructorUsedError;
  bool get can_score_net => throw _privateConstructorUsedError;
  bool get ground_coral_pickup => throw _privateConstructorUsedError;
  bool get feeder_coral_pickup => throw _privateConstructorUsedError;
  bool get ground_algae_pickup => throw _privateConstructorUsedError;
  bool get reef_algae_pickup => throw _privateConstructorUsedError;
  List<String> get climbing => throw _privateConstructorUsedError;
  int get spare_parts => throw _privateConstructorUsedError;
  String get favorite_color => throw _privateConstructorUsedError;
  List<PitAuto2025> get autos => throw _privateConstructorUsedError;

  /// Serializes this PitData2025 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PitData2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PitData2025CopyWith<PitData2025> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PitData2025CopyWith<$Res> {
  factory $PitData2025CopyWith(
          PitData2025 value, $Res Function(PitData2025) then) =
      _$PitData2025CopyWithImpl<$Res, PitData2025>;
  @useResult
  $Res call(
      {int driver_experience_events,
      String drive_train,
      bool can_score_coral,
      List<int> coral_levels,
      bool can_score_processor,
      bool can_score_net,
      bool ground_coral_pickup,
      bool feeder_coral_pickup,
      bool ground_algae_pickup,
      bool reef_algae_pickup,
      List<String> climbing,
      int spare_parts,
      String favorite_color,
      List<PitAuto2025> autos});
}

/// @nodoc
class _$PitData2025CopyWithImpl<$Res, $Val extends PitData2025>
    implements $PitData2025CopyWith<$Res> {
  _$PitData2025CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PitData2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driver_experience_events = null,
    Object? drive_train = null,
    Object? can_score_coral = null,
    Object? coral_levels = null,
    Object? can_score_processor = null,
    Object? can_score_net = null,
    Object? ground_coral_pickup = null,
    Object? feeder_coral_pickup = null,
    Object? ground_algae_pickup = null,
    Object? reef_algae_pickup = null,
    Object? climbing = null,
    Object? spare_parts = null,
    Object? favorite_color = null,
    Object? autos = null,
  }) {
    return _then(_value.copyWith(
      driver_experience_events: null == driver_experience_events
          ? _value.driver_experience_events
          : driver_experience_events // ignore: cast_nullable_to_non_nullable
              as int,
      drive_train: null == drive_train
          ? _value.drive_train
          : drive_train // ignore: cast_nullable_to_non_nullable
              as String,
      can_score_coral: null == can_score_coral
          ? _value.can_score_coral
          : can_score_coral // ignore: cast_nullable_to_non_nullable
              as bool,
      coral_levels: null == coral_levels
          ? _value.coral_levels
          : coral_levels // ignore: cast_nullable_to_non_nullable
              as List<int>,
      can_score_processor: null == can_score_processor
          ? _value.can_score_processor
          : can_score_processor // ignore: cast_nullable_to_non_nullable
              as bool,
      can_score_net: null == can_score_net
          ? _value.can_score_net
          : can_score_net // ignore: cast_nullable_to_non_nullable
              as bool,
      ground_coral_pickup: null == ground_coral_pickup
          ? _value.ground_coral_pickup
          : ground_coral_pickup // ignore: cast_nullable_to_non_nullable
              as bool,
      feeder_coral_pickup: null == feeder_coral_pickup
          ? _value.feeder_coral_pickup
          : feeder_coral_pickup // ignore: cast_nullable_to_non_nullable
              as bool,
      ground_algae_pickup: null == ground_algae_pickup
          ? _value.ground_algae_pickup
          : ground_algae_pickup // ignore: cast_nullable_to_non_nullable
              as bool,
      reef_algae_pickup: null == reef_algae_pickup
          ? _value.reef_algae_pickup
          : reef_algae_pickup // ignore: cast_nullable_to_non_nullable
              as bool,
      climbing: null == climbing
          ? _value.climbing
          : climbing // ignore: cast_nullable_to_non_nullable
              as List<String>,
      spare_parts: null == spare_parts
          ? _value.spare_parts
          : spare_parts // ignore: cast_nullable_to_non_nullable
              as int,
      favorite_color: null == favorite_color
          ? _value.favorite_color
          : favorite_color // ignore: cast_nullable_to_non_nullable
              as String,
      autos: null == autos
          ? _value.autos
          : autos // ignore: cast_nullable_to_non_nullable
              as List<PitAuto2025>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PitData2025ImplCopyWith<$Res>
    implements $PitData2025CopyWith<$Res> {
  factory _$$PitData2025ImplCopyWith(
          _$PitData2025Impl value, $Res Function(_$PitData2025Impl) then) =
      __$$PitData2025ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int driver_experience_events,
      String drive_train,
      bool can_score_coral,
      List<int> coral_levels,
      bool can_score_processor,
      bool can_score_net,
      bool ground_coral_pickup,
      bool feeder_coral_pickup,
      bool ground_algae_pickup,
      bool reef_algae_pickup,
      List<String> climbing,
      int spare_parts,
      String favorite_color,
      List<PitAuto2025> autos});
}

/// @nodoc
class __$$PitData2025ImplCopyWithImpl<$Res>
    extends _$PitData2025CopyWithImpl<$Res, _$PitData2025Impl>
    implements _$$PitData2025ImplCopyWith<$Res> {
  __$$PitData2025ImplCopyWithImpl(
      _$PitData2025Impl _value, $Res Function(_$PitData2025Impl) _then)
      : super(_value, _then);

  /// Create a copy of PitData2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driver_experience_events = null,
    Object? drive_train = null,
    Object? can_score_coral = null,
    Object? coral_levels = null,
    Object? can_score_processor = null,
    Object? can_score_net = null,
    Object? ground_coral_pickup = null,
    Object? feeder_coral_pickup = null,
    Object? ground_algae_pickup = null,
    Object? reef_algae_pickup = null,
    Object? climbing = null,
    Object? spare_parts = null,
    Object? favorite_color = null,
    Object? autos = null,
  }) {
    return _then(_$PitData2025Impl(
      driver_experience_events: null == driver_experience_events
          ? _value.driver_experience_events
          : driver_experience_events // ignore: cast_nullable_to_non_nullable
              as int,
      drive_train: null == drive_train
          ? _value.drive_train
          : drive_train // ignore: cast_nullable_to_non_nullable
              as String,
      can_score_coral: null == can_score_coral
          ? _value.can_score_coral
          : can_score_coral // ignore: cast_nullable_to_non_nullable
              as bool,
      coral_levels: null == coral_levels
          ? _value._coral_levels
          : coral_levels // ignore: cast_nullable_to_non_nullable
              as List<int>,
      can_score_processor: null == can_score_processor
          ? _value.can_score_processor
          : can_score_processor // ignore: cast_nullable_to_non_nullable
              as bool,
      can_score_net: null == can_score_net
          ? _value.can_score_net
          : can_score_net // ignore: cast_nullable_to_non_nullable
              as bool,
      ground_coral_pickup: null == ground_coral_pickup
          ? _value.ground_coral_pickup
          : ground_coral_pickup // ignore: cast_nullable_to_non_nullable
              as bool,
      feeder_coral_pickup: null == feeder_coral_pickup
          ? _value.feeder_coral_pickup
          : feeder_coral_pickup // ignore: cast_nullable_to_non_nullable
              as bool,
      ground_algae_pickup: null == ground_algae_pickup
          ? _value.ground_algae_pickup
          : ground_algae_pickup // ignore: cast_nullable_to_non_nullable
              as bool,
      reef_algae_pickup: null == reef_algae_pickup
          ? _value.reef_algae_pickup
          : reef_algae_pickup // ignore: cast_nullable_to_non_nullable
              as bool,
      climbing: null == climbing
          ? _value._climbing
          : climbing // ignore: cast_nullable_to_non_nullable
              as List<String>,
      spare_parts: null == spare_parts
          ? _value.spare_parts
          : spare_parts // ignore: cast_nullable_to_non_nullable
              as int,
      favorite_color: null == favorite_color
          ? _value.favorite_color
          : favorite_color // ignore: cast_nullable_to_non_nullable
              as String,
      autos: null == autos
          ? _value._autos
          : autos // ignore: cast_nullable_to_non_nullable
              as List<PitAuto2025>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PitData2025Impl implements _PitData2025 {
  const _$PitData2025Impl(
      {required this.driver_experience_events,
      required this.drive_train,
      required this.can_score_coral,
      required final List<int> coral_levels,
      required this.can_score_processor,
      required this.can_score_net,
      required this.ground_coral_pickup,
      required this.feeder_coral_pickup,
      required this.ground_algae_pickup,
      required this.reef_algae_pickup,
      required final List<String> climbing,
      required this.spare_parts,
      required this.favorite_color,
      required final List<PitAuto2025> autos})
      : _coral_levels = coral_levels,
        _climbing = climbing,
        _autos = autos;

  factory _$PitData2025Impl.fromJson(Map<String, dynamic> json) =>
      _$$PitData2025ImplFromJson(json);

  @override
  final int driver_experience_events;
  @override
  final String drive_train;
  @override
  final bool can_score_coral;
  final List<int> _coral_levels;
  @override
  List<int> get coral_levels {
    if (_coral_levels is EqualUnmodifiableListView) return _coral_levels;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_coral_levels);
  }

  @override
  final bool can_score_processor;
  @override
  final bool can_score_net;
  @override
  final bool ground_coral_pickup;
  @override
  final bool feeder_coral_pickup;
  @override
  final bool ground_algae_pickup;
  @override
  final bool reef_algae_pickup;
  final List<String> _climbing;
  @override
  List<String> get climbing {
    if (_climbing is EqualUnmodifiableListView) return _climbing;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_climbing);
  }

  @override
  final int spare_parts;
  @override
  final String favorite_color;
  final List<PitAuto2025> _autos;
  @override
  List<PitAuto2025> get autos {
    if (_autos is EqualUnmodifiableListView) return _autos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_autos);
  }

  @override
  String toString() {
    return 'PitData2025(driver_experience_events: $driver_experience_events, drive_train: $drive_train, can_score_coral: $can_score_coral, coral_levels: $coral_levels, can_score_processor: $can_score_processor, can_score_net: $can_score_net, ground_coral_pickup: $ground_coral_pickup, feeder_coral_pickup: $feeder_coral_pickup, ground_algae_pickup: $ground_algae_pickup, reef_algae_pickup: $reef_algae_pickup, climbing: $climbing, spare_parts: $spare_parts, favorite_color: $favorite_color, autos: $autos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PitData2025Impl &&
            (identical(
                    other.driver_experience_events, driver_experience_events) ||
                other.driver_experience_events == driver_experience_events) &&
            (identical(other.drive_train, drive_train) ||
                other.drive_train == drive_train) &&
            (identical(other.can_score_coral, can_score_coral) ||
                other.can_score_coral == can_score_coral) &&
            const DeepCollectionEquality()
                .equals(other._coral_levels, _coral_levels) &&
            (identical(other.can_score_processor, can_score_processor) ||
                other.can_score_processor == can_score_processor) &&
            (identical(other.can_score_net, can_score_net) ||
                other.can_score_net == can_score_net) &&
            (identical(other.ground_coral_pickup, ground_coral_pickup) ||
                other.ground_coral_pickup == ground_coral_pickup) &&
            (identical(other.feeder_coral_pickup, feeder_coral_pickup) ||
                other.feeder_coral_pickup == feeder_coral_pickup) &&
            (identical(other.ground_algae_pickup, ground_algae_pickup) ||
                other.ground_algae_pickup == ground_algae_pickup) &&
            (identical(other.reef_algae_pickup, reef_algae_pickup) ||
                other.reef_algae_pickup == reef_algae_pickup) &&
            const DeepCollectionEquality().equals(other._climbing, _climbing) &&
            (identical(other.spare_parts, spare_parts) ||
                other.spare_parts == spare_parts) &&
            (identical(other.favorite_color, favorite_color) ||
                other.favorite_color == favorite_color) &&
            const DeepCollectionEquality().equals(other._autos, _autos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      driver_experience_events,
      drive_train,
      can_score_coral,
      const DeepCollectionEquality().hash(_coral_levels),
      can_score_processor,
      can_score_net,
      ground_coral_pickup,
      feeder_coral_pickup,
      ground_algae_pickup,
      reef_algae_pickup,
      const DeepCollectionEquality().hash(_climbing),
      spare_parts,
      favorite_color,
      const DeepCollectionEquality().hash(_autos));

  /// Create a copy of PitData2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PitData2025ImplCopyWith<_$PitData2025Impl> get copyWith =>
      __$$PitData2025ImplCopyWithImpl<_$PitData2025Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PitData2025ImplToJson(
      this,
    );
  }
}

abstract class _PitData2025 implements PitData2025 {
  const factory _PitData2025(
      {required final int driver_experience_events,
      required final String drive_train,
      required final bool can_score_coral,
      required final List<int> coral_levels,
      required final bool can_score_processor,
      required final bool can_score_net,
      required final bool ground_coral_pickup,
      required final bool feeder_coral_pickup,
      required final bool ground_algae_pickup,
      required final bool reef_algae_pickup,
      required final List<String> climbing,
      required final int spare_parts,
      required final String favorite_color,
      required final List<PitAuto2025> autos}) = _$PitData2025Impl;

  factory _PitData2025.fromJson(Map<String, dynamic> json) =
      _$PitData2025Impl.fromJson;

  @override
  int get driver_experience_events;
  @override
  String get drive_train;
  @override
  bool get can_score_coral;
  @override
  List<int> get coral_levels;
  @override
  bool get can_score_processor;
  @override
  bool get can_score_net;
  @override
  bool get ground_coral_pickup;
  @override
  bool get feeder_coral_pickup;
  @override
  bool get ground_algae_pickup;
  @override
  bool get reef_algae_pickup;
  @override
  List<String> get climbing;
  @override
  int get spare_parts;
  @override
  String get favorite_color;
  @override
  List<PitAuto2025> get autos;

  /// Create a copy of PitData2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PitData2025ImplCopyWith<_$PitData2025Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

PitAuto2025 _$PitAuto2025FromJson(Map<String, dynamic> json) {
  return _PitAuto2025.fromJson(json);
}

/// @nodoc
mixin _$PitAuto2025 {
  double get starting_position_meters_from_processor =>
      throw _privateConstructorUsedError;
  List<PitAutoStep2025> get steps => throw _privateConstructorUsedError;
  List<String> get field_side => throw _privateConstructorUsedError;
  bool get exit => throw _privateConstructorUsedError;
  bool get preload => throw _privateConstructorUsedError;

  /// Serializes this PitAuto2025 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PitAuto2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PitAuto2025CopyWith<PitAuto2025> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PitAuto2025CopyWith<$Res> {
  factory $PitAuto2025CopyWith(
          PitAuto2025 value, $Res Function(PitAuto2025) then) =
      _$PitAuto2025CopyWithImpl<$Res, PitAuto2025>;
  @useResult
  $Res call(
      {double starting_position_meters_from_processor,
      List<PitAutoStep2025> steps,
      List<String> field_side,
      bool exit,
      bool preload});
}

/// @nodoc
class _$PitAuto2025CopyWithImpl<$Res, $Val extends PitAuto2025>
    implements $PitAuto2025CopyWith<$Res> {
  _$PitAuto2025CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PitAuto2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? starting_position_meters_from_processor = null,
    Object? steps = null,
    Object? field_side = null,
    Object? exit = null,
    Object? preload = null,
  }) {
    return _then(_value.copyWith(
      starting_position_meters_from_processor: null ==
              starting_position_meters_from_processor
          ? _value.starting_position_meters_from_processor
          : starting_position_meters_from_processor // ignore: cast_nullable_to_non_nullable
              as double,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<PitAutoStep2025>,
      field_side: null == field_side
          ? _value.field_side
          : field_side // ignore: cast_nullable_to_non_nullable
              as List<String>,
      exit: null == exit
          ? _value.exit
          : exit // ignore: cast_nullable_to_non_nullable
              as bool,
      preload: null == preload
          ? _value.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PitAuto2025ImplCopyWith<$Res>
    implements $PitAuto2025CopyWith<$Res> {
  factory _$$PitAuto2025ImplCopyWith(
          _$PitAuto2025Impl value, $Res Function(_$PitAuto2025Impl) then) =
      __$$PitAuto2025ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double starting_position_meters_from_processor,
      List<PitAutoStep2025> steps,
      List<String> field_side,
      bool exit,
      bool preload});
}

/// @nodoc
class __$$PitAuto2025ImplCopyWithImpl<$Res>
    extends _$PitAuto2025CopyWithImpl<$Res, _$PitAuto2025Impl>
    implements _$$PitAuto2025ImplCopyWith<$Res> {
  __$$PitAuto2025ImplCopyWithImpl(
      _$PitAuto2025Impl _value, $Res Function(_$PitAuto2025Impl) _then)
      : super(_value, _then);

  /// Create a copy of PitAuto2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? starting_position_meters_from_processor = null,
    Object? steps = null,
    Object? field_side = null,
    Object? exit = null,
    Object? preload = null,
  }) {
    return _then(_$PitAuto2025Impl(
      starting_position_meters_from_processor: null ==
              starting_position_meters_from_processor
          ? _value.starting_position_meters_from_processor
          : starting_position_meters_from_processor // ignore: cast_nullable_to_non_nullable
              as double,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<PitAutoStep2025>,
      field_side: null == field_side
          ? _value._field_side
          : field_side // ignore: cast_nullable_to_non_nullable
              as List<String>,
      exit: null == exit
          ? _value.exit
          : exit // ignore: cast_nullable_to_non_nullable
              as bool,
      preload: null == preload
          ? _value.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PitAuto2025Impl implements _PitAuto2025 {
  const _$PitAuto2025Impl(
      {required this.starting_position_meters_from_processor,
      required final List<PitAutoStep2025> steps,
      required final List<String> field_side,
      required this.exit,
      required this.preload})
      : _steps = steps,
        _field_side = field_side;

  factory _$PitAuto2025Impl.fromJson(Map<String, dynamic> json) =>
      _$$PitAuto2025ImplFromJson(json);

  @override
  final double starting_position_meters_from_processor;
  final List<PitAutoStep2025> _steps;
  @override
  List<PitAutoStep2025> get steps {
    if (_steps is EqualUnmodifiableListView) return _steps;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_steps);
  }

  final List<String> _field_side;
  @override
  List<String> get field_side {
    if (_field_side is EqualUnmodifiableListView) return _field_side;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_field_side);
  }

  @override
  final bool exit;
  @override
  final bool preload;

  @override
  String toString() {
    return 'PitAuto2025(starting_position_meters_from_processor: $starting_position_meters_from_processor, steps: $steps, field_side: $field_side, exit: $exit, preload: $preload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PitAuto2025Impl &&
            (identical(other.starting_position_meters_from_processor,
                    starting_position_meters_from_processor) ||
                other.starting_position_meters_from_processor ==
                    starting_position_meters_from_processor) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            const DeepCollectionEquality()
                .equals(other._field_side, _field_side) &&
            (identical(other.exit, exit) || other.exit == exit) &&
            (identical(other.preload, preload) || other.preload == preload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      starting_position_meters_from_processor,
      const DeepCollectionEquality().hash(_steps),
      const DeepCollectionEquality().hash(_field_side),
      exit,
      preload);

  /// Create a copy of PitAuto2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PitAuto2025ImplCopyWith<_$PitAuto2025Impl> get copyWith =>
      __$$PitAuto2025ImplCopyWithImpl<_$PitAuto2025Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PitAuto2025ImplToJson(
      this,
    );
  }
}

abstract class _PitAuto2025 implements PitAuto2025 {
  const factory _PitAuto2025(
      {required final double starting_position_meters_from_processor,
      required final List<PitAutoStep2025> steps,
      required final List<String> field_side,
      required final bool exit,
      required final bool preload}) = _$PitAuto2025Impl;

  factory _PitAuto2025.fromJson(Map<String, dynamic> json) =
      _$PitAuto2025Impl.fromJson;

  @override
  double get starting_position_meters_from_processor;
  @override
  List<PitAutoStep2025> get steps;
  @override
  List<String> get field_side;
  @override
  bool get exit;
  @override
  bool get preload;

  /// Create a copy of PitAuto2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PitAuto2025ImplCopyWith<_$PitAuto2025Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

PitAutoStep2025 _$PitAutoStep2025FromJson(Map<String, dynamic> json) {
  return _PitAutoStep2025.fromJson(json);
}

/// @nodoc
mixin _$PitAutoStep2025 {
  String get name => throw _privateConstructorUsedError;
  Map<String, dynamic> get extra_data => throw _privateConstructorUsedError;

  /// Serializes this PitAutoStep2025 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PitAutoStep2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PitAutoStep2025CopyWith<PitAutoStep2025> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PitAutoStep2025CopyWith<$Res> {
  factory $PitAutoStep2025CopyWith(
          PitAutoStep2025 value, $Res Function(PitAutoStep2025) then) =
      _$PitAutoStep2025CopyWithImpl<$Res, PitAutoStep2025>;
  @useResult
  $Res call({String name, Map<String, dynamic> extra_data});
}

/// @nodoc
class _$PitAutoStep2025CopyWithImpl<$Res, $Val extends PitAutoStep2025>
    implements $PitAutoStep2025CopyWith<$Res> {
  _$PitAutoStep2025CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PitAutoStep2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? extra_data = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      extra_data: null == extra_data
          ? _value.extra_data
          : extra_data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PitAutoStep2025ImplCopyWith<$Res>
    implements $PitAutoStep2025CopyWith<$Res> {
  factory _$$PitAutoStep2025ImplCopyWith(_$PitAutoStep2025Impl value,
          $Res Function(_$PitAutoStep2025Impl) then) =
      __$$PitAutoStep2025ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, Map<String, dynamic> extra_data});
}

/// @nodoc
class __$$PitAutoStep2025ImplCopyWithImpl<$Res>
    extends _$PitAutoStep2025CopyWithImpl<$Res, _$PitAutoStep2025Impl>
    implements _$$PitAutoStep2025ImplCopyWith<$Res> {
  __$$PitAutoStep2025ImplCopyWithImpl(
      _$PitAutoStep2025Impl _value, $Res Function(_$PitAutoStep2025Impl) _then)
      : super(_value, _then);

  /// Create a copy of PitAutoStep2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? extra_data = null,
  }) {
    return _then(_$PitAutoStep2025Impl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      extra_data: null == extra_data
          ? _value._extra_data
          : extra_data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PitAutoStep2025Impl implements _PitAutoStep2025 {
  const _$PitAutoStep2025Impl(
      {required this.name, required final Map<String, dynamic> extra_data})
      : _extra_data = extra_data;

  factory _$PitAutoStep2025Impl.fromJson(Map<String, dynamic> json) =>
      _$$PitAutoStep2025ImplFromJson(json);

  @override
  final String name;
  final Map<String, dynamic> _extra_data;
  @override
  Map<String, dynamic> get extra_data {
    if (_extra_data is EqualUnmodifiableMapView) return _extra_data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_extra_data);
  }

  @override
  String toString() {
    return 'PitAutoStep2025(name: $name, extra_data: $extra_data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PitAutoStep2025Impl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._extra_data, _extra_data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(_extra_data));

  /// Create a copy of PitAutoStep2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PitAutoStep2025ImplCopyWith<_$PitAutoStep2025Impl> get copyWith =>
      __$$PitAutoStep2025ImplCopyWithImpl<_$PitAutoStep2025Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PitAutoStep2025ImplToJson(
      this,
    );
  }
}

abstract class _PitAutoStep2025 implements PitAutoStep2025 {
  const factory _PitAutoStep2025(
      {required final String name,
      required final Map<String, dynamic> extra_data}) = _$PitAutoStep2025Impl;

  factory _PitAutoStep2025.fromJson(Map<String, dynamic> json) =
      _$PitAutoStep2025Impl.fromJson;

  @override
  String get name;
  @override
  Map<String, dynamic> get extra_data;

  /// Create a copy of PitAutoStep2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PitAutoStep2025ImplCopyWith<_$PitAutoStep2025Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
