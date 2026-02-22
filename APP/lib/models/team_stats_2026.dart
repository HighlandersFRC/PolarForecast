import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_stats_2026.freezed.dart';
part 'team_stats_2026.g.dart';

@freezed
class TeamStats2026 with _$TeamStats2026 {
  factory TeamStats2026({
    // Historical from backend? Default false
    @Default(false) bool historical,

    // Unique key for the team, e.g., "frc6328"
    @Default('') String key,

    // Event rank
    @Default(0) int rank,

    // Team number as string
    @Default(0) int team_number,

    // Total matches played
    @Default(0.0) double match_count,

    // Offensive Power Rating
    @Default(0.0) double OPR,

    // Optional OPR ranking
    int? OPRRank,

    // Scoring breakdown
    @Default(0.0) double endgame_points,
    @Default(0.0) double teleop_points,
    @Default(0.0) double auto_points,
    @Default(0.0) double climbing_points,
    @Default(0.0) double mobility,
    @Default(0.0) double parking,

    // Failure rate
    @Default(0.0) double death_rate,

    // Simulated rank points / RP
    @Default(0) int simulated_rp,
    @Default(0) int simulated_rank,
  }) = _TeamStats2026;

  factory TeamStats2026.fromJson(Map<String, dynamic> json) =>
      _$TeamStats2026FromJson(json);
}
