import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_prediction_2026.freezed.dart';
part 'match_prediction_2026.g.dart';

@freezed
class MatchPrediction2026 with _$MatchPrediction2026 {
  const factory MatchPrediction2026({
    String? comp_level,
    String? key,
    int? match_number,
    int? set_number,
    List<String>? blue_teams,
    double? blue_score,
    double? blue_climbing,
    double? blue_auto_points,
    double? blue_teleop_points,
    double? blue_endgame_points,
    int? blue_actual_score,
    List<String>? red_teams,
    double? red_score,
    double? red_climbing,
    double? red_auto_points,
    double? red_teleop_points,
    double? red_endgame_points,
    int? red_actual_score,
    bool? predicted,
    int? blue_win_rp,
    int? blue_auto_rp,
    int? blue_total_rp,
    int? blue_display_rp,
    int? red_win_rp,
    int? red_total_rp,
    int? red_display_rp,
  }) = _MatchPrediction2026;

  factory MatchPrediction2026.fromJson(Map<String, Object?> json) =>
      _$MatchPrediction2026FromJson(json);
}
