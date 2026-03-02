import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_breakdown_2026.freezed.dart';
part 'score_breakdown_2026.g.dart';

@freezed
class HubScore with _$HubScore {
  const factory HubScore({
    int? autoCount,
    int? autoPoints,
    int? endgameCount,
    int? endgamePoints,
    int? shift1Count,
    int? shift1Points,
    int? shift2Count,
    int? shift2Points,
    int? shift3Count,
    int? shift3Points,
    int? shift4Count,
    int? shift4Points,
    int? teleopCount,
    int? totalCount,
    int? totalPoints,
    int? transitionCount,
    int? transitionPoints,
    int? uncounted,
  }) = _HubScore;

  factory HubScore.fromJson(Map<String, Object?> json) =>
      _$HubScoreFromJson(json);
}

@freezed
class ScoreBreakdown2026 with _$ScoreBreakdown2026 {
  const factory ScoreBreakdown2026({
    int? adjustPoints,
    int? autoTowerPoints,
    String? autoTowerRobot1,
    String? autoTowerRobot2,
    String? autoTowerRobot3,
    int? endGameTowerPoints,
    String? endGameTowerRobot1,
    String? endGameTowerRobot2,
    String? endGameTowerRobot3,
    bool? energizedAchieved,
    int? foulPoints,
    bool? g206Penalty,
    HubScore? hubScore,
    int? majorFoulCount,
    int? minorFoulCount,
    String? penalties,
    int? rp,
    bool? superchargedAchieved,
    int? totalAutoPoints,
    int? totalPoints,
    int? totalTeleopPoints,
    int? totalTowerPoints,
    bool? traversalAchieved,
  }) = _ScoreBreakdown2026;

  factory ScoreBreakdown2026.fromJson(Map<String, Object?> json) =>
      _$ScoreBreakdown2026FromJson(json);
}
