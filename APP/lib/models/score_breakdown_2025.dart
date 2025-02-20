import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_breakdown_2025.freezed.dart';
part 'score_breakdown_2025.g.dart';

@freezed
class ScoreBreakdown2025 with _$ScoreBreakdown2025 {
  const factory ScoreBreakdown2025({
    required int adjustPoints,
    required int algaePoints,
    required bool autoBonusAchieved,
    required int autoCoralCount,
    required int autoCoralPoints,
    required String autoLineRobot1,
    required String autoLineRobot2,
    required String autoLineRobot3,
    required int autoMobilityPoints,
    required int autoPoints,
    required Reef autoReef,
    required bool bargeBonusAchieved,
    required bool coopertitionCriteriaMet,
    required bool coralBonusAchieved,
    required int endGameBargePoints,
    required String endGameRobot1,
    required String endGameRobot2,
    required String endGameRobot3,
    required int foulPoints,
    required bool g206Penalty,
    required bool g408Penalty,
    required bool g424Penalty,
    required int netAlgaeCount,
    required int rp,
    required int techFoulCount,
    required int teleopCoralCount,
    required int teleopCoralPoints,
    required int teleopPoints,
    required Reef teleopReef,
    required int totalPoints,
    required int wallAlgaeCount,
  }) = _ScoreBreakdown2025;

  factory ScoreBreakdown2025.fromJson(Map<String, Object?> json) =>
      _$ScoreBreakdown2025FromJson(json);
}

@freezed
class Reef with _$Reef {
  const factory Reef(
      {required ReefRow botRow,
      required ReefRow midRow,
      required ReefRow topRow,
      required int trough}) = _Reef;

  factory Reef.fromJson(Map<String, Object?> json) => _$ReefFromJson(json);
}

@freezed
class ReefRow with _$ReefRow {
  const factory ReefRow({
    required bool nodeA,
    required bool nodeB,
    required bool nodeC,
    required bool nodeD,
    required bool nodeE,
    required bool nodeF,
    required bool nodeG,
    required bool nodeH,
    required bool nodeI,
    required bool nodeJ,
    required bool nodeK,
    required bool nodeL,
  }) = _ReefRow;

  factory ReefRow.fromJson(Map<String, Object?> json) =>
      _$ReefRowFromJson(json);
}
