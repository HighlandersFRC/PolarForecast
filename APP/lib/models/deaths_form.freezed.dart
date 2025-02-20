// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deaths_form.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Death _$DeathFromJson(Map<String, dynamic> json) {
  return _Death.fromJson(json);
}

/// @nodoc
mixin _$Death {
  int get match_number => throw _privateConstructorUsedError;
  int get severity => throw _privateConstructorUsedError;
  String get death_reason => throw _privateConstructorUsedError;

  /// Serializes this Death to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Death
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeathCopyWith<Death> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeathCopyWith<$Res> {
  factory $DeathCopyWith(Death value, $Res Function(Death) then) =
      _$DeathCopyWithImpl<$Res, Death>;
  @useResult
  $Res call({int match_number, int severity, String death_reason});
}

/// @nodoc
class _$DeathCopyWithImpl<$Res, $Val extends Death>
    implements $DeathCopyWith<$Res> {
  _$DeathCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Death
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match_number = null,
    Object? severity = null,
    Object? death_reason = null,
  }) {
    return _then(_value.copyWith(
      match_number: null == match_number
          ? _value.match_number
          : match_number // ignore: cast_nullable_to_non_nullable
              as int,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as int,
      death_reason: null == death_reason
          ? _value.death_reason
          : death_reason // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DeathImplCopyWith<$Res> implements $DeathCopyWith<$Res> {
  factory _$$DeathImplCopyWith(
          _$DeathImpl value, $Res Function(_$DeathImpl) then) =
      __$$DeathImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int match_number, int severity, String death_reason});
}

/// @nodoc
class __$$DeathImplCopyWithImpl<$Res>
    extends _$DeathCopyWithImpl<$Res, _$DeathImpl>
    implements _$$DeathImplCopyWith<$Res> {
  __$$DeathImplCopyWithImpl(
      _$DeathImpl _value, $Res Function(_$DeathImpl) _then)
      : super(_value, _then);

  /// Create a copy of Death
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match_number = null,
    Object? severity = null,
    Object? death_reason = null,
  }) {
    return _then(_$DeathImpl(
      match_number: null == match_number
          ? _value.match_number
          : match_number // ignore: cast_nullable_to_non_nullable
              as int,
      severity: null == severity
          ? _value.severity
          : severity // ignore: cast_nullable_to_non_nullable
              as int,
      death_reason: null == death_reason
          ? _value.death_reason
          : death_reason // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeathImpl implements _Death {
  const _$DeathImpl(
      {required this.match_number, this.severity = -1, this.death_reason = ''});

  factory _$DeathImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeathImplFromJson(json);

  @override
  final int match_number;
  @override
  @JsonKey()
  final int severity;
  @override
  @JsonKey()
  final String death_reason;

  @override
  String toString() {
    return 'Death(match_number: $match_number, severity: $severity, death_reason: $death_reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeathImpl &&
            (identical(other.match_number, match_number) ||
                other.match_number == match_number) &&
            (identical(other.severity, severity) ||
                other.severity == severity) &&
            (identical(other.death_reason, death_reason) ||
                other.death_reason == death_reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, match_number, severity, death_reason);

  /// Create a copy of Death
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeathImplCopyWith<_$DeathImpl> get copyWith =>
      __$$DeathImplCopyWithImpl<_$DeathImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeathImplToJson(
      this,
    );
  }
}

abstract class _Death implements Death {
  const factory _Death(
      {required final int match_number,
      final int severity,
      final String death_reason}) = _$DeathImpl;

  factory _Death.fromJson(Map<String, dynamic> json) = _$DeathImpl.fromJson;

  @override
  int get match_number;
  @override
  int get severity;
  @override
  String get death_reason;

  /// Create a copy of Death
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeathImplCopyWith<_$DeathImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Deaths _$DeathsFromJson(Map<String, dynamic> json) {
  return _Deaths.fromJson(json);
}

/// @nodoc
mixin _$Deaths {
  ScoutInfo get scout_info => throw _privateConstructorUsedError;
  String get event_code => throw _privateConstructorUsedError;
  String get team_key => throw _privateConstructorUsedError;
  List<Death> get deaths => throw _privateConstructorUsedError;
  int get total => throw _privateConstructorUsedError;
  int get average => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;

  /// Serializes this Deaths to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Deaths
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeathsCopyWith<Deaths> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeathsCopyWith<$Res> {
  factory $DeathsCopyWith(Deaths value, $Res Function(Deaths) then) =
      _$DeathsCopyWithImpl<$Res, Deaths>;
  @useResult
  $Res call(
      {ScoutInfo scout_info,
      String event_code,
      String team_key,
      List<Death> deaths,
      int total,
      int average,
      int time});

  $ScoutInfoCopyWith<$Res> get scout_info;
}

/// @nodoc
class _$DeathsCopyWithImpl<$Res, $Val extends Deaths>
    implements $DeathsCopyWith<$Res> {
  _$DeathsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Deaths
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scout_info = null,
    Object? event_code = null,
    Object? team_key = null,
    Object? deaths = null,
    Object? total = null,
    Object? average = null,
    Object? time = null,
  }) {
    return _then(_value.copyWith(
      scout_info: null == scout_info
          ? _value.scout_info
          : scout_info // ignore: cast_nullable_to_non_nullable
              as ScoutInfo,
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      team_key: null == team_key
          ? _value.team_key
          : team_key // ignore: cast_nullable_to_non_nullable
              as String,
      deaths: null == deaths
          ? _value.deaths
          : deaths // ignore: cast_nullable_to_non_nullable
              as List<Death>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      average: null == average
          ? _value.average
          : average // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }

  /// Create a copy of Deaths
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoutInfoCopyWith<$Res> get scout_info {
    return $ScoutInfoCopyWith<$Res>(_value.scout_info, (value) {
      return _then(_value.copyWith(scout_info: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeathsImplCopyWith<$Res> implements $DeathsCopyWith<$Res> {
  factory _$$DeathsImplCopyWith(
          _$DeathsImpl value, $Res Function(_$DeathsImpl) then) =
      __$$DeathsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ScoutInfo scout_info,
      String event_code,
      String team_key,
      List<Death> deaths,
      int total,
      int average,
      int time});

  @override
  $ScoutInfoCopyWith<$Res> get scout_info;
}

/// @nodoc
class __$$DeathsImplCopyWithImpl<$Res>
    extends _$DeathsCopyWithImpl<$Res, _$DeathsImpl>
    implements _$$DeathsImplCopyWith<$Res> {
  __$$DeathsImplCopyWithImpl(
      _$DeathsImpl _value, $Res Function(_$DeathsImpl) _then)
      : super(_value, _then);

  /// Create a copy of Deaths
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scout_info = null,
    Object? event_code = null,
    Object? team_key = null,
    Object? deaths = null,
    Object? total = null,
    Object? average = null,
    Object? time = null,
  }) {
    return _then(_$DeathsImpl(
      scout_info: null == scout_info
          ? _value.scout_info
          : scout_info // ignore: cast_nullable_to_non_nullable
              as ScoutInfo,
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      team_key: null == team_key
          ? _value.team_key
          : team_key // ignore: cast_nullable_to_non_nullable
              as String,
      deaths: null == deaths
          ? _value._deaths
          : deaths // ignore: cast_nullable_to_non_nullable
              as List<Death>,
      total: null == total
          ? _value.total
          : total // ignore: cast_nullable_to_non_nullable
              as int,
      average: null == average
          ? _value.average
          : average // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeathsImpl implements _Deaths {
  const _$DeathsImpl(
      {required this.scout_info,
      required this.event_code,
      required this.team_key,
      final List<Death> deaths = const [],
      required this.total,
      required this.average,
      required this.time})
      : _deaths = deaths;

  factory _$DeathsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeathsImplFromJson(json);

  @override
  final ScoutInfo scout_info;
  @override
  final String event_code;
  @override
  final String team_key;
  final List<Death> _deaths;
  @override
  @JsonKey()
  List<Death> get deaths {
    if (_deaths is EqualUnmodifiableListView) return _deaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deaths);
  }

  @override
  final int total;
  @override
  final int average;
  @override
  final int time;

  @override
  String toString() {
    return 'Deaths(scout_info: $scout_info, event_code: $event_code, team_key: $team_key, deaths: $deaths, total: $total, average: $average, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeathsImpl &&
            (identical(other.scout_info, scout_info) ||
                other.scout_info == scout_info) &&
            (identical(other.event_code, event_code) ||
                other.event_code == event_code) &&
            (identical(other.team_key, team_key) ||
                other.team_key == team_key) &&
            const DeepCollectionEquality().equals(other._deaths, _deaths) &&
            (identical(other.total, total) || other.total == total) &&
            (identical(other.average, average) || other.average == average) &&
            (identical(other.time, time) || other.time == time));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, scout_info, event_code, team_key,
      const DeepCollectionEquality().hash(_deaths), total, average, time);

  /// Create a copy of Deaths
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeathsImplCopyWith<_$DeathsImpl> get copyWith =>
      __$$DeathsImplCopyWithImpl<_$DeathsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeathsImplToJson(
      this,
    );
  }
}

abstract class _Deaths implements Deaths {
  const factory _Deaths(
      {required final ScoutInfo scout_info,
      required final String event_code,
      required final String team_key,
      final List<Death> deaths,
      required final int total,
      required final int average,
      required final int time}) = _$DeathsImpl;

  factory _Deaths.fromJson(Map<String, dynamic> json) = _$DeathsImpl.fromJson;

  @override
  ScoutInfo get scout_info;
  @override
  String get event_code;
  @override
  String get team_key;
  @override
  List<Death> get deaths;
  @override
  int get total;
  @override
  int get average;
  @override
  int get time;

  /// Create a copy of Deaths
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeathsImplCopyWith<_$DeathsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
