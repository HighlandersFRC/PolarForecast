import 'package:freezed_annotation/freezed_annotation.dart';
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
    required double time,
    required PitData2026 data,
    Auto2026? auto,
  }) = _PitScouting2026;
  factory PitScouting2026.fromJson(Map<String, dynamic> json) =>
      _$PitScouting2026FromJson(json);
}

@freezed
class PitData2026 with _$PitData2026 {
  const factory PitData2026(
      {required int driver_experience_events,
      required String drive_train,
      required String type_of_shooter,
      required bool fixedShooting,
      required bool nearTower,
      required bool nearHub,
      required bool go_under_trench,
      required bool can_climb,
      required List<int> climbing,
      required bool can_climb_in_autonomous,
      required String main_strategy,
      required int spare_parts,
      required String favorite_color,
      Auto2026? auto,
      required int hopper_capacity,
      required double bps,
      required String comments,
      // keep autos dynamic to avoid type-mismatch with other code/widgets
      List<Auto2026>? autos,
      required double robot_height,
      required bool straddling_pole_climb_right,
      required bool straddling_pole_climb_left,
      required bool left_pole_climb,
      required bool right_pole_climb,
      required bool center_pole_climb}) = _PitData2026;
  factory PitData2026.fromJson(Map<String, dynamic> json) =>
      _$PitData2026FromJson(json);
}

@freezed
class Auto2026 with _$Auto2026 {
  factory Auto2026({
    required double starting_position_meters_from_hub_center,
    required List<String> field_side,
    required List<AutoStep2026> steps,
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
  }) = _Data;

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);
}
