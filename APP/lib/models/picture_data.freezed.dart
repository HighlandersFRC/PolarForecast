// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'picture_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PictureData _$PictureDataFromJson(Map<String, dynamic> json) {
  return _PictureData.fromJson(json);
}

/// @nodoc
mixin _$PictureData {
  String get user_id => throw _privateConstructorUsedError;
  int get team_number => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  String get event_code => throw _privateConstructorUsedError;
  String get image_id => throw _privateConstructorUsedError;
  String get link => throw _privateConstructorUsedError;

  /// Serializes this PictureData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PictureData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PictureDataCopyWith<PictureData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PictureDataCopyWith<$Res> {
  factory $PictureDataCopyWith(
          PictureData value, $Res Function(PictureData) then) =
      _$PictureDataCopyWithImpl<$Res, PictureData>;
  @useResult
  $Res call(
      {String user_id,
      int team_number,
      int time,
      String event_code,
      String image_id,
      String link});
}

/// @nodoc
class _$PictureDataCopyWithImpl<$Res, $Val extends PictureData>
    implements $PictureDataCopyWith<$Res> {
  _$PictureDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PictureData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? team_number = null,
    Object? time = null,
    Object? event_code = null,
    Object? image_id = null,
    Object? link = null,
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
      image_id: null == image_id
          ? _value.image_id
          : image_id // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PictureDataImplCopyWith<$Res>
    implements $PictureDataCopyWith<$Res> {
  factory _$$PictureDataImplCopyWith(
          _$PictureDataImpl value, $Res Function(_$PictureDataImpl) then) =
      __$$PictureDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String user_id,
      int team_number,
      int time,
      String event_code,
      String image_id,
      String link});
}

/// @nodoc
class __$$PictureDataImplCopyWithImpl<$Res>
    extends _$PictureDataCopyWithImpl<$Res, _$PictureDataImpl>
    implements _$$PictureDataImplCopyWith<$Res> {
  __$$PictureDataImplCopyWithImpl(
      _$PictureDataImpl _value, $Res Function(_$PictureDataImpl) _then)
      : super(_value, _then);

  /// Create a copy of PictureData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? team_number = null,
    Object? time = null,
    Object? event_code = null,
    Object? image_id = null,
    Object? link = null,
  }) {
    return _then(_$PictureDataImpl(
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
      image_id: null == image_id
          ? _value.image_id
          : image_id // ignore: cast_nullable_to_non_nullable
              as String,
      link: null == link
          ? _value.link
          : link // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PictureDataImpl implements _PictureData {
  const _$PictureDataImpl(
      {required this.user_id,
      required this.team_number,
      required this.time,
      required this.event_code,
      required this.image_id,
      required this.link});

  factory _$PictureDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$PictureDataImplFromJson(json);

  @override
  final String user_id;
  @override
  final int team_number;
  @override
  final int time;
  @override
  final String event_code;
  @override
  final String image_id;
  @override
  final String link;

  @override
  String toString() {
    return 'PictureData(user_id: $user_id, team_number: $team_number, time: $time, event_code: $event_code, image_id: $image_id, link: $link)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PictureDataImpl &&
            (identical(other.user_id, user_id) || other.user_id == user_id) &&
            (identical(other.team_number, team_number) ||
                other.team_number == team_number) &&
            (identical(other.time, time) || other.time == time) &&
            (identical(other.event_code, event_code) ||
                other.event_code == event_code) &&
            (identical(other.image_id, image_id) ||
                other.image_id == image_id) &&
            (identical(other.link, link) || other.link == link));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, user_id, team_number, time, event_code, image_id, link);

  /// Create a copy of PictureData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PictureDataImplCopyWith<_$PictureDataImpl> get copyWith =>
      __$$PictureDataImplCopyWithImpl<_$PictureDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PictureDataImplToJson(
      this,
    );
  }
}

abstract class _PictureData implements PictureData {
  const factory _PictureData(
      {required final String user_id,
      required final int team_number,
      required final int time,
      required final String event_code,
      required final String image_id,
      required final String link}) = _$PictureDataImpl;

  factory _PictureData.fromJson(Map<String, dynamic> json) =
      _$PictureDataImpl.fromJson;

  @override
  String get user_id;
  @override
  int get team_number;
  @override
  int get time;
  @override
  String get event_code;
  @override
  String get image_id;
  @override
  String get link;

  /// Create a copy of PictureData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PictureDataImplCopyWith<_$PictureDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
