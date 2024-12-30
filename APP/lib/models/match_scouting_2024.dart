import 'package:freezed_annotation/freezed_annotation.dart';

part 'match_scouting_2024.freezed.dart';
part 'match_scouting_2024.g.dart';

@freezed
class MatchScouting2024 with _$MatchScouting2024 {
  const factory MatchScouting2024({
    required String event_code,
    required String team_number,
    required int match_number,
    required bool active,
    required ScoutInfo2024 scout_info,
    required MatchData2024 data,
    required int time,
  }) = _MatchScouting2024;

  factory MatchScouting2024.fromJson(Map<String, dynamic> json) =>
      _$MatchScouting2024FromJson(json);
}

@freezed
class ScoutInfo2024 with _$ScoutInfo2024 {
  const factory ScoutInfo2024({
    required String name,
  }) = _ScoutInfo2024;

  factory ScoutInfo2024.fromJson(Map<String, dynamic> json) =>
      _$ScoutInfo2024FromJson(json);
}

@freezed
class MatchData2024 with _$MatchData2024 {
  const factory MatchData2024({
    required AutoData2024 auto,
    required TeleopData2024 teleop,
    required MiscellaneousData2024 miscellaneous,
    List<String>? selectedPieces,
  }) = _MatchData2024;

  factory MatchData2024.fromJson(Map<String, dynamic> json) =>
      _$MatchData2024FromJson(json);
}

@freezed
class AutoData2024 with _$AutoData2024 {
  const factory AutoData2024({
    required int amp,
    required int speaker,
  }) = _AutoData2024;

  factory AutoData2024.fromJson(Map<String, dynamic> json) =>
      _$AutoData2024FromJson(json);
}

@freezed
class TeleopData2024 with _$TeleopData2024 {
  const factory TeleopData2024({
    required int amp,
    required int speaker,
    required int amped_speaker,
    int? pass,
  }) = _TeleopData2024;

  factory TeleopData2024.fromJson(Map<String, dynamic> json) =>
      _$TeleopData2024FromJson(json);
}

@freezed
class MiscellaneousData2024 with _$MiscellaneousData2024 {
  const factory MiscellaneousData2024({
    required bool died,
    required String comments,
  }) = _MiscellaneousData2024;

  factory MiscellaneousData2024.fromJson(Map<String, dynamic> json) =>
      _$MiscellaneousData2024FromJson(json);
}
