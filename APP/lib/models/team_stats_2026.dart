import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_stats_2026.freezed.dart';
part 'team_stats_2026.g.dart';

@freezed
class TeamStats2026 with _$TeamStats2026 {
  factory TeamStats2026({
    required bool historical,
    required String key,
    required int rank,
    required String team_number,
    @Default(0) double match_count,
    @Default(0.0) double OPR,
    int? OPRRank,
    @Default(0.0) double total_pass,
    @Default(0.0) double auto_pass,
    @Default(0.0) double teleop_pass,
    @Default(0.0) double endgame_points,
    @Default(0.0) double teleop_points,
    @Default(0.0) double auto_points,
    @Default(0.0) double climbing_points,
    @Default(0.0) double death_rate,
    @Default(0.0) double defense_rate,
    @Default(0.0) double auto_fuel_scored,
    @Default(0.0) double teleop_fuel_scored,
    @Default(0.0) double total_fuel_scored,
    @Default(0.0) double foul_points,
    @Default(0) int simulated_rp,
    @Default(0) int simulated_rank,
  }) = _TeamStats2026;

  factory TeamStats2026.fromJson(Map<String, dynamic> json) =>
      _$TeamStats2026FromJson(json);
}
