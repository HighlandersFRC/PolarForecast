// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alliances.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Alliances _$AlliancesFromJson(Map<String, dynamic> json) {
  return _Alliances.fromJson(json);
}

/// @nodoc
mixin _$Alliances {
  Alliance get red => throw _privateConstructorUsedError;
  Alliance get blue => throw _privateConstructorUsedError;

  /// Serializes this Alliances to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Alliances
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlliancesCopyWith<Alliances> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlliancesCopyWith<$Res> {
  factory $AlliancesCopyWith(Alliances value, $Res Function(Alliances) then) =
      _$AlliancesCopyWithImpl<$Res, Alliances>;
  @useResult
  $Res call({Alliance red, Alliance blue});

  $AllianceCopyWith<$Res> get red;
  $AllianceCopyWith<$Res> get blue;
}

/// @nodoc
class _$AlliancesCopyWithImpl<$Res, $Val extends Alliances>
    implements $AlliancesCopyWith<$Res> {
  _$AlliancesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Alliances
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
              as Alliance,
      blue: null == blue
          ? _value.blue
          : blue // ignore: cast_nullable_to_non_nullable
              as Alliance,
    ) as $Val);
  }

  /// Create a copy of Alliances
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllianceCopyWith<$Res> get red {
    return $AllianceCopyWith<$Res>(_value.red, (value) {
      return _then(_value.copyWith(red: value) as $Val);
    });
  }

  /// Create a copy of Alliances
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AllianceCopyWith<$Res> get blue {
    return $AllianceCopyWith<$Res>(_value.blue, (value) {
      return _then(_value.copyWith(blue: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AlliancesImplCopyWith<$Res>
    implements $AlliancesCopyWith<$Res> {
  factory _$$AlliancesImplCopyWith(
          _$AlliancesImpl value, $Res Function(_$AlliancesImpl) then) =
      __$$AlliancesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Alliance red, Alliance blue});

  @override
  $AllianceCopyWith<$Res> get red;
  @override
  $AllianceCopyWith<$Res> get blue;
}

/// @nodoc
class __$$AlliancesImplCopyWithImpl<$Res>
    extends _$AlliancesCopyWithImpl<$Res, _$AlliancesImpl>
    implements _$$AlliancesImplCopyWith<$Res> {
  __$$AlliancesImplCopyWithImpl(
      _$AlliancesImpl _value, $Res Function(_$AlliancesImpl) _then)
      : super(_value, _then);

  /// Create a copy of Alliances
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? red = null,
    Object? blue = null,
  }) {
    return _then(_$AlliancesImpl(
      red: null == red
          ? _value.red
          : red // ignore: cast_nullable_to_non_nullable
              as Alliance,
      blue: null == blue
          ? _value.blue
          : blue // ignore: cast_nullable_to_non_nullable
              as Alliance,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AlliancesImpl with DiagnosticableTreeMixin implements _Alliances {
  const _$AlliancesImpl({required this.red, required this.blue});

  factory _$AlliancesImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlliancesImplFromJson(json);

  @override
  final Alliance red;
  @override
  final Alliance blue;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Alliances(red: $red, blue: $blue)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Alliances'))
      ..add(DiagnosticsProperty('red', red))
      ..add(DiagnosticsProperty('blue', blue));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlliancesImpl &&
            (identical(other.red, red) || other.red == red) &&
            (identical(other.blue, blue) || other.blue == blue));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, red, blue);

  /// Create a copy of Alliances
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlliancesImplCopyWith<_$AlliancesImpl> get copyWith =>
      __$$AlliancesImplCopyWithImpl<_$AlliancesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AlliancesImplToJson(
      this,
    );
  }
}

abstract class _Alliances implements Alliances {
  const factory _Alliances(
      {required final Alliance red,
      required final Alliance blue}) = _$AlliancesImpl;

  factory _Alliances.fromJson(Map<String, dynamic> json) =
      _$AlliancesImpl.fromJson;

  @override
  Alliance get red;
  @override
  Alliance get blue;

  /// Create a copy of Alliances
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlliancesImplCopyWith<_$AlliancesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
