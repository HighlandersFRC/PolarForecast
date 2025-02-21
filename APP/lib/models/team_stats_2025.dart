import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_stats_2025.freezed.dart';
part 'team_stats_2025.g.dart';

@freezed
class TeamStats2025 with _$TeamStats2025 {
  factory TeamStats2025({
    required bool historical,
    required String key,
    required int rank,
    required String team_number,
    required double match_count,
    required double OPR,
    required double endgame_points,
    required double teleop_points,
    required double auto_points,
    required double l_4_total,
    required double l_3_total,
    required double l_2_total,
    required double l_1_total,
    required double total_pieces,
    required double algae_total,
    required double algae_points,
    required double coral_total,
    required double coral_points,
    required double teleop_coral_points,
    required double teleop_coral,
    required double auto_coral_points,
    required double auto_coral,
    required double shallow_climb_rate,
    required double deep_climb_rate,
    required double climbing_points,
    required double mobility,
    required double death_rate,
    required double parking,
    required double auto_scoring_l_1,
    required double auto_scoring_l_2,
    required double auto_scoring_l_3,
    required double auto_scoring_l_4,
    required double teleop_scoring_l_1,
    required double teleop_scoring_l_2,
    required double teleop_scoring_l_3,
    required double teleop_scoring_l_4,
    required double net,
    required double processor,
    required double foul_points,
    required double coopertition,
    required int simulated_rp,
    required int simulated_rank,
  }) = _TeamStats2025;

  factory TeamStats2025.fromJson(Map<String, dynamic> json) =>
      _$TeamStats2025FromJson(json);
}
