// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'score_breakdowns_2024.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScoreBreakdowns2024 _$ScoreBreakdowns2024FromJson(Map<String, dynamic> json) {
  return _ScoreBreakdowns2024.fromJson(json);
}

/// @nodoc
mixin _$ScoreBreakdowns2024 {
  ScoreBreakdown2024 get red => throw _privateConstructorUsedError;
  ScoreBreakdown2024 get blue => throw _privateConstructorUsedError;

  /// Serializes this ScoreBreakdowns2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoreBreakdowns2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoreBreakdowns2024CopyWith<ScoreBreakdowns2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoreBreakdowns2024CopyWith<$Res> {
  factory $ScoreBreakdowns2024CopyWith(
          ScoreBreakdowns2024 value, $Res Function(ScoreBreakdowns2024) then) =
      _$ScoreBreakdowns2024CopyWithImpl<$Res, ScoreBreakdowns2024>;
  @useResult
  $Res call({ScoreBreakdown2024 red, ScoreBreakdown2024 blue});

  $ScoreBreakdown2024CopyWith<$Res> get red;
  $ScoreBreakdown2024CopyWith<$Res> get blue;
}

/// @nodoc
class _$ScoreBreakdowns2024CopyWithImpl<$Res, $Val extends ScoreBreakdowns2024>
    implements $ScoreBreakdowns2024CopyWith<$Res> {
  _$ScoreBreakdowns2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoreBreakdowns2024
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
              as ScoreBreakdown2024,
      blue: null == blue
          ? _value.blue
          : blue // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdown2024,
    ) as $Val);
  }

  /// Create a copy of ScoreBreakdowns2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreBreakdown2024CopyWith<$Res> get red {
    return $ScoreBreakdown2024CopyWith<$Res>(_value.red, (value) {
      return _then(_value.copyWith(red: value) as $Val);
    });
  }

  /// Create a copy of ScoreBreakdowns2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreBreakdown2024CopyWith<$Res> get blue {
    return $ScoreBreakdown2024CopyWith<$Res>(_value.blue, (value) {
      return _then(_value.copyWith(blue: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScoreBreakdowns2024ImplCopyWith<$Res>
    implements $ScoreBreakdowns2024CopyWith<$Res> {
  factory _$$ScoreBreakdowns2024ImplCopyWith(_$ScoreBreakdowns2024Impl value,
          $Res Function(_$ScoreBreakdowns2024Impl) then) =
      __$$ScoreBreakdowns2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ScoreBreakdown2024 red, ScoreBreakdown2024 blue});

  @override
  $ScoreBreakdown2024CopyWith<$Res> get red;
  @override
  $ScoreBreakdown2024CopyWith<$Res> get blue;
}

/// @nodoc
class __$$ScoreBreakdowns2024ImplCopyWithImpl<$Res>
    extends _$ScoreBreakdowns2024CopyWithImpl<$Res, _$ScoreBreakdowns2024Impl>
    implements _$$ScoreBreakdowns2024ImplCopyWith<$Res> {
  __$$ScoreBreakdowns2024ImplCopyWithImpl(_$ScoreBreakdowns2024Impl _value,
      $Res Function(_$ScoreBreakdowns2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of ScoreBreakdowns2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? red = null,
    Object? blue = null,
  }) {
    return _then(_$ScoreBreakdowns2024Impl(
      red: null == red
          ? _value.red
          : red // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdown2024,
      blue: null == blue
          ? _value.blue
          : blue // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdown2024,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoreBreakdowns2024Impl
    with DiagnosticableTreeMixin
    implements _ScoreBreakdowns2024 {
  const _$ScoreBreakdowns2024Impl({required this.red, required this.blue});

  factory _$ScoreBreakdowns2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$ScoreBreakdowns2024ImplFromJson(json);

  @override
  final ScoreBreakdown2024 red;
  @override
  final ScoreBreakdown2024 blue;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ScoreBreakdowns2024(red: $red, blue: $blue)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ScoreBreakdowns2024'))
      ..add(DiagnosticsProperty('red', red))
      ..add(DiagnosticsProperty('blue', blue));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoreBreakdowns2024Impl &&
            (identical(other.red, red) || other.red == red) &&
            (identical(other.blue, blue) || other.blue == blue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, red, blue);

  /// Create a copy of ScoreBreakdowns2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoreBreakdowns2024ImplCopyWith<_$ScoreBreakdowns2024Impl> get copyWith =>
      __$$ScoreBreakdowns2024ImplCopyWithImpl<_$ScoreBreakdowns2024Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoreBreakdowns2024ImplToJson(
      this,
    );
  }
}

abstract class _ScoreBreakdowns2024 implements ScoreBreakdowns2024 {
  const factory _ScoreBreakdowns2024(
      {required final ScoreBreakdown2024 red,
      required final ScoreBreakdown2024 blue}) = _$ScoreBreakdowns2024Impl;

  factory _ScoreBreakdowns2024.fromJson(Map<String, dynamic> json) =
      _$ScoreBreakdowns2024Impl.fromJson;

  @override
  ScoreBreakdown2024 get red;
  @override
  ScoreBreakdown2024 get blue;

  /// Create a copy of ScoreBreakdowns2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoreBreakdowns2024ImplCopyWith<_$ScoreBreakdowns2024Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
