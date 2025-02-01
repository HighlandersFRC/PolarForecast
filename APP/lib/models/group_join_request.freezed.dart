// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_join_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GroupJoinRequest _$GroupJoinRequestFromJson(Map<String, dynamic> json) {
  return _GroupJoinRequest.fromJson(json);
}

/// @nodoc
mixin _$GroupJoinRequest {
  String get group_name => throw _privateConstructorUsedError;
  String get group_id => throw _privateConstructorUsedError;
  String get user_id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  int get request_time => throw _privateConstructorUsedError;
  bool get accepted => throw _privateConstructorUsedError;

  /// Serializes this GroupJoinRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupJoinRequestCopyWith<GroupJoinRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupJoinRequestCopyWith<$Res> {
  factory $GroupJoinRequestCopyWith(
          GroupJoinRequest value, $Res Function(GroupJoinRequest) then) =
      _$GroupJoinRequestCopyWithImpl<$Res, GroupJoinRequest>;
  @useResult
  $Res call(
      {String group_name,
      String group_id,
      String user_id,
      String username,
      int request_time,
      bool accepted});
}

/// @nodoc
class _$GroupJoinRequestCopyWithImpl<$Res, $Val extends GroupJoinRequest>
    implements $GroupJoinRequestCopyWith<$Res> {
  _$GroupJoinRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? group_name = null,
    Object? group_id = null,
    Object? user_id = null,
    Object? username = null,
    Object? request_time = null,
    Object? accepted = null,
  }) {
    return _then(_value.copyWith(
      group_name: null == group_name
          ? _value.group_name
          : group_name // ignore: cast_nullable_to_non_nullable
              as String,
      group_id: null == group_id
          ? _value.group_id
          : group_id // ignore: cast_nullable_to_non_nullable
              as String,
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      request_time: null == request_time
          ? _value.request_time
          : request_time // ignore: cast_nullable_to_non_nullable
              as int,
      accepted: null == accepted
          ? _value.accepted
          : accepted // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupJoinRequestImplCopyWith<$Res>
    implements $GroupJoinRequestCopyWith<$Res> {
  factory _$$GroupJoinRequestImplCopyWith(_$GroupJoinRequestImpl value,
          $Res Function(_$GroupJoinRequestImpl) then) =
      __$$GroupJoinRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String group_name,
      String group_id,
      String user_id,
      String username,
      int request_time,
      bool accepted});
}

/// @nodoc
class __$$GroupJoinRequestImplCopyWithImpl<$Res>
    extends _$GroupJoinRequestCopyWithImpl<$Res, _$GroupJoinRequestImpl>
    implements _$$GroupJoinRequestImplCopyWith<$Res> {
  __$$GroupJoinRequestImplCopyWithImpl(_$GroupJoinRequestImpl _value,
      $Res Function(_$GroupJoinRequestImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? group_name = null,
    Object? group_id = null,
    Object? user_id = null,
    Object? username = null,
    Object? request_time = null,
    Object? accepted = null,
  }) {
    return _then(_$GroupJoinRequestImpl(
      group_name: null == group_name
          ? _value.group_name
          : group_name // ignore: cast_nullable_to_non_nullable
              as String,
      group_id: null == group_id
          ? _value.group_id
          : group_id // ignore: cast_nullable_to_non_nullable
              as String,
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      request_time: null == request_time
          ? _value.request_time
          : request_time // ignore: cast_nullable_to_non_nullable
              as int,
      accepted: null == accepted
          ? _value.accepted
          : accepted // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupJoinRequestImpl implements _GroupJoinRequest {
  const _$GroupJoinRequestImpl(
      {required this.group_name,
      required this.group_id,
      required this.user_id,
      required this.username,
      required this.request_time,
      required this.accepted});

  factory _$GroupJoinRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupJoinRequestImplFromJson(json);

  @override
  final String group_name;
  @override
  final String group_id;
  @override
  final String user_id;
  @override
  final String username;
  @override
  final int request_time;
  @override
  final bool accepted;

  @override
  String toString() {
    return 'GroupJoinRequest(group_name: $group_name, group_id: $group_id, user_id: $user_id, username: $username, request_time: $request_time, accepted: $accepted)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupJoinRequestImpl &&
            (identical(other.group_name, group_name) ||
                other.group_name == group_name) &&
            (identical(other.group_id, group_id) ||
                other.group_id == group_id) &&
            (identical(other.user_id, user_id) || other.user_id == user_id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.request_time, request_time) ||
                other.request_time == request_time) &&
            (identical(other.accepted, accepted) ||
                other.accepted == accepted));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, group_name, group_id, user_id,
      username, request_time, accepted);

  /// Create a copy of GroupJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupJoinRequestImplCopyWith<_$GroupJoinRequestImpl> get copyWith =>
      __$$GroupJoinRequestImplCopyWithImpl<_$GroupJoinRequestImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupJoinRequestImplToJson(
      this,
    );
  }
}

abstract class _GroupJoinRequest implements GroupJoinRequest {
  const factory _GroupJoinRequest(
      {required final String group_name,
      required final String group_id,
      required final String user_id,
      required final String username,
      required final int request_time,
      required final bool accepted}) = _$GroupJoinRequestImpl;

  factory _GroupJoinRequest.fromJson(Map<String, dynamic> json) =
      _$GroupJoinRequestImpl.fromJson;

  @override
  String get group_name;
  @override
  String get group_id;
  @override
  String get user_id;
  @override
  String get username;
  @override
  int get request_time;
  @override
  bool get accepted;

  /// Create a copy of GroupJoinRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupJoinRequestImplCopyWith<_$GroupJoinRequestImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
