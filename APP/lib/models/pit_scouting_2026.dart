import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scouting_app/models/match_scouting_2026.dart';
import 'package:scouting_app/models/scout_info.dart';
part 'pit_scouting_2026.freezed.dart';
part 'pit_scouting_2026.g.dart';

@freezed
class PitScouting2026 with _$PitScouting2026 {
  const factory PitScouting2026({
    required String user_id,
    required ScoutInfo scout_info,
    required int team_number,
    required String event_code,
    required int time,
    required PitData2026 data,
    Auto2026? auto,
  }) = _PitScouting2026;
  factory PitScouting2026.fromJson(Map<String, dynamic> json) =>
      _$PitScouting2026FromJson(json);
}

@freezed
class PitData2026 with _$PitData2026 {
  const factory PitData2026({
    required int driver_experience_events,
    required String drive_train,
    required bool can_feed_human_player,
    required bool can_pick_up_from_ground,
    required int distance_to_shoot,
    required int cycles_in_25_seconds,
    required int cycle_time,
    required bool go_over_bump,
    required bool go_under_trench,
    required bool can_climb,
    required List<int> climbing,
    required bool can_climb_in_autonomous,
    required bool can_climb_with_others,
    required bool automatically_shooting,
    required bool shooting_while_moving,
    required String main_strategy,
    required int spare_parts,
    required String favorite_color,
    Auto2026? auto,
    required AutoScoring auto_scoring,
    // keep autos dynamic to avoid type-mismatch with other code/widgets
    required List<dynamic> autos,
  }) = _PitData2026;
  factory PitData2026.fromJson(Map<String, dynamic> json) =>
      _$PitData2026FromJson(json);
}

@freezed
class Auto2026 with _$Auto2026 {
  factory Auto2026({
    required double starting_position_meters_from_hub_center,
    required List<dynamic> steps,
    required List<String> field_side,
    required bool preload,
    required bool climb,
    required bool contacts_robot,
    @Default(false) bool both_sides,
    @JsonKey(name: 'auto_pieces')
    @Default(0)
    int autoPieces, // <-- NEW COUNTER FIELD
  }) = _Auto2026;

  factory Auto2026.fromJson(Map<String, dynamic> json) =>
      _$Auto2026FromJson(json);
}

@freezed
class AutoStep2026 with _$AutoStep2026 {
  const factory AutoStep2026({
    required String name,
    required Map<String, dynamic> extra_data,
  }) = _AutoStep2026;
  factory AutoStep2026.fromJson(Map<String, dynamic> json) =>
      _$AutoStep2026FromJson(json);
}

@freezed
class Data with _$Data {
  factory Data({
    required Auto2026 auto,
    required AutoScoring auto_scoring,
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
