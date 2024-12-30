// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_details_2024.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchDetails2024 _$MatchDetails2024FromJson(Map<String, dynamic> json) {
  return _MatchDetails2024.fromJson(json);
}

/// @nodoc
mixin _$MatchDetails2024 {
  Match2024 get match => throw _privateConstructorUsedError;
  MatchPrediction2024 get prediction => throw _privateConstructorUsedError;
  List<TeamStats2024> get red_teams => throw _privateConstructorUsedError;
  List<TeamStats2024> get blue_teams => throw _privateConstructorUsedError;

  /// Serializes this MatchDetails2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchDetails2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchDetails2024CopyWith<MatchDetails2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchDetails2024CopyWith<$Res> {
  factory $MatchDetails2024CopyWith(
          MatchDetails2024 value, $Res Function(MatchDetails2024) then) =
      _$MatchDetails2024CopyWithImpl<$Res, MatchDetails2024>;
  @useResult
  $Res call(
      {Match2024 match,
      MatchPrediction2024 prediction,
      List<TeamStats2024> red_teams,
      List<TeamStats2024> blue_teams});

  $Match2024CopyWith<$Res> get match;
  $MatchPrediction2024CopyWith<$Res> get prediction;
}

/// @nodoc
class _$MatchDetails2024CopyWithImpl<$Res, $Val extends MatchDetails2024>
    implements $MatchDetails2024CopyWith<$Res> {
  _$MatchDetails2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchDetails2024
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
              as Match2024,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as MatchPrediction2024,
      red_teams: null == red_teams
          ? _value.red_teams
          : red_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2024>,
      blue_teams: null == blue_teams
          ? _value.blue_teams
          : blue_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2024>,
    ) as $Val);
  }

  /// Create a copy of MatchDetails2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Match2024CopyWith<$Res> get match {
    return $Match2024CopyWith<$Res>(_value.match, (value) {
      return _then(_value.copyWith(match: value) as $Val);
    });
  }

  /// Create a copy of MatchDetails2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchPrediction2024CopyWith<$Res> get prediction {
    return $MatchPrediction2024CopyWith<$Res>(_value.prediction, (value) {
      return _then(_value.copyWith(prediction: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchDetails2024ImplCopyWith<$Res>
    implements $MatchDetails2024CopyWith<$Res> {
  factory _$$MatchDetails2024ImplCopyWith(_$MatchDetails2024Impl value,
          $Res Function(_$MatchDetails2024Impl) then) =
      __$$MatchDetails2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Match2024 match,
      MatchPrediction2024 prediction,
      List<TeamStats2024> red_teams,
      List<TeamStats2024> blue_teams});

  @override
  $Match2024CopyWith<$Res> get match;
  @override
  $MatchPrediction2024CopyWith<$Res> get prediction;
}

/// @nodoc
class __$$MatchDetails2024ImplCopyWithImpl<$Res>
    extends _$MatchDetails2024CopyWithImpl<$Res, _$MatchDetails2024Impl>
    implements _$$MatchDetails2024ImplCopyWith<$Res> {
  __$$MatchDetails2024ImplCopyWithImpl(_$MatchDetails2024Impl _value,
      $Res Function(_$MatchDetails2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of MatchDetails2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? match = null,
    Object? prediction = null,
    Object? red_teams = null,
    Object? blue_teams = null,
  }) {
    return _then(_$MatchDetails2024Impl(
      match: null == match
          ? _value.match
          : match // ignore: cast_nullable_to_non_nullable
              as Match2024,
      prediction: null == prediction
          ? _value.prediction
          : prediction // ignore: cast_nullable_to_non_nullable
              as MatchPrediction2024,
      red_teams: null == red_teams
          ? _value._red_teams
          : red_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2024>,
      blue_teams: null == blue_teams
          ? _value._blue_teams
          : blue_teams // ignore: cast_nullable_to_non_nullable
              as List<TeamStats2024>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchDetails2024Impl
    with DiagnosticableTreeMixin
    implements _MatchDetails2024 {
  const _$MatchDetails2024Impl(
      {required this.match,
      required this.prediction,
      required final List<TeamStats2024> red_teams,
      required final List<TeamStats2024> blue_teams})
      : _red_teams = red_teams,
        _blue_teams = blue_teams;

  factory _$MatchDetails2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$MatchDetails2024ImplFromJson(json);

  @override
  final Match2024 match;
  @override
  final MatchPrediction2024 prediction;
  final List<TeamStats2024> _red_teams;
  @override
  List<TeamStats2024> get red_teams {
    if (_red_teams is EqualUnmodifiableListView) return _red_teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_red_teams);
  }

  final List<TeamStats2024> _blue_teams;
  @override
  List<TeamStats2024> get blue_teams {
    if (_blue_teams is EqualUnmodifiableListView) return _blue_teams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blue_teams);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MatchDetails2024(match: $match, prediction: $prediction, red_teams: $red_teams, blue_teams: $blue_teams)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MatchDetails2024'))
      ..add(DiagnosticsProperty('match', match))
      ..add(DiagnosticsProperty('prediction', prediction))
      ..add(DiagnosticsProperty('red_teams', red_teams))
      ..add(DiagnosticsProperty('blue_teams', blue_teams));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchDetails2024Impl &&
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

  /// Create a copy of MatchDetails2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchDetails2024ImplCopyWith<_$MatchDetails2024Impl> get copyWith =>
      __$$MatchDetails2024ImplCopyWithImpl<_$MatchDetails2024Impl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchDetails2024ImplToJson(
      this,
    );
  }
}

abstract class _MatchDetails2024 implements MatchDetails2024 {
  const factory _MatchDetails2024(
      {required final Match2024 match,
      required final MatchPrediction2024 prediction,
      required final List<TeamStats2024> red_teams,
      required final List<TeamStats2024> blue_teams}) = _$MatchDetails2024Impl;

  factory _MatchDetails2024.fromJson(Map<String, dynamic> json) =
      _$MatchDetails2024Impl.fromJson;

  @override
  Match2024 get match;
  @override
  MatchPrediction2024 get prediction;
  @override
  List<TeamStats2024> get red_teams;
  @override
  List<TeamStats2024> get blue_teams;

  /// Create a copy of MatchDetails2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchDetails2024ImplCopyWith<_$MatchDetails2024Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
