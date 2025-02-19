// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scout_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScoutInfo _$ScoutInfoFromJson(Map<String, dynamic> json) {
  return _ScoutInfo.fromJson(json);
}

/// @nodoc
mixin _$ScoutInfo {
  String get user_id => throw _privateConstructorUsedError;
  String? get first_name => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  int get team_number => throw _privateConstructorUsedError;

  /// Serializes this ScoutInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoutInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoutInfoCopyWith<ScoutInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoutInfoCopyWith<$Res> {
  factory $ScoutInfoCopyWith(ScoutInfo value, $Res Function(ScoutInfo) then) =
      _$ScoutInfoCopyWithImpl<$Res, ScoutInfo>;
  @useResult
  $Res call(
      {String user_id, String? first_name, String? username, int team_number});
}

/// @nodoc
class _$ScoutInfoCopyWithImpl<$Res, $Val extends ScoutInfo>
    implements $ScoutInfoCopyWith<$Res> {
  _$ScoutInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoutInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? first_name = freezed,
    Object? username = freezed,
    Object? team_number = null,
  }) {
    return _then(_value.copyWith(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      first_name: freezed == first_name
          ? _value.first_name
          : first_name // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoutInfoImplCopyWith<$Res>
    implements $ScoutInfoCopyWith<$Res> {
  factory _$$ScoutInfoImplCopyWith(
          _$ScoutInfoImpl value, $Res Function(_$ScoutInfoImpl) then) =
      __$$ScoutInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String user_id, String? first_name, String? username, int team_number});
}

/// @nodoc
class __$$ScoutInfoImplCopyWithImpl<$Res>
    extends _$ScoutInfoCopyWithImpl<$Res, _$ScoutInfoImpl>
    implements _$$ScoutInfoImplCopyWith<$Res> {
  __$$ScoutInfoImplCopyWithImpl(
      _$ScoutInfoImpl _value, $Res Function(_$ScoutInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoutInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? first_name = freezed,
    Object? username = freezed,
    Object? team_number = null,
  }) {
    return _then(_$ScoutInfoImpl(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      first_name: freezed == first_name
          ? _value.first_name
          : first_name // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoutInfoImpl implements _ScoutInfo {
  const _$ScoutInfoImpl(
      {required this.user_id,
      this.first_name,
      this.username,
      required this.team_number});

  factory _$ScoutInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutInfoImplFromJson(json);

  @override
  final String user_id;
  @override
  final String? first_name;
  @override
  final String? username;
  @override
  final int team_number;

  @override
  String toString() {
    return 'ScoutInfo(user_id: $user_id, first_name: $first_name, username: $username, team_number: $team_number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutInfoImpl &&
            (identical(other.user_id, user_id) || other.user_id == user_id) &&
            (identical(other.first_name, first_name) ||
                other.first_name == first_name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.team_number, team_number) ||
                other.team_number == team_number));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, user_id, first_name, username, team_number);

  /// Create a copy of ScoutInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoutInfoImplCopyWith<_$ScoutInfoImpl> get copyWith =>
      __$$ScoutInfoImplCopyWithImpl<_$ScoutInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoutInfoImplToJson(
      this,
    );
  }
}

abstract class _ScoutInfo implements ScoutInfo {
  const factory _ScoutInfo(
      {required final String user_id,
      final String? first_name,
      final String? username,
      required final int team_number}) = _$ScoutInfoImpl;

  factory _ScoutInfo.fromJson(Map<String, dynamic> json) =
      _$ScoutInfoImpl.fromJson;

  @override
  String get user_id;
  @override
  String? get first_name;
  @override
  String? get username;
  @override
  int get team_number;

  /// Create a copy of ScoutInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoutInfoImplCopyWith<_$ScoutInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
