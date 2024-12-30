import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'score_breakdown_2024.freezed.dart';
part 'score_breakdown_2024.g.dart';

@freezed
class ScoreBreakdown2024 with _$ScoreBreakdown2024 {
  const factory ScoreBreakdown2024({
    required int adjustPoints,
    required int autoAmpNoteCount,
    required int autoAmpNotePoints,
    required int autoLeavePoints,
    required String autoLineRobot1,
    required String autoLineRobot2,
    required String autoLineRobot3,
    required int autoPoints,
    required int autoSpeakerNoteCount,
    required int autoSpeakerNotePoints,
    required int autoTotalNotePoints,
    required bool coopNotePlayed,
    required bool coopertitionBonusAchieved,
    required bool coopertitionCriteriaMet,
    required int endGameHarmonyPoints,
    required int endGameNoteInTrapPoints,
    required int endGameOnStagePoints,
    required int endGameParkPoints,
    required String endGameRobot1,
    required String endGameRobot2,
    required String endGameRobot3,
    required int endGameSpotLightBonusPoints,
    required int endGameTotalStagePoints,
    required bool ensembleBonusAchieved,
    required int ensembleBonusOnStageRobotsThreshold,
    required int ensembleBonusStagePointsThreshold,
    required int foulCount,
    required int foulPoints,
    required bool g206Penalty,
    required bool g408Penalty,
    required bool g424Penalty,
    required bool melodyBonusAchieved,
    required int melodyBonusThreshold,
    required int melodyBonusThresholdCoop,
    required int melodyBonusThresholdNonCoop,
    required bool micCenterStage,
    required bool micStageLeft,
    required bool micStageRight,
    required int rp,
    required int techFoulCount,
    required int teleopAmpNoteCount,
    required int teleopAmpNotePoints,
    required int teleopPoints,
    required int teleopSpeakerNoteAmplifiedCount,
    required int teleopSpeakerNoteAmplifiedPoints,
    required int teleopSpeakerNoteCount,
    required int teleopSpeakerNotePoints,
    required int teleopTotalNotePoints,
    required int totalPoints,
    required bool trapCenterStage,
    required bool trapStageLeft,
    required bool trapStageRight,
  }) = _ScoreBreakdown2024;

  factory ScoreBreakdown2024.fromJson(Map<String, Object?> json) =>
      _$ScoreBreakdown2024FromJson(json);
}
