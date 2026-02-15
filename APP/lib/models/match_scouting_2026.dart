import 'package:freezed_annotation/freezed_annotation.dart';
import 'scout_info.dart';
import 'pit_scouting_2026.dart';

part 'match_scouting_2026.freezed.dart';
part 'match_scouting_2026.g.dart';

@freezed
class MatchScouting2026 with _$MatchScouting2026 {
  factory MatchScouting2026({
    required String event_code,
    required int team_number,
    required int match_number,
    required ScoutInfo scout_info,
    required Data data,
    required int time,
  }) = _MatchScouting2026;

  factory MatchScouting2026.fromJson(Map<String, dynamic> json) =>
      _$MatchScouting2026FromJson(json);
}

@freezed
class Data with _$Data {
  factory Data({
    required Auto2026 auto,
    required AutoScoring auto_scoring,
    required TeleopScoring teleop_scoring,
    required Miscellaneous miscellaneous,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@freezed
class AutoScoring with _$AutoScoring {
  factory AutoScoring({
    required int feed_amount,
    required int intake_amount,
    required int shoot_amount,
    required int cycles_completed,
    required String climb_side,
  }) = _AutoScoring;

  factory AutoScoring.fromJson(Map<String, dynamic> json) =>
      _$AutoScoringFromJson(json);
}

@freezed
class TeleopScoring with _$TeleopScoring {
  factory TeleopScoring({
    required int cycles_completed,
    required int shoot_amount,
  }) = _TeleopScoring;

  factory TeleopScoring.fromJson(Map<String, dynamic> json) =>
      _$TeleopScoringFromJson(json);
}

@freezed
class Miscellaneous with _$Miscellaneous {
  factory Miscellaneous({
    required bool died,
    required String comments,
  }) = _Miscellaneous;

  factory Miscellaneous.fromJson(Map<String, dynamic> json) =>
      _$MiscellaneousFromJson(json);
}
