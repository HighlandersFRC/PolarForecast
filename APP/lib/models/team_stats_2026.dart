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
    required double match_count,
    required double OPR,
    int? OPRRank,
    required double total_pass,
    required double auto_pass,
    required double teleop_pass,
    required double endgame_points,
    required double teleop_points,
    required double auto_points,
    required double climbing_points,
    required double death_rate,
    required double auto_fuel_cycles,
    required double teleop_fuel_cycles,
    required double foul_points,
    required int simulated_rp,
    required int simulated_rank,
  }) = _TeamStats2026;

  factory TeamStats2026.fromJson(Map<String, dynamic> json) =>
      _$TeamStats2026FromJson(json);
}
