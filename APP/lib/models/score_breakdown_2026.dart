import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_breakdown_2026.freezed.dart';
part 'score_breakdown_2026.g.dart';

@freezed
class HubScore with _$HubScore {
  const factory HubScore({
    required int autoCount,
    required int autoPoints,
    required int endgameCount,
    required int endgamePoints,
    required int shift1Count,
    required int shift1Points,
    required int shift2Count,
    required int shift2Points,
    required int shift3Count,
    required int shift3Points,
    required int shift4Count,
    required int shift4Points,
    required int teleopCount,
    required int totalCount,
    required int totalPoints,
    required int transitionCount,
    required int transitionPoints,
    required int uncounted,
  }) = _HubScore;

  factory HubScore.fromJson(Map<String, Object?> json) =>
      _$HubScoreFromJson(json);
}

@freezed
class ScoreBreakdown2026 with _$ScoreBreakdown2026 {
  const factory ScoreBreakdown2026(
      {required int adjustPoints,
      required int autoTowerPoints,
      required String autoTowerRobot1,
      required String autoTowerRobot2,
      required String autoTowerRobot3,
      required int endGameTowerPoints,
      required String endGameTowerRobot1,
      required String endGameTowerRobot2,
      required String endGameTowerRobot3,
      required bool energizedAchieved,
      required int foulPoints,
      required bool g206Penalty,
      required HubScore hubScore,
      required int majorFoulCount,
      required int minorFoulCount,
      required String penalties,
      required int rp,
      required bool superchargedAchieved,
      required int totalAutoPoints,
      required int totalPoints,
      required int totalTeleopPoints,
      required int totalTowerPoints,
      required int traversalAchieved}) = _ScoreBreakdown2026;

  factory ScoreBreakdown2026.fromJson(Map<String, Object?> json) =>
      _$ScoreBreakdown2026FromJson(json);
}
