// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'team_stats_2026.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TeamStats2026 _$TeamStats2026FromJson(Map<String, dynamic> json) {
  return _TeamStats2026.fromJson(json);
}

/// @nodoc
mixin _$TeamStats2026 {
// Historical from backend? Default false
  bool get historical =>
      throw _privateConstructorUsedError; // Unique key for the team, e.g., "frc6328"
  String get key => throw _privateConstructorUsedError; // Event rank
  int get rank => throw _privateConstructorUsedError; // Team number as string
  int get team_number =>
      throw _privateConstructorUsedError; // Total matches played
  double get match_count =>
      throw _privateConstructorUsedError; // Offensive Power Rating
  double get OPR => throw _privateConstructorUsedError; // Optional OPR ranking
  int? get OPRRank => throw _privateConstructorUsedError; // Scoring breakdown
  double get endgame_points => throw _privateConstructorUsedError;
  double get teleop_points => throw _privateConstructorUsedError;
  double get auto_points => throw _privateConstructorUsedError;
  double get climbing_points => throw _privateConstructorUsedError;
  double get mobility => throw _privateConstructorUsedError;
  double get parking => throw _privateConstructorUsedError; // Failure rate
  double get death_rate =>
      throw _privateConstructorUsedError; // Simulated rank points / RP
  int get simulated_rp => throw _privateConstructorUsedError;
  int get simulated_rank => throw _privateConstructorUsedError;

  /// Serializes this TeamStats2026 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TeamStats2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TeamStats2026CopyWith<TeamStats2026> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TeamStats2026CopyWith<$Res> {
  factory $TeamStats2026CopyWith(
          TeamStats2026 value, $Res Function(TeamStats2026) then) =
      _$TeamStats2026CopyWithImpl<$Res, TeamStats2026>;
  @useResult
  $Res call(
      {bool historical,
      String key,
      int rank,
      int team_number,
      double match_count,
      double OPR,
      int? OPRRank,
      double endgame_points,
      double teleop_points,
      double auto_points,
      double climbing_points,
      double mobility,
      double parking,
      double death_rate,
      int simulated_rp,
      int simulated_rank});
}

/// @nodoc
class _$TeamStats2026CopyWithImpl<$Res, $Val extends TeamStats2026>
    implements $TeamStats2026CopyWith<$Res> {
  _$TeamStats2026CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TeamStats2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? historical = null,
    Object? key = null,
    Object? rank = null,
    Object? team_number = null,
    Object? match_count = null,
    Object? OPR = null,
    Object? OPRRank = freezed,
    Object? endgame_points = null,
    Object? teleop_points = null,
    Object? auto_points = null,
    Object? climbing_points = null,
    Object? mobility = null,
    Object? parking = null,
    Object? death_rate = null,
    Object? simulated_rp = null,
    Object? simulated_rank = null,
  }) {
    return _then(_value.copyWith(
      historical: null == historical
          ? _value.historical
          : historical // ignore: cast_nullable_to_non_nullable
              as bool,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
      match_count: null == match_count
          ? _value.match_count
          : match_count // ignore: cast_nullable_to_non_nullable
              as double,
      OPR: null == OPR
          ? _value.OPR
          : OPR // ignore: cast_nullable_to_non_nullable
              as double,
      OPRRank: freezed == OPRRank
          ? _value.OPRRank
          : OPRRank // ignore: cast_nullable_to_non_nullable
              as int?,
      endgame_points: null == endgame_points
          ? _value.endgame_points
          : endgame_points // ignore: cast_nullable_to_non_nullable
              as double,
      teleop_points: null == teleop_points
          ? _value.teleop_points
          : teleop_points // ignore: cast_nullable_to_non_nullable
              as double,
      auto_points: null == auto_points
          ? _value.auto_points
          : auto_points // ignore: cast_nullable_to_non_nullable
              as double,
      climbing_points: null == climbing_points
          ? _value.climbing_points
          : climbing_points // ignore: cast_nullable_to_non_nullable
              as double,
      mobility: null == mobility
          ? _value.mobility
          : mobility // ignore: cast_nullable_to_non_nullable
              as double,
      parking: null == parking
          ? _value.parking
          : parking // ignore: cast_nullable_to_non_nullable
              as double,
      death_rate: null == death_rate
          ? _value.death_rate
          : death_rate // ignore: cast_nullable_to_non_nullable
              as double,
      simulated_rp: null == simulated_rp
          ? _value.simulated_rp
          : simulated_rp // ignore: cast_nullable_to_non_nullable
              as int,
      simulated_rank: null == simulated_rank
          ? _value.simulated_rank
          : simulated_rank // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TeamStats2026ImplCopyWith<$Res>
    implements $TeamStats2026CopyWith<$Res> {
  factory _$$TeamStats2026ImplCopyWith(
          _$TeamStats2026Impl value, $Res Function(_$TeamStats2026Impl) then) =
      __$$TeamStats2026ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool historical,
      String key,
      int rank,
      int team_number,
      double match_count,
      double OPR,
      int? OPRRank,
      double endgame_points,
      double teleop_points,
      double auto_points,
      double climbing_points,
      double mobility,
      double parking,
      double death_rate,
      int simulated_rp,
      int simulated_rank});
}

/// @nodoc
class __$$TeamStats2026ImplCopyWithImpl<$Res>
    extends _$TeamStats2026CopyWithImpl<$Res, _$TeamStats2026Impl>
    implements _$$TeamStats2026ImplCopyWith<$Res> {
  __$$TeamStats2026ImplCopyWithImpl(
      _$TeamStats2026Impl _value, $Res Function(_$TeamStats2026Impl) _then)
      : super(_value, _then);

  /// Create a copy of TeamStats2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? historical = null,
    Object? key = null,
    Object? rank = null,
    Object? team_number = null,
    Object? match_count = null,
    Object? OPR = null,
    Object? OPRRank = freezed,
    Object? endgame_points = null,
    Object? teleop_points = null,
    Object? auto_points = null,
    Object? climbing_points = null,
    Object? mobility = null,
    Object? parking = null,
    Object? death_rate = null,
    Object? simulated_rp = null,
    Object? simulated_rank = null,
  }) {
    return _then(_$TeamStats2026Impl(
      historical: null == historical
          ? _value.historical
          : historical // ignore: cast_nullable_to_non_nullable
              as bool,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      rank: null == rank
          ? _value.rank
          : rank // ignore: cast_nullable_to_non_nullable
              as int,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
      match_count: null == match_count
          ? _value.match_count
          : match_count // ignore: cast_nullable_to_non_nullable
              as double,
      OPR: null == OPR
          ? _value.OPR
          : OPR // ignore: cast_nullable_to_non_nullable
              as double,
      OPRRank: freezed == OPRRank
          ? _value.OPRRank
          : OPRRank // ignore: cast_nullable_to_non_nullable
              as int?,
      endgame_points: null == endgame_points
          ? _value.endgame_points
          : endgame_points // ignore: cast_nullable_to_non_nullable
              as double,
      teleop_points: null == teleop_points
          ? _value.teleop_points
          : teleop_points // ignore: cast_nullable_to_non_nullable
              as double,
      auto_points: null == auto_points
          ? _value.auto_points
          : auto_points // ignore: cast_nullable_to_non_nullable
              as double,
      climbing_points: null == climbing_points
          ? _value.climbing_points
          : climbing_points // ignore: cast_nullable_to_non_nullable
              as double,
      mobility: null == mobility
          ? _value.mobility
          : mobility // ignore: cast_nullable_to_non_nullable
              as double,
      parking: null == parking
          ? _value.parking
          : parking // ignore: cast_nullable_to_non_nullable
              as double,
      death_rate: null == death_rate
          ? _value.death_rate
          : death_rate // ignore: cast_nullable_to_non_nullable
              as double,
      simulated_rp: null == simulated_rp
          ? _value.simulated_rp
          : simulated_rp // ignore: cast_nullable_to_non_nullable
              as int,
      simulated_rank: null == simulated_rank
          ? _value.simulated_rank
          : simulated_rank // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TeamStats2026Impl implements _TeamStats2026 {
  _$TeamStats2026Impl(
      {this.historical = false,
      this.key = '',
      this.rank = 0,
      this.team_number = 0,
      this.match_count = 0.0,
      this.OPR = 0.0,
      this.OPRRank,
      this.endgame_points = 0.0,
      this.teleop_points = 0.0,
      this.auto_points = 0.0,
      this.climbing_points = 0.0,
      this.mobility = 0.0,
      this.parking = 0.0,
      this.death_rate = 0.0,
      this.simulated_rp = 0,
      this.simulated_rank = 0});

  factory _$TeamStats2026Impl.fromJson(Map<String, dynamic> json) =>
      _$$TeamStats2026ImplFromJson(json);

// Historical from backend? Default false
  @override
  @JsonKey()
  final bool historical;
// Unique key for the team, e.g., "frc6328"
  @override
  @JsonKey()
  final String key;
// Event rank
  @override
  @JsonKey()
  final int rank;
// Team number as string
  @override
  @JsonKey()
  final int team_number;
// Total matches played
  @override
  @JsonKey()
  final double match_count;
// Offensive Power Rating
  @override
  @JsonKey()
  final double OPR;
// Optional OPR ranking
  @override
  final int? OPRRank;
// Scoring breakdown
  @override
  @JsonKey()
  final double endgame_points;
  @override
  @JsonKey()
  final double teleop_points;
  @override
  @JsonKey()
  final double auto_points;
  @override
  @JsonKey()
  final double climbing_points;
  @override
  @JsonKey()
  final double mobility;
  @override
  @JsonKey()
  final double parking;
// Failure rate
  @override
  @JsonKey()
  final double death_rate;
// Simulated rank points / RP
  @override
  @JsonKey()
  final int simulated_rp;
  @override
  @JsonKey()
  final int simulated_rank;

  @override
  String toString() {
    return 'TeamStats2026(historical: $historical, key: $key, rank: $rank, team_number: $team_number, match_count: $match_count, OPR: $OPR, OPRRank: $OPRRank, endgame_points: $endgame_points, teleop_points: $teleop_points, auto_points: $auto_points, climbing_points: $climbing_points, mobility: $mobility, parking: $parking, death_rate: $death_rate, simulated_rp: $simulated_rp, simulated_rank: $simulated_rank)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TeamStats2026Impl &&
            (identical(other.historical, historical) ||
                other.historical == historical) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.rank, rank) || other.rank == rank) &&
            (identical(other.team_number, team_number) ||
                other.team_number == team_number) &&
            (identical(other.match_count, match_count) ||
                other.match_count == match_count) &&
            (identical(other.OPR, OPR) || other.OPR == OPR) &&
            (identical(other.OPRRank, OPRRank) || other.OPRRank == OPRRank) &&
            (identical(other.endgame_points, endgame_points) ||
                other.endgame_points == endgame_points) &&
            (identical(other.teleop_points, teleop_points) ||
                other.teleop_points == teleop_points) &&
            (identical(other.auto_points, auto_points) ||
                other.auto_points == auto_points) &&
            (identical(other.climbing_points, climbing_points) ||
                other.climbing_points == climbing_points) &&
            (identical(other.mobility, mobility) ||
                other.mobility == mobility) &&
            (identical(other.parking, parking) || other.parking == parking) &&
            (identical(other.death_rate, death_rate) ||
                other.death_rate == death_rate) &&
            (identical(other.simulated_rp, simulated_rp) ||
                other.simulated_rp == simulated_rp) &&
            (identical(other.simulated_rank, simulated_rank) ||
                other.simulated_rank == simulated_rank));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      historical,
      key,
      rank,
      team_number,
      match_count,
      OPR,
      OPRRank,
      endgame_points,
      teleop_points,
      auto_points,
      climbing_points,
      mobility,
      parking,
      death_rate,
      simulated_rp,
      simulated_rank);

  /// Create a copy of TeamStats2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TeamStats2026ImplCopyWith<_$TeamStats2026Impl> get copyWith =>
      __$$TeamStats2026ImplCopyWithImpl<_$TeamStats2026Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TeamStats2026ImplToJson(
      this,
    );
  }
}

abstract class _TeamStats2026 implements TeamStats2026 {
  factory _TeamStats2026(
      {final bool historical,
      final String key,
      final int rank,
      final int team_number,
      final double match_count,
      final double OPR,
      final int? OPRRank,
      final double endgame_points,
      final double teleop_points,
      final double auto_points,
      final double climbing_points,
      final double mobility,
      final double parking,
      final double death_rate,
      final int simulated_rp,
      final int simulated_rank}) = _$TeamStats2026Impl;

  factory _TeamStats2026.fromJson(Map<String, dynamic> json) =
      _$TeamStats2026Impl.fromJson;

// Historical from backend? Default false
  @override
  bool get historical; // Unique key for the team, e.g., "frc6328"
  @override
  String get key; // Event rank
  @override
  int get rank; // Team number as string
  @override
  int get team_number; // Total matches played
  @override
  double get match_count; // Offensive Power Rating
  @override
  double get OPR; // Optional OPR ranking
  @override
  int? get OPRRank; // Scoring breakdown
  @override
  double get endgame_points;
  @override
  double get teleop_points;
  @override
  double get auto_points;
  @override
  double get climbing_points;
  @override
  double get mobility;
  @override
  double get parking; // Failure rate
  @override
  double get death_rate; // Simulated rank points / RP
  @override
  int get simulated_rp;
  @override
  int get simulated_rank;

  /// Create a copy of TeamStats2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TeamStats2026ImplCopyWith<_$TeamStats2026Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
