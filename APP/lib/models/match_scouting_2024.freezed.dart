// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_scouting_2024.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchScouting2024 _$MatchScouting2024FromJson(Map<String, dynamic> json) {
  return _MatchScouting2024.fromJson(json);
}

/// @nodoc
mixin _$MatchScouting2024 {
  String get event_code => throw _privateConstructorUsedError;
  String get team_number => throw _privateConstructorUsedError;
  int get match_number => throw _privateConstructorUsedError;
  bool get active => throw _privateConstructorUsedError;
  ScoutInfo2024 get scout_info => throw _privateConstructorUsedError;
  MatchData2024 get data => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;

  /// Serializes this MatchScouting2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchScouting2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchScouting2024CopyWith<MatchScouting2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchScouting2024CopyWith<$Res> {
  factory $MatchScouting2024CopyWith(
          MatchScouting2024 value, $Res Function(MatchScouting2024) then) =
      _$MatchScouting2024CopyWithImpl<$Res, MatchScouting2024>;
  @useResult
  $Res call(
      {String event_code,
      String team_number,
      int match_number,
      bool active,
      ScoutInfo2024 scout_info,
      MatchData2024 data,
      int time});

  $ScoutInfo2024CopyWith<$Res> get scout_info;
  $MatchData2024CopyWith<$Res> get data;
}

/// @nodoc
class _$MatchScouting2024CopyWithImpl<$Res, $Val extends MatchScouting2024>
    implements $MatchScouting2024CopyWith<$Res> {
  _$MatchScouting2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchScouting2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event_code = null,
    Object? team_number = null,
    Object? match_number = null,
    Object? active = null,
    Object? scout_info = null,
    Object? data = null,
    Object? time = null,
  }) {
    return _then(_value.copyWith(
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as String,
      match_number: null == match_number
          ? _value.match_number
          : match_number // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      scout_info: null == scout_info
          ? _value.scout_info
          : scout_info // ignore: cast_nullable_to_non_nullable
              as ScoutInfo2024,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as MatchData2024,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of MatchScouting2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoutInfo2024CopyWith<$Res> get scout_info {
    return $ScoutInfo2024CopyWith<$Res>(_value.scout_info, (value) {
      return _then(_value.copyWith(scout_info: value) as $Val);
    });
  }

  /// Create a copy of MatchScouting2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchData2024CopyWith<$Res> get data {
    return $MatchData2024CopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchScouting2024ImplCopyWith<$Res>
    implements $MatchScouting2024CopyWith<$Res> {
  factory _$$MatchScouting2024ImplCopyWith(_$MatchScouting2024Impl value,
          $Res Function(_$MatchScouting2024Impl) then) =
      __$$MatchScouting2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String event_code,
      String team_number,
      int match_number,
      bool active,
      ScoutInfo2024 scout_info,
      MatchData2024 data,
      int time});

  @override
  $ScoutInfo2024CopyWith<$Res> get scout_info;
  @override
  $MatchData2024CopyWith<$Res> get data;
}

/// @nodoc
class __$$MatchScouting2024ImplCopyWithImpl<$Res>
    extends _$MatchScouting2024CopyWithImpl<$Res, _$MatchScouting2024Impl>
    implements _$$MatchScouting2024ImplCopyWith<$Res> {
  __$$MatchScouting2024ImplCopyWithImpl(_$MatchScouting2024Impl _value,
      $Res Function(_$MatchScouting2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of MatchScouting2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event_code = null,
    Object? team_number = null,
    Object? match_number = null,
    Object? active = null,
    Object? scout_info = null,
    Object? data = null,
    Object? time = null,
  }) {
    return _then(_$MatchScouting2024Impl(
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as String,
      match_number: null == match_number
          ? _value.match_number
          : match_number // ignore: cast_nullable_to_non_nullable
              as int,
      active: null == active
          ? _value.active
          : active // ignore: cast_nullable_to_non_nullable
              as bool,
      scout_info: null == scout_info
          ? _value.scout_info
          : scout_info // ignore: cast_nullable_to_non_nullable
              as ScoutInfo2024,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as MatchData2024,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchScouting2024Impl implements _MatchScouting2024 {
  const _$MatchScouting2024Impl(
      {required this.event_code,
      required this.team_number,
      required this.match_number,
      required this.active,
      required this.scout_info,
      required this.data,
      required this.time});

  factory _$MatchScouting2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$MatchScouting2024ImplFromJson(json);

  @override
  final String event_code;
  @override
  final String team_number;
  @override
  final int match_number;
  @override
  final bool active;
  @override
  final ScoutInfo2024 scout_info;
  @override
  final MatchData2024 data;
  @override
  final int time;

  @override
  String toString() {
    return 'MatchScouting2024(event_code: $event_code, team_number: $team_number, match_number: $match_number, active: $active, scout_info: $scout_info, data: $data, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchScouting2024Impl &&
            (identical(other.event_code, event_code) ||
                other.event_code == event_code) &&
            (identical(other.team_number, team_number) ||
                other.team_number == team_number) &&
            (identical(other.match_number, match_number) ||
                other.match_number == match_number) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.scout_info, scout_info) ||
                other.scout_info == scout_info) &&
            (identical(other.data, data) || other.data == data) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, event_code, team_number,
      match_number, active, scout_info, data, time);

  /// Create a copy of MatchScouting2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchScouting2024ImplCopyWith<_$MatchScouting2024Impl> get copyWith =>
      __$$MatchScouting2024ImplCopyWithImpl<_$MatchScouting2024Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchScouting2024ImplToJson(
      this,
    );
  }
}

abstract class _MatchScouting2024 implements MatchScouting2024 {
  const factory _MatchScouting2024(
      {required final String event_code,
      required final String team_number,
      required final int match_number,
      required final bool active,
      required final ScoutInfo2024 scout_info,
      required final MatchData2024 data,
      required final int time}) = _$MatchScouting2024Impl;

  factory _MatchScouting2024.fromJson(Map<String, dynamic> json) =
      _$MatchScouting2024Impl.fromJson;

  @override
  String get event_code;
  @override
  String get team_number;
  @override
  int get match_number;
  @override
  bool get active;
  @override
  ScoutInfo2024 get scout_info;
  @override
  MatchData2024 get data;
  @override
  int get time;

  /// Create a copy of MatchScouting2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchScouting2024ImplCopyWith<_$MatchScouting2024Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoutInfo2024 _$ScoutInfo2024FromJson(Map<String, dynamic> json) {
  return _ScoutInfo2024.fromJson(json);
}

/// @nodoc
mixin _$ScoutInfo2024 {
  String get name => throw _privateConstructorUsedError;

  /// Serializes this ScoutInfo2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoutInfo2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoutInfo2024CopyWith<ScoutInfo2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoutInfo2024CopyWith<$Res> {
  factory $ScoutInfo2024CopyWith(
          ScoutInfo2024 value, $Res Function(ScoutInfo2024) then) =
      _$ScoutInfo2024CopyWithImpl<$Res, ScoutInfo2024>;
  @useResult
  $Res call({String name});
}

/// @nodoc
class _$ScoutInfo2024CopyWithImpl<$Res, $Val extends ScoutInfo2024>
    implements $ScoutInfo2024CopyWith<$Res> {
  _$ScoutInfo2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoutInfo2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoutInfo2024ImplCopyWith<$Res>
    implements $ScoutInfo2024CopyWith<$Res> {
  factory _$$ScoutInfo2024ImplCopyWith(
          _$ScoutInfo2024Impl value, $Res Function(_$ScoutInfo2024Impl) then) =
      __$$ScoutInfo2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name});
}

/// @nodoc
class __$$ScoutInfo2024ImplCopyWithImpl<$Res>
    extends _$ScoutInfo2024CopyWithImpl<$Res, _$ScoutInfo2024Impl>
    implements _$$ScoutInfo2024ImplCopyWith<$Res> {
  __$$ScoutInfo2024ImplCopyWithImpl(
      _$ScoutInfo2024Impl _value, $Res Function(_$ScoutInfo2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of ScoutInfo2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_$ScoutInfo2024Impl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoutInfo2024Impl implements _ScoutInfo2024 {
  const _$ScoutInfo2024Impl({required this.name});

  factory _$ScoutInfo2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutInfo2024ImplFromJson(json);

  @override
  final String name;

  @override
  String toString() {
    return 'ScoutInfo2024(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutInfo2024Impl &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of ScoutInfo2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoutInfo2024ImplCopyWith<_$ScoutInfo2024Impl> get copyWith =>
      __$$ScoutInfo2024ImplCopyWithImpl<_$ScoutInfo2024Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoutInfo2024ImplToJson(
      this,
    );
  }
}

abstract class _ScoutInfo2024 implements ScoutInfo2024 {
  const factory _ScoutInfo2024({required final String name}) =
      _$ScoutInfo2024Impl;

  factory _ScoutInfo2024.fromJson(Map<String, dynamic> json) =
      _$ScoutInfo2024Impl.fromJson;

  @override
  String get name;

  /// Create a copy of ScoutInfo2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoutInfo2024ImplCopyWith<_$ScoutInfo2024Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchData2024 _$MatchData2024FromJson(Map<String, dynamic> json) {
  return _MatchData2024.fromJson(json);
}

/// @nodoc
mixin _$MatchData2024 {
  AutoData2024 get auto => throw _privateConstructorUsedError;
  TeleopData2024 get teleop => throw _privateConstructorUsedError;
  MiscellaneousData2024 get miscellaneous => throw _privateConstructorUsedError;
  List<String>? get selectedPieces => throw _privateConstructorUsedError;

  /// Serializes this MatchData2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchData2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchData2024CopyWith<MatchData2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchData2024CopyWith<$Res> {
  factory $MatchData2024CopyWith(
          MatchData2024 value, $Res Function(MatchData2024) then) =
      _$MatchData2024CopyWithImpl<$Res, MatchData2024>;
  @useResult
  $Res call(
      {AutoData2024 auto,
      TeleopData2024 teleop,
      MiscellaneousData2024 miscellaneous,
      List<String>? selectedPieces});

  $AutoData2024CopyWith<$Res> get auto;
  $TeleopData2024CopyWith<$Res> get teleop;
  $MiscellaneousData2024CopyWith<$Res> get miscellaneous;
}

/// @nodoc
class _$MatchData2024CopyWithImpl<$Res, $Val extends MatchData2024>
    implements $MatchData2024CopyWith<$Res> {
  _$MatchData2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchData2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? auto = null,
    Object? teleop = null,
    Object? miscellaneous = null,
    Object? selectedPieces = freezed,
  }) {
    return _then(_value.copyWith(
      auto: null == auto
          ? _value.auto
          : auto // ignore: cast_nullable_to_non_nullable
              as AutoData2024,
      teleop: null == teleop
          ? _value.teleop
          : teleop // ignore: cast_nullable_to_non_nullable
              as TeleopData2024,
      miscellaneous: null == miscellaneous
          ? _value.miscellaneous
          : miscellaneous // ignore: cast_nullable_to_non_nullable
              as MiscellaneousData2024,
      selectedPieces: freezed == selectedPieces
          ? _value.selectedPieces
          : selectedPieces // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }

  /// Create a copy of MatchData2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AutoData2024CopyWith<$Res> get auto {
    return $AutoData2024CopyWith<$Res>(_value.auto, (value) {
      return _then(_value.copyWith(auto: value) as $Val);
    });
  }

  /// Create a copy of MatchData2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeleopData2024CopyWith<$Res> get teleop {
    return $TeleopData2024CopyWith<$Res>(_value.teleop, (value) {
      return _then(_value.copyWith(teleop: value) as $Val);
    });
  }

  /// Create a copy of MatchData2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MiscellaneousData2024CopyWith<$Res> get miscellaneous {
    return $MiscellaneousData2024CopyWith<$Res>(_value.miscellaneous, (value) {
      return _then(_value.copyWith(miscellaneous: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchData2024ImplCopyWith<$Res>
    implements $MatchData2024CopyWith<$Res> {
  factory _$$MatchData2024ImplCopyWith(
          _$MatchData2024Impl value, $Res Function(_$MatchData2024Impl) then) =
      __$$MatchData2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {AutoData2024 auto,
      TeleopData2024 teleop,
      MiscellaneousData2024 miscellaneous,
      List<String>? selectedPieces});

  @override
  $AutoData2024CopyWith<$Res> get auto;
  @override
  $TeleopData2024CopyWith<$Res> get teleop;
  @override
  $MiscellaneousData2024CopyWith<$Res> get miscellaneous;
}

/// @nodoc
class __$$MatchData2024ImplCopyWithImpl<$Res>
    extends _$MatchData2024CopyWithImpl<$Res, _$MatchData2024Impl>
    implements _$$MatchData2024ImplCopyWith<$Res> {
  __$$MatchData2024ImplCopyWithImpl(
      _$MatchData2024Impl _value, $Res Function(_$MatchData2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of MatchData2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? auto = null,
    Object? teleop = null,
    Object? miscellaneous = null,
    Object? selectedPieces = freezed,
  }) {
    return _then(_$MatchData2024Impl(
      auto: null == auto
          ? _value.auto
          : auto // ignore: cast_nullable_to_non_nullable
              as AutoData2024,
      teleop: null == teleop
          ? _value.teleop
          : teleop // ignore: cast_nullable_to_non_nullable
              as TeleopData2024,
      miscellaneous: null == miscellaneous
          ? _value.miscellaneous
          : miscellaneous // ignore: cast_nullable_to_non_nullable
              as MiscellaneousData2024,
      selectedPieces: freezed == selectedPieces
          ? _value._selectedPieces
          : selectedPieces // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchData2024Impl implements _MatchData2024 {
  const _$MatchData2024Impl(
      {required this.auto,
      required this.teleop,
      required this.miscellaneous,
      final List<String>? selectedPieces})
      : _selectedPieces = selectedPieces;

  factory _$MatchData2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$MatchData2024ImplFromJson(json);

  @override
  final AutoData2024 auto;
  @override
  final TeleopData2024 teleop;
  @override
  final MiscellaneousData2024 miscellaneous;
  final List<String>? _selectedPieces;
  @override
  List<String>? get selectedPieces {
    final value = _selectedPieces;
    if (value == null) return null;
    if (_selectedPieces is EqualUnmodifiableListView) return _selectedPieces;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'MatchData2024(auto: $auto, teleop: $teleop, miscellaneous: $miscellaneous, selectedPieces: $selectedPieces)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchData2024Impl &&
            (identical(other.auto, auto) || other.auto == auto) &&
            (identical(other.teleop, teleop) || other.teleop == teleop) &&
            (identical(other.miscellaneous, miscellaneous) ||
                other.miscellaneous == miscellaneous) &&
            const DeepCollectionEquality()
                .equals(other._selectedPieces, _selectedPieces));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, auto, teleop, miscellaneous,
      const DeepCollectionEquality().hash(_selectedPieces));

  /// Create a copy of MatchData2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchData2024ImplCopyWith<_$MatchData2024Impl> get copyWith =>
      __$$MatchData2024ImplCopyWithImpl<_$MatchData2024Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchData2024ImplToJson(
      this,
    );
  }
}

abstract class _MatchData2024 implements MatchData2024 {
  const factory _MatchData2024(
      {required final AutoData2024 auto,
      required final TeleopData2024 teleop,
      required final MiscellaneousData2024 miscellaneous,
      final List<String>? selectedPieces}) = _$MatchData2024Impl;

  factory _MatchData2024.fromJson(Map<String, dynamic> json) =
      _$MatchData2024Impl.fromJson;

  @override
  AutoData2024 get auto;
  @override
  TeleopData2024 get teleop;
  @override
  MiscellaneousData2024 get miscellaneous;
  @override
  List<String>? get selectedPieces;

  /// Create a copy of MatchData2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchData2024ImplCopyWith<_$MatchData2024Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

AutoData2024 _$AutoData2024FromJson(Map<String, dynamic> json) {
  return _AutoData2024.fromJson(json);
}

/// @nodoc
mixin _$AutoData2024 {
  int get amp => throw _privateConstructorUsedError;
  int get speaker => throw _privateConstructorUsedError;

  /// Serializes this AutoData2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AutoData2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AutoData2024CopyWith<AutoData2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AutoData2024CopyWith<$Res> {
  factory $AutoData2024CopyWith(
          AutoData2024 value, $Res Function(AutoData2024) then) =
      _$AutoData2024CopyWithImpl<$Res, AutoData2024>;
  @useResult
  $Res call({int amp, int speaker});
}

/// @nodoc
class _$AutoData2024CopyWithImpl<$Res, $Val extends AutoData2024>
    implements $AutoData2024CopyWith<$Res> {
  _$AutoData2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AutoData2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amp = null,
    Object? speaker = null,
  }) {
    return _then(_value.copyWith(
      amp: null == amp
          ? _value.amp
          : amp // ignore: cast_nullable_to_non_nullable
              as int,
      speaker: null == speaker
          ? _value.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AutoData2024ImplCopyWith<$Res>
    implements $AutoData2024CopyWith<$Res> {
  factory _$$AutoData2024ImplCopyWith(
          _$AutoData2024Impl value, $Res Function(_$AutoData2024Impl) then) =
      __$$AutoData2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int amp, int speaker});
}

/// @nodoc
class __$$AutoData2024ImplCopyWithImpl<$Res>
    extends _$AutoData2024CopyWithImpl<$Res, _$AutoData2024Impl>
    implements _$$AutoData2024ImplCopyWith<$Res> {
  __$$AutoData2024ImplCopyWithImpl(
      _$AutoData2024Impl _value, $Res Function(_$AutoData2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of AutoData2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amp = null,
    Object? speaker = null,
  }) {
    return _then(_$AutoData2024Impl(
      amp: null == amp
          ? _value.amp
          : amp // ignore: cast_nullable_to_non_nullable
              as int,
      speaker: null == speaker
          ? _value.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AutoData2024Impl implements _AutoData2024 {
  const _$AutoData2024Impl({required this.amp, required this.speaker});

  factory _$AutoData2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$AutoData2024ImplFromJson(json);

  @override
  final int amp;
  @override
  final int speaker;

  @override
  String toString() {
    return 'AutoData2024(amp: $amp, speaker: $speaker)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AutoData2024Impl &&
            (identical(other.amp, amp) || other.amp == amp) &&
            (identical(other.speaker, speaker) || other.speaker == speaker));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, amp, speaker);

  /// Create a copy of AutoData2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AutoData2024ImplCopyWith<_$AutoData2024Impl> get copyWith =>
      __$$AutoData2024ImplCopyWithImpl<_$AutoData2024Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AutoData2024ImplToJson(
      this,
    );
  }
}

abstract class _AutoData2024 implements AutoData2024 {
  const factory _AutoData2024(
      {required final int amp,
      required final int speaker}) = _$AutoData2024Impl;

  factory _AutoData2024.fromJson(Map<String, dynamic> json) =
      _$AutoData2024Impl.fromJson;

  @override
  int get amp;
  @override
  int get speaker;

  /// Create a copy of AutoData2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AutoData2024ImplCopyWith<_$AutoData2024Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

TeleopData2024 _$TeleopData2024FromJson(Map<String, dynamic> json) {
  return _TeleopData2024.fromJson(json);
}

/// @nodoc
mixin _$TeleopData2024 {
  int get amp => throw _privateConstructorUsedError;
  int get speaker => throw _privateConstructorUsedError;
  int get amped_speaker => throw _privateConstructorUsedError;
  int? get pass => throw _privateConstructorUsedError;

  /// Serializes this TeleopData2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeleopData2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeleopData2024CopyWith<TeleopData2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeleopData2024CopyWith<$Res> {
  factory $TeleopData2024CopyWith(
          TeleopData2024 value, $Res Function(TeleopData2024) then) =
      _$TeleopData2024CopyWithImpl<$Res, TeleopData2024>;
  @useResult
  $Res call({int amp, int speaker, int amped_speaker, int? pass});
}

/// @nodoc
class _$TeleopData2024CopyWithImpl<$Res, $Val extends TeleopData2024>
    implements $TeleopData2024CopyWith<$Res> {
  _$TeleopData2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeleopData2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amp = null,
    Object? speaker = null,
    Object? amped_speaker = null,
    Object? pass = freezed,
  }) {
    return _then(_value.copyWith(
      amp: null == amp
          ? _value.amp
          : amp // ignore: cast_nullable_to_non_nullable
              as int,
      speaker: null == speaker
          ? _value.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as int,
      amped_speaker: null == amped_speaker
          ? _value.amped_speaker
          : amped_speaker // ignore: cast_nullable_to_non_nullable
              as int,
      pass: freezed == pass
          ? _value.pass
          : pass // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeleopData2024ImplCopyWith<$Res>
    implements $TeleopData2024CopyWith<$Res> {
  factory _$$TeleopData2024ImplCopyWith(_$TeleopData2024Impl value,
          $Res Function(_$TeleopData2024Impl) then) =
      __$$TeleopData2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int amp, int speaker, int amped_speaker, int? pass});
}

/// @nodoc
class __$$TeleopData2024ImplCopyWithImpl<$Res>
    extends _$TeleopData2024CopyWithImpl<$Res, _$TeleopData2024Impl>
    implements _$$TeleopData2024ImplCopyWith<$Res> {
  __$$TeleopData2024ImplCopyWithImpl(
      _$TeleopData2024Impl _value, $Res Function(_$TeleopData2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of TeleopData2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? amp = null,
    Object? speaker = null,
    Object? amped_speaker = null,
    Object? pass = freezed,
  }) {
    return _then(_$TeleopData2024Impl(
      amp: null == amp
          ? _value.amp
          : amp // ignore: cast_nullable_to_non_nullable
              as int,
      speaker: null == speaker
          ? _value.speaker
          : speaker // ignore: cast_nullable_to_non_nullable
              as int,
      amped_speaker: null == amped_speaker
          ? _value.amped_speaker
          : amped_speaker // ignore: cast_nullable_to_non_nullable
              as int,
      pass: freezed == pass
          ? _value.pass
          : pass // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeleopData2024Impl implements _TeleopData2024 {
  const _$TeleopData2024Impl(
      {required this.amp,
      required this.speaker,
      required this.amped_speaker,
      this.pass});

  factory _$TeleopData2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$TeleopData2024ImplFromJson(json);

  @override
  final int amp;
  @override
  final int speaker;
  @override
  final int amped_speaker;
  @override
  final int? pass;

  @override
  String toString() {
    return 'TeleopData2024(amp: $amp, speaker: $speaker, amped_speaker: $amped_speaker, pass: $pass)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeleopData2024Impl &&
            (identical(other.amp, amp) || other.amp == amp) &&
            (identical(other.speaker, speaker) || other.speaker == speaker) &&
            (identical(other.amped_speaker, amped_speaker) ||
                other.amped_speaker == amped_speaker) &&
            (identical(other.pass, pass) || other.pass == pass));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, amp, speaker, amped_speaker, pass);

  /// Create a copy of TeleopData2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeleopData2024ImplCopyWith<_$TeleopData2024Impl> get copyWith =>
      __$$TeleopData2024ImplCopyWithImpl<_$TeleopData2024Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeleopData2024ImplToJson(
      this,
    );
  }
}

abstract class _TeleopData2024 implements TeleopData2024 {
  const factory _TeleopData2024(
      {required final int amp,
      required final int speaker,
      required final int amped_speaker,
      final int? pass}) = _$TeleopData2024Impl;

  factory _TeleopData2024.fromJson(Map<String, dynamic> json) =
      _$TeleopData2024Impl.fromJson;

  @override
  int get amp;
  @override
  int get speaker;
  @override
  int get amped_speaker;
  @override
  int? get pass;

  /// Create a copy of TeleopData2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeleopData2024ImplCopyWith<_$TeleopData2024Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

MiscellaneousData2024 _$MiscellaneousData2024FromJson(
    Map<String, dynamic> json) {
  return _MiscellaneousData2024.fromJson(json);
}

/// @nodoc
mixin _$MiscellaneousData2024 {
  bool get died => throw _privateConstructorUsedError;
  String get comments => throw _privateConstructorUsedError;

  /// Serializes this MiscellaneousData2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MiscellaneousData2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MiscellaneousData2024CopyWith<MiscellaneousData2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MiscellaneousData2024CopyWith<$Res> {
  factory $MiscellaneousData2024CopyWith(MiscellaneousData2024 value,
          $Res Function(MiscellaneousData2024) then) =
      _$MiscellaneousData2024CopyWithImpl<$Res, MiscellaneousData2024>;
  @useResult
  $Res call({bool died, String comments});
}

/// @nodoc
class _$MiscellaneousData2024CopyWithImpl<$Res,
        $Val extends MiscellaneousData2024>
    implements $MiscellaneousData2024CopyWith<$Res> {
  _$MiscellaneousData2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MiscellaneousData2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? died = null,
    Object? comments = null,
  }) {
    return _then(_value.copyWith(
      died: null == died
          ? _value.died
          : died // ignore: cast_nullable_to_non_nullable
              as bool,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MiscellaneousData2024ImplCopyWith<$Res>
    implements $MiscellaneousData2024CopyWith<$Res> {
  factory _$$MiscellaneousData2024ImplCopyWith(
          _$MiscellaneousData2024Impl value,
          $Res Function(_$MiscellaneousData2024Impl) then) =
      __$$MiscellaneousData2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool died, String comments});
}

/// @nodoc
class __$$MiscellaneousData2024ImplCopyWithImpl<$Res>
    extends _$MiscellaneousData2024CopyWithImpl<$Res,
        _$MiscellaneousData2024Impl>
    implements _$$MiscellaneousData2024ImplCopyWith<$Res> {
  __$$MiscellaneousData2024ImplCopyWithImpl(_$MiscellaneousData2024Impl _value,
      $Res Function(_$MiscellaneousData2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of MiscellaneousData2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? died = null,
    Object? comments = null,
  }) {
    return _then(_$MiscellaneousData2024Impl(
      died: null == died
          ? _value.died
          : died // ignore: cast_nullable_to_non_nullable
              as bool,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MiscellaneousData2024Impl implements _MiscellaneousData2024 {
  const _$MiscellaneousData2024Impl(
      {required this.died, required this.comments});

  factory _$MiscellaneousData2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$MiscellaneousData2024ImplFromJson(json);

  @override
  final bool died;
  @override
  final String comments;

  @override
  String toString() {
    return 'MiscellaneousData2024(died: $died, comments: $comments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MiscellaneousData2024Impl &&
            (identical(other.died, died) || other.died == died) &&
            (identical(other.comments, comments) ||
                other.comments == comments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, died, comments);

  /// Create a copy of MiscellaneousData2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MiscellaneousData2024ImplCopyWith<_$MiscellaneousData2024Impl>
      get copyWith => __$$MiscellaneousData2024ImplCopyWithImpl<
          _$MiscellaneousData2024Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MiscellaneousData2024ImplToJson(
      this,
    );
  }
}

abstract class _MiscellaneousData2024 implements MiscellaneousData2024 {
  const factory _MiscellaneousData2024(
      {required final bool died,
      required final String comments}) = _$MiscellaneousData2024Impl;

  factory _MiscellaneousData2024.fromJson(Map<String, dynamic> json) =
      _$MiscellaneousData2024Impl.fromJson;

  @override
  bool get died;
  @override
  String get comments;

  /// Create a copy of MiscellaneousData2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MiscellaneousData2024ImplCopyWith<_$MiscellaneousData2024Impl>
      get copyWith => throw _privateConstructorUsedError;
}
