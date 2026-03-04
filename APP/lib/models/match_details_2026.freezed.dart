// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_details_2026.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchDetails2026 _$MatchDetails2026FromJson(Map<String, dynamic> json) {
  return _MatchDetails2026.fromJson(json);
}

/// @nodoc
mixin _$MatchDetails2026 {
  Match2026 get match => throw _privateConstructorUsedError;
  MatchPrediction2026? get prediction => throw _privateConstructorUsedError;
  List<TeamStats2026>? get red_teams => throw _privateConstructorUsedError;
  List<TeamStats2026>? get blue_teams => throw _privateConstructorUsedError;

  /// Serializes this MatchDetails2026 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchDetails2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchDetails2026CopyWith<MatchDetails2026> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchDetails2026CopyWith<$Res> {
  factory $MatchDetails2026CopyWith(
          MatchDetails2026 value, $Res Function(MatchDetails2026) then) =
      _$MatchDetails2026CopyWithImpl<$Res, MatchDetails2026>;
  @useResult
  $Res call(
      {Match2026 match,
      MatchPrediction2026? prediction,
      List<TeamStats2026>? red_teams,
      List<TeamStats2026>? blue_teams});

  $Match2026CopyWith<$Res> get match;
  $MatchPrediction2026CopyWith<$Res>? get prediction;
}

/// @nodoc
class _$MatchDetails2026CopyWithImpl<$Res, $Val extends MatchDetails2026>
    implements $MatchDetails2026CopyWith<$Res> {
  _$MatchDetails2026CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchDetails2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match = null,
    Object? prediction = freezed,
    Object? red_teams = freezed,
    Object? blue_teams = freezed,
  }) {
    return _then(_value.copyWith(
      match: null == match
          ? _value.match
          : match // ignore: cast_nullable_to_non_nullable
              as Match2026,
      prediction: freezed == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as MatchPrediction2026?,
      red_teams: freezed == red_teams
          ? _value.red_teams
          : red_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2026>?,
      blue_teams: freezed == blue_teams
          ? _value.blue_teams
          : blue_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2026>?,
    ) as $Val);
  }

  /// Create a copy of MatchDetails2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Match2026CopyWith<$Res> get match {
    return $Match2026CopyWith<$Res>(_value.match, (value) {
      return _then(_value.copyWith(match: value) as $Val);
    });
  }

  /// Create a copy of MatchDetails2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchPrediction2026CopyWith<$Res>? get prediction {
    if (_value.prediction == null) {
      return null;
    }

    return $MatchPrediction2026CopyWith<$Res>(_value.prediction!, (value) {
      return _then(_value.copyWith(prediction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchDetails2026ImplCopyWith<$Res>
    implements $MatchDetails2026CopyWith<$Res> {
  factory _$$MatchDetails2026ImplCopyWith(_$MatchDetails2026Impl value,
          $Res Function(_$MatchDetails2026Impl) then) =
      __$$MatchDetails2026ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Match2026 match,
      MatchPrediction2026? prediction,
      List<TeamStats2026>? red_teams,
      List<TeamStats2026>? blue_teams});

  @override
  $Match2026CopyWith<$Res> get match;
  @override
  $MatchPrediction2026CopyWith<$Res>? get prediction;
}

/// @nodoc
class __$$MatchDetails2026ImplCopyWithImpl<$Res>
    extends _$MatchDetails2026CopyWithImpl<$Res, _$MatchDetails2026Impl>
    implements _$$MatchDetails2026ImplCopyWith<$Res> {
  __$$MatchDetails2026ImplCopyWithImpl(_$MatchDetails2026Impl _value,
      $Res Function(_$MatchDetails2026Impl) _then)
      : super(_value, _then);

  /// Create a copy of MatchDetails2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match = null,
    Object? prediction = freezed,
    Object? red_teams = freezed,
    Object? blue_teams = freezed,
  }) {
    return _then(_$MatchDetails2026Impl(
      match: null == match
          ? _value.match
          : match // ignore: cast_nullable_to_non_nullable
              as Match2026,
      prediction: freezed == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as MatchPrediction2026?,
      red_teams: freezed == red_teams
          ? _value._red_teams
          : red_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2026>?,
      blue_teams: freezed == blue_teams
          ? _value._blue_teams
          : blue_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2026>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchDetails2026Impl
    with DiagnosticableTreeMixin
    implements _MatchDetails2026 {
  const _$MatchDetails2026Impl(
      {required this.match,
      required this.prediction,
      required final List<TeamStats2026>? red_teams,
      required final List<TeamStats2026>? blue_teams})
      : _red_teams = red_teams,
        _blue_teams = blue_teams;

  factory _$MatchDetails2026Impl.fromJson(Map<String, dynamic> json) =>
      _$$MatchDetails2026ImplFromJson(json);

  @override
  final Match2026 match;
  @override
  final MatchPrediction2026? prediction;
  final List<TeamStats2026>? _red_teams;
  @override
  List<TeamStats2026>? get red_teams {
    final value = _red_teams;
    if (value == null) return null;
    if (_red_teams is EqualUnmodifiableListView) return _red_teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<TeamStats2026>? _blue_teams;
  @override
  List<TeamStats2026>? get blue_teams {
    final value = _blue_teams;
    if (value == null) return null;
    if (_blue_teams is EqualUnmodifiableListView) return _blue_teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MatchDetails2026(match: $match, prediction: $prediction, red_teams: $red_teams, blue_teams: $blue_teams)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MatchDetails2026'))
      ..add(DiagnosticsProperty('match', match))
      ..add(DiagnosticsProperty('prediction', prediction))
      ..add(DiagnosticsProperty('red_teams', red_teams))
      ..add(DiagnosticsProperty('blue_teams', blue_teams));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchDetails2026Impl &&
            (identical(other.match, match) || other.match == match) &&
            (identical(other.prediction, prediction) ||
                other.prediction == prediction) &&
            const DeepCollectionEquality()
                .equals(other._red_teams, _red_teams) &&
            const DeepCollectionEquality()
                .equals(other._blue_teams, _blue_teams));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      match,
      prediction,
      const DeepCollectionEquality().hash(_red_teams),
      const DeepCollectionEquality().hash(_blue_teams));

  /// Create a copy of MatchDetails2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchDetails2026ImplCopyWith<_$MatchDetails2026Impl> get copyWith =>
      __$$MatchDetails2026ImplCopyWithImpl<_$MatchDetails2026Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchDetails2026ImplToJson(
      this,
    );
  }
}

abstract class _MatchDetails2026 implements MatchDetails2026 {
  const factory _MatchDetails2026(
      {required final Match2026 match,
      required final MatchPrediction2026? prediction,
      required final List<TeamStats2026>? red_teams,
      required final List<TeamStats2026>? blue_teams}) = _$MatchDetails2026Impl;

  factory _MatchDetails2026.fromJson(Map<String, dynamic> json) =
      _$MatchDetails2026Impl.fromJson;

  @override
  Match2026 get match;
  @override
  MatchPrediction2026? get prediction;
  @override
  List<TeamStats2026>? get red_teams;
  @override
  List<TeamStats2026>? get blue_teams;

  /// Create a copy of MatchDetails2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchDetails2026ImplCopyWith<_$MatchDetails2026Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
