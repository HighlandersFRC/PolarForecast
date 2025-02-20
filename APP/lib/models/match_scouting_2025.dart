import 'package:freezed_annotation/freezed_annotation.dart';
import 'pit_scouting_2025.dart';

import 'scout_info.dart';

part 'match_scouting_2025.freezed.dart';
part 'match_scouting_2025.g.dart';

@freezed
class MatchScouting2025 with _$MatchScouting2025 {
  factory MatchScouting2025({
    required String event_code,
    required int team_number,
    required int match_number,
    required ScoutInfo scout_info,
    required Data data,
    required int time,
  }) = _MatchScouting2025;

  factory MatchScouting2025.fromJson(Map<String, dynamic> json) =>
      _$MatchScouting2025FromJson(json);
}

@freezed
class Data with _$Data {
  factory Data({
    required Auto2025 auto,
    required AutoScoring auto_scoring,
    required TeleopScoring teleop_scoring,
    required Miscellaneous miscellaneous,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}

@freezed
class AutoScoring with _$AutoScoring {
  factory AutoScoring({
    required int l_1,
    required int l_2,
    required int l_3,
    required int l_4,
    required int net,
    required int processor,
  }) = _AutoScoring;

  factory AutoScoring.fromJson(Map<String, dynamic> json) =>
      _$AutoScoringFromJson(json);
}

@freezed
class TeleopScoring with _$TeleopScoring {
  factory TeleopScoring({
    required int l_1,
    required int l_2,
    required int l_3,
    required int l_4,
    required int net,
    required int processor,
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
