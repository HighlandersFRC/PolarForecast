// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'score_breakdowns_2025.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScoreBreakdowns2025 _$ScoreBreakdowns2025FromJson(Map<String, dynamic> json) {
  return _ScoreBreakdowns2025.fromJson(json);
}

/// @nodoc
mixin _$ScoreBreakdowns2025 {
  ScoreBreakdown2025 get red => throw _privateConstructorUsedError;
  ScoreBreakdown2025 get blue => throw _privateConstructorUsedError;

  /// Serializes this ScoreBreakdowns2025 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoreBreakdowns2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreBreakdowns2025CopyWith<ScoreBreakdowns2025> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreBreakdowns2025CopyWith<$Res> {
  factory $ScoreBreakdowns2025CopyWith(
          ScoreBreakdowns2025 value, $Res Function(ScoreBreakdowns2025) then) =
      _$ScoreBreakdowns2025CopyWithImpl<$Res, ScoreBreakdowns2025>;
  @useResult
  $Res call({ScoreBreakdown2025 red, ScoreBreakdown2025 blue});

  $ScoreBreakdown2025CopyWith<$Res> get red;
  $ScoreBreakdown2025CopyWith<$Res> get blue;
}

/// @nodoc
class _$ScoreBreakdowns2025CopyWithImpl<$Res, $Val extends ScoreBreakdowns2025>
    implements $ScoreBreakdowns2025CopyWith<$Res> {
  _$ScoreBreakdowns2025CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreBreakdowns2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? red = null,
    Object? blue = null,
  }) {
    return _then(_value.copyWith(
      red: null == red
          ? _value.red
          : red // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdown2025,
      blue: null == blue
          ? _value.blue
          : blue // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdown2025,
    ) as $Val);
  }

  /// Create a copy of ScoreBreakdowns2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreBreakdown2025CopyWith<$Res> get red {
    return $ScoreBreakdown2025CopyWith<$Res>(_value.red, (value) {
      return _then(_value.copyWith(red: value) as $Val);
    });
  }

  /// Create a copy of ScoreBreakdowns2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreBreakdown2025CopyWith<$Res> get blue {
    return $ScoreBreakdown2025CopyWith<$Res>(_value.blue, (value) {
      return _then(_value.copyWith(blue: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScoreBreakdowns2025ImplCopyWith<$Res>
    implements $ScoreBreakdowns2025CopyWith<$Res> {
  factory _$$ScoreBreakdowns2025ImplCopyWith(_$ScoreBreakdowns2025Impl value,
          $Res Function(_$ScoreBreakdowns2025Impl) then) =
      __$$ScoreBreakdowns2025ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ScoreBreakdown2025 red, ScoreBreakdown2025 blue});

  @override
  $ScoreBreakdown2025CopyWith<$Res> get red;
  @override
  $ScoreBreakdown2025CopyWith<$Res> get blue;
}

/// @nodoc
class __$$ScoreBreakdowns2025ImplCopyWithImpl<$Res>
    extends _$ScoreBreakdowns2025CopyWithImpl<$Res, _$ScoreBreakdowns2025Impl>
    implements _$$ScoreBreakdowns2025ImplCopyWith<$Res> {
  __$$ScoreBreakdowns2025ImplCopyWithImpl(_$ScoreBreakdowns2025Impl _value,
      $Res Function(_$ScoreBreakdowns2025Impl) _then)
      : super(_value, _then);

  /// Create a copy of ScoreBreakdowns2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? red = null,
    Object? blue = null,
  }) {
    return _then(_$ScoreBreakdowns2025Impl(
      red: null == red
          ? _value.red
          : red // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdown2025,
      blue: null == blue
          ? _value.blue
          : blue // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdown2025,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreBreakdowns2025Impl implements _ScoreBreakdowns2025 {
  const _$ScoreBreakdowns2025Impl({required this.red, required this.blue});

  factory _$ScoreBreakdowns2025Impl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreBreakdowns2025ImplFromJson(json);

  @override
  final ScoreBreakdown2025 red;
  @override
  final ScoreBreakdown2025 blue;

  @override
  String toString() {
    return 'ScoreBreakdowns2025(red: $red, blue: $blue)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreBreakdowns2025Impl &&
            (identical(other.red, red) || other.red == red) &&
            (identical(other.blue, blue) || other.blue == blue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, red, blue);

  /// Create a copy of ScoreBreakdowns2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreBreakdowns2025ImplCopyWith<_$ScoreBreakdowns2025Impl> get copyWith =>
      __$$ScoreBreakdowns2025ImplCopyWithImpl<_$ScoreBreakdowns2025Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreBreakdowns2025ImplToJson(
      this,
    );
  }
}

abstract class _ScoreBreakdowns2025 implements ScoreBreakdowns2025 {
  const factory _ScoreBreakdowns2025(
      {required final ScoreBreakdown2025 red,
      required final ScoreBreakdown2025 blue}) = _$ScoreBreakdowns2025Impl;

  factory _ScoreBreakdowns2025.fromJson(Map<String, dynamic> json) =
      _$ScoreBreakdowns2025Impl.fromJson;

  @override
  ScoreBreakdown2025 get red;
  @override
  ScoreBreakdown2025 get blue;

  /// Create a copy of ScoreBreakdowns2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreBreakdowns2025ImplCopyWith<_$ScoreBreakdowns2025Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
