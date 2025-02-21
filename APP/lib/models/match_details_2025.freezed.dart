// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_details_2025.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchDetails2025 _$MatchDetails2025FromJson(Map<String, dynamic> json) {
  return _MatchDetails2025.fromJson(json);
}

/// @nodoc
mixin _$MatchDetails2025 {
  Match2025 get match => throw _privateConstructorUsedError;
  MatchPrediction2025 get prediction => throw _privateConstructorUsedError;
  List<TeamStats2025> get red_teams => throw _privateConstructorUsedError;
  List<TeamStats2025> get blue_teams => throw _privateConstructorUsedError;

  /// Serializes this MatchDetails2025 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchDetails2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchDetails2025CopyWith<MatchDetails2025> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchDetails2025CopyWith<$Res> {
  factory $MatchDetails2025CopyWith(
          MatchDetails2025 value, $Res Function(MatchDetails2025) then) =
      _$MatchDetails2025CopyWithImpl<$Res, MatchDetails2025>;
  @useResult
  $Res call(
      {Match2025 match,
      MatchPrediction2025 prediction,
      List<TeamStats2025> red_teams,
      List<TeamStats2025> blue_teams});

  $Match2025CopyWith<$Res> get match;
  $MatchPrediction2025CopyWith<$Res> get prediction;
}

/// @nodoc
class _$MatchDetails2025CopyWithImpl<$Res, $Val extends MatchDetails2025>
    implements $MatchDetails2025CopyWith<$Res> {
  _$MatchDetails2025CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchDetails2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match = null,
    Object? prediction = null,
    Object? red_teams = null,
    Object? blue_teams = null,
  }) {
    return _then(_value.copyWith(
      match: null == match
          ? _value.match
          : match // ignore: cast_nullable_to_non_nullable
              as Match2025,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as MatchPrediction2025,
      red_teams: null == red_teams
          ? _value.red_teams
          : red_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2025>,
      blue_teams: null == blue_teams
          ? _value.blue_teams
          : blue_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2025>,
    ) as $Val);
  }

  /// Create a copy of MatchDetails2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Match2025CopyWith<$Res> get match {
    return $Match2025CopyWith<$Res>(_value.match, (value) {
      return _then(_value.copyWith(match: value) as $Val);
    });
  }

  /// Create a copy of MatchDetails2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchPrediction2025CopyWith<$Res> get prediction {
    return $MatchPrediction2025CopyWith<$Res>(_value.prediction, (value) {
      return _then(_value.copyWith(prediction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchDetails2025ImplCopyWith<$Res>
    implements $MatchDetails2025CopyWith<$Res> {
  factory _$$MatchDetails2025ImplCopyWith(_$MatchDetails2025Impl value,
          $Res Function(_$MatchDetails2025Impl) then) =
      __$$MatchDetails2025ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Match2025 match,
      MatchPrediction2025 prediction,
      List<TeamStats2025> red_teams,
      List<TeamStats2025> blue_teams});

  @override
  $Match2025CopyWith<$Res> get match;
  @override
  $MatchPrediction2025CopyWith<$Res> get prediction;
}

/// @nodoc
class __$$MatchDetails2025ImplCopyWithImpl<$Res>
    extends _$MatchDetails2025CopyWithImpl<$Res, _$MatchDetails2025Impl>
    implements _$$MatchDetails2025ImplCopyWith<$Res> {
  __$$MatchDetails2025ImplCopyWithImpl(_$MatchDetails2025Impl _value,
      $Res Function(_$MatchDetails2025Impl) _then)
      : super(_value, _then);

  /// Create a copy of MatchDetails2025
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match = null,
    Object? prediction = null,
    Object? red_teams = null,
    Object? blue_teams = null,
  }) {
    return _then(_$MatchDetails2025Impl(
      match: null == match
          ? _value.match
          : match // ignore: cast_nullable_to_non_nullable
              as Match2025,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as MatchPrediction2025,
      red_teams: null == red_teams
          ? _value._red_teams
          : red_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2025>,
      blue_teams: null == blue_teams
          ? _value._blue_teams
          : blue_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2025>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchDetails2025Impl
    with DiagnosticableTreeMixin
    implements _MatchDetails2025 {
  const _$MatchDetails2025Impl(
      {required this.match,
      required this.prediction,
      required final List<TeamStats2025> red_teams,
      required final List<TeamStats2025> blue_teams})
      : _red_teams = red_teams,
        _blue_teams = blue_teams;

  factory _$MatchDetails2025Impl.fromJson(Map<String, dynamic> json) =>
      _$$MatchDetails2025ImplFromJson(json);

  @override
  final Match2025 match;
  @override
  final MatchPrediction2025 prediction;
  final List<TeamStats2025> _red_teams;
  @override
  List<TeamStats2025> get red_teams {
    if (_red_teams is EqualUnmodifiableListView) return _red_teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_red_teams);
  }

  final List<TeamStats2025> _blue_teams;
  @override
  List<TeamStats2025> get blue_teams {
    if (_blue_teams is EqualUnmodifiableListView) return _blue_teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blue_teams);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MatchDetails2025(match: $match, prediction: $prediction, red_teams: $red_teams, blue_teams: $blue_teams)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MatchDetails2025'))
      ..add(DiagnosticsProperty('match', match))
      ..add(DiagnosticsProperty('prediction', prediction))
      ..add(DiagnosticsProperty('red_teams', red_teams))
      ..add(DiagnosticsProperty('blue_teams', blue_teams));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchDetails2025Impl &&
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

  /// Create a copy of MatchDetails2025
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchDetails2025ImplCopyWith<_$MatchDetails2025Impl> get copyWith =>
      __$$MatchDetails2025ImplCopyWithImpl<_$MatchDetails2025Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchDetails2025ImplToJson(
      this,
    );
  }
}

abstract class _MatchDetails2025 implements MatchDetails2025 {
  const factory _MatchDetails2025(
      {required final Match2025 match,
      required final MatchPrediction2025 prediction,
      required final List<TeamStats2025> red_teams,
      required final List<TeamStats2025> blue_teams}) = _$MatchDetails2025Impl;

  factory _MatchDetails2025.fromJson(Map<String, dynamic> json) =
      _$MatchDetails2025Impl.fromJson;

  @override
  Match2025 get match;
  @override
  MatchPrediction2025 get prediction;
  @override
  List<TeamStats2025> get red_teams;
  @override
  List<TeamStats2025> get blue_teams;

  /// Create a copy of MatchDetails2025
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchDetails2025ImplCopyWith<_$MatchDetails2025Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
