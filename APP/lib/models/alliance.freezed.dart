// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alliance.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Alliance _$AllianceFromJson(Map<String, dynamic> json) {
  return _Alliance.fromJson(json);
}

/// @nodoc
mixin _$Alliance {
  List<String> get dq_team_keys => throw _privateConstructorUsedError;
  List<String> get surrogate_team_keys => throw _privateConstructorUsedError;
  List<String> get team_keys => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;

  /// Serializes this Alliance to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Alliance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllianceCopyWith<Alliance> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllianceCopyWith<$Res> {
  factory $AllianceCopyWith(Alliance value, $Res Function(Alliance) then) =
      _$AllianceCopyWithImpl<$Res, Alliance>;
  @useResult
  $Res call(
      {List<String> dq_team_keys,
      List<String> surrogate_team_keys,
      List<String> team_keys,
      int score});
}

/// @nodoc
class _$AllianceCopyWithImpl<$Res, $Val extends Alliance>
    implements $AllianceCopyWith<$Res> {
  _$AllianceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Alliance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dq_team_keys = null,
    Object? surrogate_team_keys = null,
    Object? team_keys = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      dq_team_keys: null == dq_team_keys
          ? _value.dq_team_keys
          : dq_team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      surrogate_team_keys: null == surrogate_team_keys
          ? _value.surrogate_team_keys
          : surrogate_team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      team_keys: null == team_keys
          ? _value.team_keys
          : team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AllianceImplCopyWith<$Res>
    implements $AllianceCopyWith<$Res> {
  factory _$$AllianceImplCopyWith(
          _$AllianceImpl value, $Res Function(_$AllianceImpl) then) =
      __$$AllianceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> dq_team_keys,
      List<String> surrogate_team_keys,
      List<String> team_keys,
      int score});
}

/// @nodoc
class __$$AllianceImplCopyWithImpl<$Res>
    extends _$AllianceCopyWithImpl<$Res, _$AllianceImpl>
    implements _$$AllianceImplCopyWith<$Res> {
  __$$AllianceImplCopyWithImpl(
      _$AllianceImpl _value, $Res Function(_$AllianceImpl) _then)
      : super(_value, _then);

  /// Create a copy of Alliance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dq_team_keys = null,
    Object? surrogate_team_keys = null,
    Object? team_keys = null,
    Object? score = null,
  }) {
    return _then(_$AllianceImpl(
      dq_team_keys: null == dq_team_keys
          ? _value._dq_team_keys
          : dq_team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      surrogate_team_keys: null == surrogate_team_keys
          ? _value._surrogate_team_keys
          : surrogate_team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      team_keys: null == team_keys
          ? _value._team_keys
          : team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AllianceImpl with DiagnosticableTreeMixin implements _Alliance {
  const _$AllianceImpl(
      {required final List<String> dq_team_keys,
      required final List<String> surrogate_team_keys,
      required final List<String> team_keys,
      required this.score})
      : _dq_team_keys = dq_team_keys,
        _surrogate_team_keys = surrogate_team_keys,
        _team_keys = team_keys;

  factory _$AllianceImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllianceImplFromJson(json);

  final List<String> _dq_team_keys;
  @override
  List<String> get dq_team_keys {
    if (_dq_team_keys is EqualUnmodifiableListView) return _dq_team_keys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dq_team_keys);
  }

  final List<String> _surrogate_team_keys;
  @override
  List<String> get surrogate_team_keys {
    if (_surrogate_team_keys is EqualUnmodifiableListView)
      return _surrogate_team_keys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_surrogate_team_keys);
  }

  final List<String> _team_keys;
  @override
  List<String> get team_keys {
    if (_team_keys is EqualUnmodifiableListView) return _team_keys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_team_keys);
  }

  @override
  final int score;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Alliance(dq_team_keys: $dq_team_keys, surrogate_team_keys: $surrogate_team_keys, team_keys: $team_keys, score: $score)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Alliance'))
      ..add(DiagnosticsProperty('dq_team_keys', dq_team_keys))
      ..add(DiagnosticsProperty('surrogate_team_keys', surrogate_team_keys))
      ..add(DiagnosticsProperty('team_keys', team_keys))
      ..add(DiagnosticsProperty('score', score));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllianceImpl &&
            const DeepCollectionEquality()
                .equals(other._dq_team_keys, _dq_team_keys) &&
            const DeepCollectionEquality()
                .equals(other._surrogate_team_keys, _surrogate_team_keys) &&
            const DeepCollectionEquality()
                .equals(other._team_keys, _team_keys) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_dq_team_keys),
      const DeepCollectionEquality().hash(_surrogate_team_keys),
      const DeepCollectionEquality().hash(_team_keys),
      score);

  /// Create a copy of Alliance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllianceImplCopyWith<_$AllianceImpl> get copyWith =>
      __$$AllianceImplCopyWithImpl<_$AllianceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AllianceImplToJson(
      this,
    );
  }
}

abstract class _Alliance implements Alliance {
  const factory _Alliance(
      {required final List<String> dq_team_keys,
      required final List<String> surrogate_team_keys,
      required final List<String> team_keys,
      required final int score}) = _$AllianceImpl;

  factory _Alliance.fromJson(Map<String, dynamic> json) =
      _$AllianceImpl.fromJson;

  @override
  List<String> get dq_team_keys;
  @override
  List<String> get surrogate_team_keys;
  @override
  List<String> get team_keys;
  @override
  int get score;

  /// Create a copy of Alliance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllianceImplCopyWith<_$AllianceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
