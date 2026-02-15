// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pit_scouting_2026.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PitScouting2026 _$PitScouting2026FromJson(Map<String, dynamic> json) {
  return _PitScouting2026.fromJson(json);
}

/// @nodoc
mixin _$PitScouting2026 {
  String get user_id => throw _privateConstructorUsedError;
  ScoutInfo get scout_info => throw _privateConstructorUsedError;
  int get team_number => throw _privateConstructorUsedError;
  String get event_code => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  PitData2026 get data => throw _privateConstructorUsedError;
  Auto2026? get auto => throw _privateConstructorUsedError;

  /// Serializes this PitScouting2026 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PitScouting2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PitScouting2026CopyWith<PitScouting2026> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PitScouting2026CopyWith<$Res> {
  factory $PitScouting2026CopyWith(
          PitScouting2026 value, $Res Function(PitScouting2026) then) =
      _$PitScouting2026CopyWithImpl<$Res, PitScouting2026>;
  @useResult
  $Res call(
      {String user_id,
      ScoutInfo scout_info,
      int team_number,
      String event_code,
      int time,
      PitData2026 data,
      Auto2026? auto});

  $ScoutInfoCopyWith<$Res> get scout_info;
  $PitData2026CopyWith<$Res> get data;
  $Auto2026CopyWith<$Res>? get auto;
}

/// @nodoc
class _$PitScouting2026CopyWithImpl<$Res, $Val extends PitScouting2026>
    implements $PitScouting2026CopyWith<$Res> {
  _$PitScouting2026CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PitScouting2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? scout_info = null,
    Object? team_number = null,
    Object? event_code = null,
    Object? time = null,
    Object? data = null,
    Object? auto = freezed,
  }) {
    return _then(_value.copyWith(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      scout_info: null == scout_info
          ? _value.scout_info
          : scout_info // ignore: cast_nullable_to_non_nullable
              as ScoutInfo,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PitData2026,
      auto: freezed == auto
          ? _value.auto
          : auto // ignore: cast_nullable_to_non_nullable
              as Auto2026?,
    ) as $Val);
  }

  /// Create a copy of PitScouting2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoutInfoCopyWith<$Res> get scout_info {
    return $ScoutInfoCopyWith<$Res>(_value.scout_info, (value) {
      return _then(_value.copyWith(scout_info: value) as $Val);
    });
  }

  /// Create a copy of PitScouting2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PitData2026CopyWith<$Res> get data {
    return $PitData2026CopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }

  /// Create a copy of PitScouting2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Auto2026CopyWith<$Res>? get auto {
    if (_value.auto == null) {
      return null;
    }

    return $Auto2026CopyWith<$Res>(_value.auto!, (value) {
      return _then(_value.copyWith(auto: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PitScouting2026ImplCopyWith<$Res>
    implements $PitScouting2026CopyWith<$Res> {
  factory _$$PitScouting2026ImplCopyWith(_$PitScouting2026Impl value,
          $Res Function(_$PitScouting2026Impl) then) =
      __$$PitScouting2026ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String user_id,
      ScoutInfo scout_info,
      int team_number,
      String event_code,
      int time,
      PitData2026 data,
      Auto2026? auto});

  @override
  $ScoutInfoCopyWith<$Res> get scout_info;
  @override
  $PitData2026CopyWith<$Res> get data;
  @override
  $Auto2026CopyWith<$Res>? get auto;
}

/// @nodoc
class __$$PitScouting2026ImplCopyWithImpl<$Res>
    extends _$PitScouting2026CopyWithImpl<$Res, _$PitScouting2026Impl>
    implements _$$PitScouting2026ImplCopyWith<$Res> {
  __$$PitScouting2026ImplCopyWithImpl(
      _$PitScouting2026Impl _value, $Res Function(_$PitScouting2026Impl) _then)
      : super(_value, _then);

  /// Create a copy of PitScouting2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? scout_info = null,
    Object? team_number = null,
    Object? event_code = null,
    Object? time = null,
    Object? data = null,
    Object? auto = freezed,
  }) {
    return _then(_$PitScouting2026Impl(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      scout_info: null == scout_info
          ? _value.scout_info
          : scout_info // ignore: cast_nullable_to_non_nullable
              as ScoutInfo,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as PitData2026,
      auto: freezed == auto
          ? _value.auto
          : auto // ignore: cast_nullable_to_non_nullable
              as Auto2026?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PitScouting2026Impl implements _PitScouting2026 {
  const _$PitScouting2026Impl(
      {required this.user_id,
      required this.scout_info,
      required this.team_number,
      required this.event_code,
      required this.time,
      required this.data,
      this.auto});

  factory _$PitScouting2026Impl.fromJson(Map<String, dynamic> json) =>
      _$$PitScouting2026ImplFromJson(json);

  @override
  final String user_id;
  @override
  final ScoutInfo scout_info;
  @override
  final int team_number;
  @override
  final String event_code;
  @override
  final int time;
  @override
  final PitData2026 data;
  @override
  final Auto2026? auto;

  @override
  String toString() {
    return 'PitScouting2026(user_id: $user_id, scout_info: $scout_info, team_number: $team_number, event_code: $event_code, time: $time, data: $data, auto: $auto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PitScouting2026Impl &&
            (identical(other.user_id, user_id) || other.user_id == user_id) &&
            (identical(other.scout_info, scout_info) ||
                other.scout_info == scout_info) &&
            (identical(other.team_number, team_number) ||
                other.team_number == team_number) &&
            (identical(other.event_code, event_code) ||
                other.event_code == event_code) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.auto, auto) || other.auto == auto));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, user_id, scout_info, team_number,
      event_code, time, data, auto);

  /// Create a copy of PitScouting2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PitScouting2026ImplCopyWith<_$PitScouting2026Impl> get copyWith =>
      __$$PitScouting2026ImplCopyWithImpl<_$PitScouting2026Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PitScouting2026ImplToJson(
      this,
    );
  }
}

abstract class _PitScouting2026 implements PitScouting2026 {
  const factory _PitScouting2026(
      {required final String user_id,
      required final ScoutInfo scout_info,
      required final int team_number,
      required final String event_code,
      required final int time,
      required final PitData2026 data,
      final Auto2026? auto}) = _$PitScouting2026Impl;

  factory _PitScouting2026.fromJson(Map<String, dynamic> json) =
      _$PitScouting2026Impl.fromJson;

  @override
  String get user_id;
  @override
  ScoutInfo get scout_info;
  @override
  int get team_number;
  @override
  String get event_code;
  @override
  int get time;
  @override
  PitData2026 get data;
  @override
  Auto2026? get auto;

  /// Create a copy of PitScouting2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PitScouting2026ImplCopyWith<_$PitScouting2026Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

PitData2026 _$PitData2026FromJson(Map<String, dynamic> json) {
  return _PitData2026.fromJson(json);
}

/// @nodoc
mixin _$PitData2026 {
  int get driver_experience_events => throw _privateConstructorUsedError;
  String get drive_train => throw _privateConstructorUsedError;
  bool get can_feed_human_player => throw _privateConstructorUsedError;
  bool get can_pick_up_from_ground => throw _privateConstructorUsedError;
  int get distance_to_shoot => throw _privateConstructorUsedError;
  int get cycles_in_25_seconds => throw _privateConstructorUsedError;
  int get cycle_time => throw _privateConstructorUsedError;
  bool get go_over_bump => throw _privateConstructorUsedError;
  bool get go_under_trench => throw _privateConstructorUsedError;
  bool get can_climb => throw _privateConstructorUsedError;
  List<int> get climbing => throw _privateConstructorUsedError;
  bool get can_climb_in_autonomous => throw _privateConstructorUsedError;
  bool get can_climb_with_others => throw _privateConstructorUsedError;
  bool get automatically_shooting => throw _privateConstructorUsedError;
  bool get shooting_while_moving => throw _privateConstructorUsedError;
  String get main_strategy => throw _privateConstructorUsedError;
  int get spare_parts => throw _privateConstructorUsedError;
  String get favorite_color => throw _privateConstructorUsedError;
  Auto2026? get auto => throw _privateConstructorUsedError;
  AutoScoring get auto_scoring =>
      throw _privateConstructorUsedError; // keep autos dynamic to avoid type-mismatch with other code/widgets
  List<dynamic> get autos => throw _privateConstructorUsedError;

  /// Serializes this PitData2026 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PitData2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PitData2026CopyWith<PitData2026> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PitData2026CopyWith<$Res> {
  factory $PitData2026CopyWith(
          PitData2026 value, $Res Function(PitData2026) then) =
      _$PitData2026CopyWithImpl<$Res, PitData2026>;
  @useResult
  $Res call(
      {int driver_experience_events,
      String drive_train,
      bool can_feed_human_player,
      bool can_pick_up_from_ground,
      int distance_to_shoot,
      int cycles_in_25_seconds,
      int cycle_time,
      bool go_over_bump,
      bool go_under_trench,
      bool can_climb,
      List<int> climbing,
      bool can_climb_in_autonomous,
      bool can_climb_with_others,
      bool automatically_shooting,
      bool shooting_while_moving,
      String main_strategy,
      int spare_parts,
      String favorite_color,
      Auto2026? auto,
      AutoScoring auto_scoring,
      List<dynamic> autos});

  $Auto2026CopyWith<$Res>? get auto;
  $AutoScoringCopyWith<$Res> get auto_scoring;
}

/// @nodoc
class _$PitData2026CopyWithImpl<$Res, $Val extends PitData2026>
    implements $PitData2026CopyWith<$Res> {
  _$PitData2026CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PitData2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driver_experience_events = null,
    Object? drive_train = null,
    Object? can_feed_human_player = null,
    Object? can_pick_up_from_ground = null,
    Object? distance_to_shoot = null,
    Object? cycles_in_25_seconds = null,
    Object? cycle_time = null,
    Object? go_over_bump = null,
    Object? go_under_trench = null,
    Object? can_climb = null,
    Object? climbing = null,
    Object? can_climb_in_autonomous = null,
    Object? can_climb_with_others = null,
    Object? automatically_shooting = null,
    Object? shooting_while_moving = null,
    Object? main_strategy = null,
    Object? spare_parts = null,
    Object? favorite_color = null,
    Object? auto = freezed,
    Object? auto_scoring = null,
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
      can_feed_human_player: null == can_feed_human_player
          ? _value.can_feed_human_player
          : can_feed_human_player // ignore: cast_nullable_to_non_nullable
              as bool,
      can_pick_up_from_ground: null == can_pick_up_from_ground
          ? _value.can_pick_up_from_ground
          : can_pick_up_from_ground // ignore: cast_nullable_to_non_nullable
              as bool,
      distance_to_shoot: null == distance_to_shoot
          ? _value.distance_to_shoot
          : distance_to_shoot // ignore: cast_nullable_to_non_nullable
              as int,
      cycles_in_25_seconds: null == cycles_in_25_seconds
          ? _value.cycles_in_25_seconds
          : cycles_in_25_seconds // ignore: cast_nullable_to_non_nullable
              as int,
      cycle_time: null == cycle_time
          ? _value.cycle_time
          : cycle_time // ignore: cast_nullable_to_non_nullable
              as int,
      go_over_bump: null == go_over_bump
          ? _value.go_over_bump
          : go_over_bump // ignore: cast_nullable_to_non_nullable
              as bool,
      go_under_trench: null == go_under_trench
          ? _value.go_under_trench
          : go_under_trench // ignore: cast_nullable_to_non_nullable
              as bool,
      can_climb: null == can_climb
          ? _value.can_climb
          : can_climb // ignore: cast_nullable_to_non_nullable
              as bool,
      climbing: null == climbing
          ? _value.climbing
          : climbing // ignore: cast_nullable_to_non_nullable
              as List<int>,
      can_climb_in_autonomous: null == can_climb_in_autonomous
          ? _value.can_climb_in_autonomous
          : can_climb_in_autonomous // ignore: cast_nullable_to_non_nullable
              as bool,
      can_climb_with_others: null == can_climb_with_others
          ? _value.can_climb_with_others
          : can_climb_with_others // ignore: cast_nullable_to_non_nullable
              as bool,
      automatically_shooting: null == automatically_shooting
          ? _value.automatically_shooting
          : automatically_shooting // ignore: cast_nullable_to_non_nullable
              as bool,
      shooting_while_moving: null == shooting_while_moving
          ? _value.shooting_while_moving
          : shooting_while_moving // ignore: cast_nullable_to_non_nullable
              as bool,
      main_strategy: null == main_strategy
          ? _value.main_strategy
          : main_strategy // ignore: cast_nullable_to_non_nullable
              as String,
      spare_parts: null == spare_parts
          ? _value.spare_parts
          : spare_parts // ignore: cast_nullable_to_non_nullable
              as int,
      favorite_color: null == favorite_color
          ? _value.favorite_color
          : favorite_color // ignore: cast_nullable_to_non_nullable
              as String,
      auto: freezed == auto
          ? _value.auto
          : auto // ignore: cast_nullable_to_non_nullable
              as Auto2026?,
      auto_scoring: null == auto_scoring
          ? _value.auto_scoring
          : auto_scoring // ignore: cast_nullable_to_non_nullable
              as AutoScoring,
      autos: null == autos
          ? _value.autos
          : autos // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ) as $Val);
  }

  /// Create a copy of PitData2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Auto2026CopyWith<$Res>? get auto {
    if (_value.auto == null) {
      return null;
    }

    return $Auto2026CopyWith<$Res>(_value.auto!, (value) {
      return _then(_value.copyWith(auto: value) as $Val);
    });
  }

  /// Create a copy of PitData2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AutoScoringCopyWith<$Res> get auto_scoring {
    return $AutoScoringCopyWith<$Res>(_value.auto_scoring, (value) {
      return _then(_value.copyWith(auto_scoring: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PitData2026ImplCopyWith<$Res>
    implements $PitData2026CopyWith<$Res> {
  factory _$$PitData2026ImplCopyWith(
          _$PitData2026Impl value, $Res Function(_$PitData2026Impl) then) =
      __$$PitData2026ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int driver_experience_events,
      String drive_train,
      bool can_feed_human_player,
      bool can_pick_up_from_ground,
      int distance_to_shoot,
      int cycles_in_25_seconds,
      int cycle_time,
      bool go_over_bump,
      bool go_under_trench,
      bool can_climb,
      List<int> climbing,
      bool can_climb_in_autonomous,
      bool can_climb_with_others,
      bool automatically_shooting,
      bool shooting_while_moving,
      String main_strategy,
      int spare_parts,
      String favorite_color,
      Auto2026? auto,
      AutoScoring auto_scoring,
      List<dynamic> autos});

  @override
  $Auto2026CopyWith<$Res>? get auto;
  @override
  $AutoScoringCopyWith<$Res> get auto_scoring;
}

/// @nodoc
class __$$PitData2026ImplCopyWithImpl<$Res>
    extends _$PitData2026CopyWithImpl<$Res, _$PitData2026Impl>
    implements _$$PitData2026ImplCopyWith<$Res> {
  __$$PitData2026ImplCopyWithImpl(
      _$PitData2026Impl _value, $Res Function(_$PitData2026Impl) _then)
      : super(_value, _then);

  /// Create a copy of PitData2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? driver_experience_events = null,
    Object? drive_train = null,
    Object? can_feed_human_player = null,
    Object? can_pick_up_from_ground = null,
    Object? distance_to_shoot = null,
    Object? cycles_in_25_seconds = null,
    Object? cycle_time = null,
    Object? go_over_bump = null,
    Object? go_under_trench = null,
    Object? can_climb = null,
    Object? climbing = null,
    Object? can_climb_in_autonomous = null,
    Object? can_climb_with_others = null,
    Object? automatically_shooting = null,
    Object? shooting_while_moving = null,
    Object? main_strategy = null,
    Object? spare_parts = null,
    Object? favorite_color = null,
    Object? auto = freezed,
    Object? auto_scoring = null,
    Object? autos = null,
  }) {
    return _then(_$PitData2026Impl(
      driver_experience_events: null == driver_experience_events
          ? _value.driver_experience_events
          : driver_experience_events // ignore: cast_nullable_to_non_nullable
              as int,
      drive_train: null == drive_train
          ? _value.drive_train
          : drive_train // ignore: cast_nullable_to_non_nullable
              as String,
      can_feed_human_player: null == can_feed_human_player
          ? _value.can_feed_human_player
          : can_feed_human_player // ignore: cast_nullable_to_non_nullable
              as bool,
      can_pick_up_from_ground: null == can_pick_up_from_ground
          ? _value.can_pick_up_from_ground
          : can_pick_up_from_ground // ignore: cast_nullable_to_non_nullable
              as bool,
      distance_to_shoot: null == distance_to_shoot
          ? _value.distance_to_shoot
          : distance_to_shoot // ignore: cast_nullable_to_non_nullable
              as int,
      cycles_in_25_seconds: null == cycles_in_25_seconds
          ? _value.cycles_in_25_seconds
          : cycles_in_25_seconds // ignore: cast_nullable_to_non_nullable
              as int,
      cycle_time: null == cycle_time
          ? _value.cycle_time
          : cycle_time // ignore: cast_nullable_to_non_nullable
              as int,
      go_over_bump: null == go_over_bump
          ? _value.go_over_bump
          : go_over_bump // ignore: cast_nullable_to_non_nullable
              as bool,
      go_under_trench: null == go_under_trench
          ? _value.go_under_trench
          : go_under_trench // ignore: cast_nullable_to_non_nullable
              as bool,
      can_climb: null == can_climb
          ? _value.can_climb
          : can_climb // ignore: cast_nullable_to_non_nullable
              as bool,
      climbing: null == climbing
          ? _value._climbing
          : climbing // ignore: cast_nullable_to_non_nullable
              as List<int>,
      can_climb_in_autonomous: null == can_climb_in_autonomous
          ? _value.can_climb_in_autonomous
          : can_climb_in_autonomous // ignore: cast_nullable_to_non_nullable
              as bool,
      can_climb_with_others: null == can_climb_with_others
          ? _value.can_climb_with_others
          : can_climb_with_others // ignore: cast_nullable_to_non_nullable
              as bool,
      automatically_shooting: null == automatically_shooting
          ? _value.automatically_shooting
          : automatically_shooting // ignore: cast_nullable_to_non_nullable
              as bool,
      shooting_while_moving: null == shooting_while_moving
          ? _value.shooting_while_moving
          : shooting_while_moving // ignore: cast_nullable_to_non_nullable
              as bool,
      main_strategy: null == main_strategy
          ? _value.main_strategy
          : main_strategy // ignore: cast_nullable_to_non_nullable
              as String,
      spare_parts: null == spare_parts
          ? _value.spare_parts
          : spare_parts // ignore: cast_nullable_to_non_nullable
              as int,
      favorite_color: null == favorite_color
          ? _value.favorite_color
          : favorite_color // ignore: cast_nullable_to_non_nullable
              as String,
      auto: freezed == auto
          ? _value.auto
          : auto // ignore: cast_nullable_to_non_nullable
              as Auto2026?,
      auto_scoring: null == auto_scoring
          ? _value.auto_scoring
          : auto_scoring // ignore: cast_nullable_to_non_nullable
              as AutoScoring,
      autos: null == autos
          ? _value._autos
          : autos // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PitData2026Impl implements _PitData2026 {
  const _$PitData2026Impl(
      {required this.driver_experience_events,
      required this.drive_train,
      required this.can_feed_human_player,
      required this.can_pick_up_from_ground,
      required this.distance_to_shoot,
      required this.cycles_in_25_seconds,
      required this.cycle_time,
      required this.go_over_bump,
      required this.go_under_trench,
      required this.can_climb,
      required final List<int> climbing,
      required this.can_climb_in_autonomous,
      required this.can_climb_with_others,
      required this.automatically_shooting,
      required this.shooting_while_moving,
      required this.main_strategy,
      required this.spare_parts,
      required this.favorite_color,
      this.auto,
      required this.auto_scoring,
      required final List<dynamic> autos})
      : _climbing = climbing,
        _autos = autos;

  factory _$PitData2026Impl.fromJson(Map<String, dynamic> json) =>
      _$$PitData2026ImplFromJson(json);

  @override
  final int driver_experience_events;
  @override
  final String drive_train;
  @override
  final bool can_feed_human_player;
  @override
  final bool can_pick_up_from_ground;
  @override
  final int distance_to_shoot;
  @override
  final int cycles_in_25_seconds;
  @override
  final int cycle_time;
  @override
  final bool go_over_bump;
  @override
  final bool go_under_trench;
  @override
  final bool can_climb;
  final List<int> _climbing;
  @override
  List<int> get climbing {
    if (_climbing is EqualUnmodifiableListView) return _climbing;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_climbing);
  }

  @override
  final bool can_climb_in_autonomous;
  @override
  final bool can_climb_with_others;
  @override
  final bool automatically_shooting;
  @override
  final bool shooting_while_moving;
  @override
  final String main_strategy;
  @override
  final int spare_parts;
  @override
  final String favorite_color;
  @override
  final Auto2026? auto;
  @override
  final AutoScoring auto_scoring;
// keep autos dynamic to avoid type-mismatch with other code/widgets
  final List<dynamic> _autos;
// keep autos dynamic to avoid type-mismatch with other code/widgets
  @override
  List<dynamic> get autos {
    if (_autos is EqualUnmodifiableListView) return _autos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_autos);
  }

  @override
  String toString() {
    return 'PitData2026(driver_experience_events: $driver_experience_events, drive_train: $drive_train, can_feed_human_player: $can_feed_human_player, can_pick_up_from_ground: $can_pick_up_from_ground, distance_to_shoot: $distance_to_shoot, cycles_in_25_seconds: $cycles_in_25_seconds, cycle_time: $cycle_time, go_over_bump: $go_over_bump, go_under_trench: $go_under_trench, can_climb: $can_climb, climbing: $climbing, can_climb_in_autonomous: $can_climb_in_autonomous, can_climb_with_others: $can_climb_with_others, automatically_shooting: $automatically_shooting, shooting_while_moving: $shooting_while_moving, main_strategy: $main_strategy, spare_parts: $spare_parts, favorite_color: $favorite_color, auto: $auto, auto_scoring: $auto_scoring, autos: $autos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PitData2026Impl &&
            (identical(
                    other.driver_experience_events, driver_experience_events) ||
                other.driver_experience_events == driver_experience_events) &&
            (identical(other.drive_train, drive_train) ||
                other.drive_train == drive_train) &&
            (identical(other.can_feed_human_player, can_feed_human_player) ||
                other.can_feed_human_player == can_feed_human_player) &&
            (identical(
                    other.can_pick_up_from_ground, can_pick_up_from_ground) ||
                other.can_pick_up_from_ground == can_pick_up_from_ground) &&
            (identical(other.distance_to_shoot, distance_to_shoot) ||
                other.distance_to_shoot == distance_to_shoot) &&
            (identical(other.cycles_in_25_seconds, cycles_in_25_seconds) ||
                other.cycles_in_25_seconds == cycles_in_25_seconds) &&
            (identical(other.cycle_time, cycle_time) ||
                other.cycle_time == cycle_time) &&
            (identical(other.go_over_bump, go_over_bump) ||
                other.go_over_bump == go_over_bump) &&
            (identical(other.go_under_trench, go_under_trench) ||
                other.go_under_trench == go_under_trench) &&
            (identical(other.can_climb, can_climb) ||
                other.can_climb == can_climb) &&
            const DeepCollectionEquality().equals(other._climbing, _climbing) &&
            (identical(
                    other.can_climb_in_autonomous, can_climb_in_autonomous) ||
                other.can_climb_in_autonomous == can_climb_in_autonomous) &&
            (identical(other.can_climb_with_others, can_climb_with_others) ||
                other.can_climb_with_others == can_climb_with_others) &&
            (identical(other.automatically_shooting, automatically_shooting) ||
                other.automatically_shooting == automatically_shooting) &&
            (identical(other.shooting_while_moving, shooting_while_moving) ||
                other.shooting_while_moving == shooting_while_moving) &&
            (identical(other.main_strategy, main_strategy) ||
                other.main_strategy == main_strategy) &&
            (identical(other.spare_parts, spare_parts) ||
                other.spare_parts == spare_parts) &&
            (identical(other.favorite_color, favorite_color) ||
                other.favorite_color == favorite_color) &&
            (identical(other.auto, auto) || other.auto == auto) &&
            (identical(other.auto_scoring, auto_scoring) ||
                other.auto_scoring == auto_scoring) &&
            const DeepCollectionEquality().equals(other._autos, _autos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        driver_experience_events,
        drive_train,
        can_feed_human_player,
        can_pick_up_from_ground,
        distance_to_shoot,
        cycles_in_25_seconds,
        cycle_time,
        go_over_bump,
        go_under_trench,
        can_climb,
        const DeepCollectionEquality().hash(_climbing),
        can_climb_in_autonomous,
        can_climb_with_others,
        automatically_shooting,
        shooting_while_moving,
        main_strategy,
        spare_parts,
        favorite_color,
        auto,
        auto_scoring,
        const DeepCollectionEquality().hash(_autos)
      ]);

  /// Create a copy of PitData2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PitData2026ImplCopyWith<_$PitData2026Impl> get copyWith =>
      __$$PitData2026ImplCopyWithImpl<_$PitData2026Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PitData2026ImplToJson(
      this,
    );
  }
}

abstract class _PitData2026 implements PitData2026 {
  const factory _PitData2026(
      {required final int driver_experience_events,
      required final String drive_train,
      required final bool can_feed_human_player,
      required final bool can_pick_up_from_ground,
      required final int distance_to_shoot,
      required final int cycles_in_25_seconds,
      required final int cycle_time,
      required final bool go_over_bump,
      required final bool go_under_trench,
      required final bool can_climb,
      required final List<int> climbing,
      required final bool can_climb_in_autonomous,
      required final bool can_climb_with_others,
      required final bool automatically_shooting,
      required final bool shooting_while_moving,
      required final String main_strategy,
      required final int spare_parts,
      required final String favorite_color,
      final Auto2026? auto,
      required final AutoScoring auto_scoring,
      required final List<dynamic> autos}) = _$PitData2026Impl;

  factory _PitData2026.fromJson(Map<String, dynamic> json) =
      _$PitData2026Impl.fromJson;

  @override
  int get driver_experience_events;
  @override
  String get drive_train;
  @override
  bool get can_feed_human_player;
  @override
  bool get can_pick_up_from_ground;
  @override
  int get distance_to_shoot;
  @override
  int get cycles_in_25_seconds;
  @override
  int get cycle_time;
  @override
  bool get go_over_bump;
  @override
  bool get go_under_trench;
  @override
  bool get can_climb;
  @override
  List<int> get climbing;
  @override
  bool get can_climb_in_autonomous;
  @override
  bool get can_climb_with_others;
  @override
  bool get automatically_shooting;
  @override
  bool get shooting_while_moving;
  @override
  String get main_strategy;
  @override
  int get spare_parts;
  @override
  String get favorite_color;
  @override
  Auto2026? get auto;
  @override
  AutoScoring
      get auto_scoring; // keep autos dynamic to avoid type-mismatch with other code/widgets
  @override
  List<dynamic> get autos;

  /// Create a copy of PitData2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PitData2026ImplCopyWith<_$PitData2026Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

Auto2026 _$Auto2026FromJson(Map<String, dynamic> json) {
  return _Auto2026.fromJson(json);
}

/// @nodoc
mixin _$Auto2026 {
  double get starting_position_meters_from_hub_center =>
      throw _privateConstructorUsedError;
  List<dynamic> get steps => throw _privateConstructorUsedError;
  List<String> get field_side => throw _privateConstructorUsedError;
  bool get preload => throw _privateConstructorUsedError;
  bool get climb => throw _privateConstructorUsedError;
  bool get contacts_robot => throw _privateConstructorUsedError;
  bool get both_sides => throw _privateConstructorUsedError;
  @JsonKey(name: 'auto_pieces')
  int get autoPieces =>
      throw _privateConstructorUsedError; // <-- NEW COUNTER FIELD
  @JsonKey(name: 'fuel_shots_in_auto')
  int get fuelShotsInAuto =>
      throw _privateConstructorUsedError; // NEW: fuel shots
  @JsonKey(name: 'intaked_amount_in_auto')
  int get intakedAmountInAuto => throw _privateConstructorUsedError;

  /// Serializes this Auto2026 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Auto2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $Auto2026CopyWith<Auto2026> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $Auto2026CopyWith<$Res> {
  factory $Auto2026CopyWith(Auto2026 value, $Res Function(Auto2026) then) =
      _$Auto2026CopyWithImpl<$Res, Auto2026>;
  @useResult
  $Res call(
      {double starting_position_meters_from_hub_center,
      List<dynamic> steps,
      List<String> field_side,
      bool preload,
      bool climb,
      bool contacts_robot,
      bool both_sides,
      @JsonKey(name: 'auto_pieces') int autoPieces,
      @JsonKey(name: 'fuel_shots_in_auto') int fuelShotsInAuto,
      @JsonKey(name: 'intaked_amount_in_auto') int intakedAmountInAuto});
}

/// @nodoc
class _$Auto2026CopyWithImpl<$Res, $Val extends Auto2026>
    implements $Auto2026CopyWith<$Res> {
  _$Auto2026CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Auto2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? starting_position_meters_from_hub_center = null,
    Object? steps = null,
    Object? field_side = null,
    Object? preload = null,
    Object? climb = null,
    Object? contacts_robot = null,
    Object? both_sides = null,
    Object? autoPieces = null,
    Object? fuelShotsInAuto = null,
    Object? intakedAmountInAuto = null,
  }) {
    return _then(_value.copyWith(
      starting_position_meters_from_hub_center: null ==
              starting_position_meters_from_hub_center
          ? _value.starting_position_meters_from_hub_center
          : starting_position_meters_from_hub_center // ignore: cast_nullable_to_non_nullable
              as double,
      steps: null == steps
          ? _value.steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      field_side: null == field_side
          ? _value.field_side
          : field_side // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preload: null == preload
          ? _value.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as bool,
      climb: null == climb
          ? _value.climb
          : climb // ignore: cast_nullable_to_non_nullable
              as bool,
      contacts_robot: null == contacts_robot
          ? _value.contacts_robot
          : contacts_robot // ignore: cast_nullable_to_non_nullable
              as bool,
      both_sides: null == both_sides
          ? _value.both_sides
          : both_sides // ignore: cast_nullable_to_non_nullable
              as bool,
      autoPieces: null == autoPieces
          ? _value.autoPieces
          : autoPieces // ignore: cast_nullable_to_non_nullable
              as int,
      fuelShotsInAuto: null == fuelShotsInAuto
          ? _value.fuelShotsInAuto
          : fuelShotsInAuto // ignore: cast_nullable_to_non_nullable
              as int,
      intakedAmountInAuto: null == intakedAmountInAuto
          ? _value.intakedAmountInAuto
          : intakedAmountInAuto // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$Auto2026ImplCopyWith<$Res>
    implements $Auto2026CopyWith<$Res> {
  factory _$$Auto2026ImplCopyWith(
          _$Auto2026Impl value, $Res Function(_$Auto2026Impl) then) =
      __$$Auto2026ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double starting_position_meters_from_hub_center,
      List<dynamic> steps,
      List<String> field_side,
      bool preload,
      bool climb,
      bool contacts_robot,
      bool both_sides,
      @JsonKey(name: 'auto_pieces') int autoPieces,
      @JsonKey(name: 'fuel_shots_in_auto') int fuelShotsInAuto,
      @JsonKey(name: 'intaked_amount_in_auto') int intakedAmountInAuto});
}

/// @nodoc
class __$$Auto2026ImplCopyWithImpl<$Res>
    extends _$Auto2026CopyWithImpl<$Res, _$Auto2026Impl>
    implements _$$Auto2026ImplCopyWith<$Res> {
  __$$Auto2026ImplCopyWithImpl(
      _$Auto2026Impl _value, $Res Function(_$Auto2026Impl) _then)
      : super(_value, _then);

  /// Create a copy of Auto2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? starting_position_meters_from_hub_center = null,
    Object? steps = null,
    Object? field_side = null,
    Object? preload = null,
    Object? climb = null,
    Object? contacts_robot = null,
    Object? both_sides = null,
    Object? autoPieces = null,
    Object? fuelShotsInAuto = null,
    Object? intakedAmountInAuto = null,
  }) {
    return _then(_$Auto2026Impl(
      starting_position_meters_from_hub_center: null ==
              starting_position_meters_from_hub_center
          ? _value.starting_position_meters_from_hub_center
          : starting_position_meters_from_hub_center // ignore: cast_nullable_to_non_nullable
              as double,
      steps: null == steps
          ? _value._steps
          : steps // ignore: cast_nullable_to_non_nullable
              as List<dynamic>,
      field_side: null == field_side
          ? _value._field_side
          : field_side // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preload: null == preload
          ? _value.preload
          : preload // ignore: cast_nullable_to_non_nullable
              as bool,
      climb: null == climb
          ? _value.climb
          : climb // ignore: cast_nullable_to_non_nullable
              as bool,
      contacts_robot: null == contacts_robot
          ? _value.contacts_robot
          : contacts_robot // ignore: cast_nullable_to_non_nullable
              as bool,
      both_sides: null == both_sides
          ? _value.both_sides
          : both_sides // ignore: cast_nullable_to_non_nullable
              as bool,
      autoPieces: null == autoPieces
          ? _value.autoPieces
          : autoPieces // ignore: cast_nullable_to_non_nullable
              as int,
      fuelShotsInAuto: null == fuelShotsInAuto
          ? _value.fuelShotsInAuto
          : fuelShotsInAuto // ignore: cast_nullable_to_non_nullable
              as int,
      intakedAmountInAuto: null == intakedAmountInAuto
          ? _value.intakedAmountInAuto
          : intakedAmountInAuto // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$Auto2026Impl implements _Auto2026 {
  _$Auto2026Impl(
      {required this.starting_position_meters_from_hub_center,
      required final List<dynamic> steps,
      required final List<String> field_side,
      required this.preload,
      required this.climb,
      required this.contacts_robot,
      this.both_sides = false,
      @JsonKey(name: 'auto_pieces') this.autoPieces = 0,
      @JsonKey(name: 'fuel_shots_in_auto') this.fuelShotsInAuto = 0,
      @JsonKey(name: 'intaked_amount_in_auto') this.intakedAmountInAuto = 0})
      : _steps = steps,
        _field_side = field_side;

  factory _$Auto2026Impl.fromJson(Map<String, dynamic> json) =>
      _$$Auto2026ImplFromJson(json);

  @override
  final double starting_position_meters_from_hub_center;
  final List<dynamic> _steps;
  @override
  List<dynamic> get steps {
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
  final bool preload;
  @override
  final bool climb;
  @override
  final bool contacts_robot;
  @override
  @JsonKey()
  final bool both_sides;
  @override
  @JsonKey(name: 'auto_pieces')
  final int autoPieces;
// <-- NEW COUNTER FIELD
  @override
  @JsonKey(name: 'fuel_shots_in_auto')
  final int fuelShotsInAuto;
// NEW: fuel shots
  @override
  @JsonKey(name: 'intaked_amount_in_auto')
  final int intakedAmountInAuto;

  @override
  String toString() {
    return 'Auto2026(starting_position_meters_from_hub_center: $starting_position_meters_from_hub_center, steps: $steps, field_side: $field_side, preload: $preload, climb: $climb, contacts_robot: $contacts_robot, both_sides: $both_sides, autoPieces: $autoPieces, fuelShotsInAuto: $fuelShotsInAuto, intakedAmountInAuto: $intakedAmountInAuto)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Auto2026Impl &&
            (identical(other.starting_position_meters_from_hub_center,
                    starting_position_meters_from_hub_center) ||
                other.starting_position_meters_from_hub_center ==
                    starting_position_meters_from_hub_center) &&
            const DeepCollectionEquality().equals(other._steps, _steps) &&
            const DeepCollectionEquality()
                .equals(other._field_side, _field_side) &&
            (identical(other.preload, preload) || other.preload == preload) &&
            (identical(other.climb, climb) || other.climb == climb) &&
            (identical(other.contacts_robot, contacts_robot) ||
                other.contacts_robot == contacts_robot) &&
            (identical(other.both_sides, both_sides) ||
                other.both_sides == both_sides) &&
            (identical(other.autoPieces, autoPieces) ||
                other.autoPieces == autoPieces) &&
            (identical(other.fuelShotsInAuto, fuelShotsInAuto) ||
                other.fuelShotsInAuto == fuelShotsInAuto) &&
            (identical(other.intakedAmountInAuto, intakedAmountInAuto) ||
                other.intakedAmountInAuto == intakedAmountInAuto));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      starting_position_meters_from_hub_center,
      const DeepCollectionEquality().hash(_steps),
      const DeepCollectionEquality().hash(_field_side),
      preload,
      climb,
      contacts_robot,
      both_sides,
      autoPieces,
      fuelShotsInAuto,
      intakedAmountInAuto);

  /// Create a copy of Auto2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Auto2026ImplCopyWith<_$Auto2026Impl> get copyWith =>
      __$$Auto2026ImplCopyWithImpl<_$Auto2026Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$Auto2026ImplToJson(
      this,
    );
  }
}

abstract class _Auto2026 implements Auto2026 {
  factory _Auto2026(
      {required final double starting_position_meters_from_hub_center,
      required final List<dynamic> steps,
      required final List<String> field_side,
      required final bool preload,
      required final bool climb,
      required final bool contacts_robot,
      final bool both_sides,
      @JsonKey(name: 'auto_pieces') final int autoPieces,
      @JsonKey(name: 'fuel_shots_in_auto') final int fuelShotsInAuto,
      @JsonKey(name: 'intaked_amount_in_auto')
      final int intakedAmountInAuto}) = _$Auto2026Impl;

  factory _Auto2026.fromJson(Map<String, dynamic> json) =
      _$Auto2026Impl.fromJson;

  @override
  double get starting_position_meters_from_hub_center;
  @override
  List<dynamic> get steps;
  @override
  List<String> get field_side;
  @override
  bool get preload;
  @override
  bool get climb;
  @override
  bool get contacts_robot;
  @override
  bool get both_sides;
  @override
  @JsonKey(name: 'auto_pieces')
  int get autoPieces; // <-- NEW COUNTER FIELD
  @override
  @JsonKey(name: 'fuel_shots_in_auto')
  int get fuelShotsInAuto; // NEW: fuel shots
  @override
  @JsonKey(name: 'intaked_amount_in_auto')
  int get intakedAmountInAuto;

  /// Create a copy of Auto2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Auto2026ImplCopyWith<_$Auto2026Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

AutoStep2026 _$AutoStep2026FromJson(Map<String, dynamic> json) {
  return _AutoStep2026.fromJson(json);
}

/// @nodoc
mixin _$AutoStep2026 {
  String get name => throw _privateConstructorUsedError;
  Map<String, dynamic> get extra_data => throw _privateConstructorUsedError;

  /// Serializes this AutoStep2026 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutoStep2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutoStep2026CopyWith<AutoStep2026> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoStep2026CopyWith<$Res> {
  factory $AutoStep2026CopyWith(
          AutoStep2026 value, $Res Function(AutoStep2026) then) =
      _$AutoStep2026CopyWithImpl<$Res, AutoStep2026>;
  @useResult
  $Res call({String name, Map<String, dynamic> extra_data});
}

/// @nodoc
class _$AutoStep2026CopyWithImpl<$Res, $Val extends AutoStep2026>
    implements $AutoStep2026CopyWith<$Res> {
  _$AutoStep2026CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutoStep2026
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
abstract class _$$AutoStep2026ImplCopyWith<$Res>
    implements $AutoStep2026CopyWith<$Res> {
  factory _$$AutoStep2026ImplCopyWith(
          _$AutoStep2026Impl value, $Res Function(_$AutoStep2026Impl) then) =
      __$$AutoStep2026ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, Map<String, dynamic> extra_data});
}

/// @nodoc
class __$$AutoStep2026ImplCopyWithImpl<$Res>
    extends _$AutoStep2026CopyWithImpl<$Res, _$AutoStep2026Impl>
    implements _$$AutoStep2026ImplCopyWith<$Res> {
  __$$AutoStep2026ImplCopyWithImpl(
      _$AutoStep2026Impl _value, $Res Function(_$AutoStep2026Impl) _then)
      : super(_value, _then);

  /// Create a copy of AutoStep2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? extra_data = null,
  }) {
    return _then(_$AutoStep2026Impl(
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
class _$AutoStep2026Impl implements _AutoStep2026 {
  const _$AutoStep2026Impl(
      {required this.name, required final Map<String, dynamic> extra_data})
      : _extra_data = extra_data;

  factory _$AutoStep2026Impl.fromJson(Map<String, dynamic> json) =>
      _$$AutoStep2026ImplFromJson(json);

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
    return 'AutoStep2026(name: $name, extra_data: $extra_data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoStep2026Impl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._extra_data, _extra_data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, name, const DeepCollectionEquality().hash(_extra_data));

  /// Create a copy of AutoStep2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoStep2026ImplCopyWith<_$AutoStep2026Impl> get copyWith =>
      __$$AutoStep2026ImplCopyWithImpl<_$AutoStep2026Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutoStep2026ImplToJson(
      this,
    );
  }
}

abstract class _AutoStep2026 implements AutoStep2026 {
  const factory _AutoStep2026(
      {required final String name,
      required final Map<String, dynamic> extra_data}) = _$AutoStep2026Impl;

  factory _AutoStep2026.fromJson(Map<String, dynamic> json) =
      _$AutoStep2026Impl.fromJson;

  @override
  String get name;
  @override
  Map<String, dynamic> get extra_data;

  /// Create a copy of AutoStep2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutoStep2026ImplCopyWith<_$AutoStep2026Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

Data _$DataFromJson(Map<String, dynamic> json) {
  return _Data.fromJson(json);
}

/// @nodoc
mixin _$Data {
  Auto2026 get auto => throw _privateConstructorUsedError;
  AutoScoring get auto_scoring => throw _privateConstructorUsedError;

  /// Serializes this Data to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DataCopyWith<Data> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DataCopyWith<$Res> {
  factory $DataCopyWith(Data value, $Res Function(Data) then) =
      _$DataCopyWithImpl<$Res, Data>;
  @useResult
  $Res call({Auto2026 auto, AutoScoring auto_scoring});

  $Auto2026CopyWith<$Res> get auto;
  $AutoScoringCopyWith<$Res> get auto_scoring;
}

/// @nodoc
class _$DataCopyWithImpl<$Res, $Val extends Data>
    implements $DataCopyWith<$Res> {
  _$DataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? auto = null,
    Object? auto_scoring = null,
  }) {
    return _then(_value.copyWith(
      auto: null == auto
          ? _value.auto
          : auto // ignore: cast_nullable_to_non_nullable
              as Auto2026,
      auto_scoring: null == auto_scoring
          ? _value.auto_scoring
          : auto_scoring // ignore: cast_nullable_to_non_nullable
              as AutoScoring,
    ) as $Val);
  }

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Auto2026CopyWith<$Res> get auto {
    return $Auto2026CopyWith<$Res>(_value.auto, (value) {
      return _then(_value.copyWith(auto: value) as $Val);
    });
  }

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AutoScoringCopyWith<$Res> get auto_scoring {
    return $AutoScoringCopyWith<$Res>(_value.auto_scoring, (value) {
      return _then(_value.copyWith(auto_scoring: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DataImplCopyWith<$Res> implements $DataCopyWith<$Res> {
  factory _$$DataImplCopyWith(
          _$DataImpl value, $Res Function(_$DataImpl) then) =
      __$$DataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Auto2026 auto, AutoScoring auto_scoring});

  @override
  $Auto2026CopyWith<$Res> get auto;
  @override
  $AutoScoringCopyWith<$Res> get auto_scoring;
}

/// @nodoc
class __$$DataImplCopyWithImpl<$Res>
    extends _$DataCopyWithImpl<$Res, _$DataImpl>
    implements _$$DataImplCopyWith<$Res> {
  __$$DataImplCopyWithImpl(_$DataImpl _value, $Res Function(_$DataImpl) _then)
      : super(_value, _then);

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? auto = null,
    Object? auto_scoring = null,
  }) {
    return _then(_$DataImpl(
      auto: null == auto
          ? _value.auto
          : auto // ignore: cast_nullable_to_non_nullable
              as Auto2026,
      auto_scoring: null == auto_scoring
          ? _value.auto_scoring
          : auto_scoring // ignore: cast_nullable_to_non_nullable
              as AutoScoring,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DataImpl implements _Data {
  _$DataImpl({required this.auto, required this.auto_scoring});

  factory _$DataImpl.fromJson(Map<String, dynamic> json) =>
      _$$DataImplFromJson(json);

  @override
  final Auto2026 auto;
  @override
  final AutoScoring auto_scoring;

  @override
  String toString() {
    return 'Data(auto: $auto, auto_scoring: $auto_scoring)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DataImpl &&
            (identical(other.auto, auto) || other.auto == auto) &&
            (identical(other.auto_scoring, auto_scoring) ||
                other.auto_scoring == auto_scoring));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, auto, auto_scoring);

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DataImplCopyWith<_$DataImpl> get copyWith =>
      __$$DataImplCopyWithImpl<_$DataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DataImplToJson(
      this,
    );
  }
}

abstract class _Data implements Data {
  factory _Data(
      {required final Auto2026 auto,
      required final AutoScoring auto_scoring}) = _$DataImpl;

  factory _Data.fromJson(Map<String, dynamic> json) = _$DataImpl.fromJson;

  @override
  Auto2026 get auto;
  @override
  AutoScoring get auto_scoring;

  /// Create a copy of Data
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DataImplCopyWith<_$DataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
