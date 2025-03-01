import 'package:freezed_annotation/freezed_annotation.dart';

import 'scout_info.dart';

part 'pit_scouting_2025.freezed.dart';
part 'pit_scouting_2025.g.dart';

@freezed
class PitScouting2025 with _$PitScouting2025 {
  const factory PitScouting2025({
    required ScoutInfo scout_info,
    required int team_number,
    required int time,
    required String event_code,
    required PitData2025 data,
  }) = _PitScouting2025;

  factory PitScouting2025.fromJson(Map<String, dynamic> json) =>
      _$PitScouting2025FromJson(json);
}

@freezed
class PitData2025 with _$PitData2025 {
  const factory PitData2025({
    required int driver_experience_events,
    required String drive_train,
    required bool can_score_coral,
    required List<int> coral_levels,
    required bool can_score_processor,
    required bool can_score_net,
    required bool ground_coral_pickup,
    required bool feeder_coral_pickup,
    required bool ground_algae_pickup,
    required bool reef_algae_pickup,
    required List<String> climbing,
    required int spare_parts,
    required String favorite_color,
    required List<Auto2025> autos,
  }) = _PitData2025;

  factory PitData2025.fromJson(Map<String, dynamic> json) =>
      _$PitData2025FromJson(json);
}

@freezed
class Auto2025 with _$Auto2025 {
  const factory Auto2025({
    required double starting_position_meters_from_processor,
    required List<AutoStep2025> steps,
    required List<String> field_side,
    required bool exit,
    required bool preload,
    @Default(false) bool both_sides,
  }) = _Auto2025;

  factory Auto2025.fromJson(Map<String, dynamic> json) =>
      _$Auto2025FromJson(json);
}

@freezed
class AutoStep2025 with _$AutoStep2025 {
  const factory AutoStep2025({
    required String name,
    required Map<String, dynamic> extra_data,
  }) = _AutoStep2025;

  factory AutoStep2025.fromJson(Map<String, dynamic> json) =>
      _$AutoStep2025FromJson(json);
}
