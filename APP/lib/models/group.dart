import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

@freezed
class Picks with _$Picks {
  const factory Picks({required String number, required String comments}) =
      _Picks;

  factory Picks.fromJson(Map<String, dynamic> json) => _$PicksFromJson(json);
}

@freezed
class Picklist2026 with _$Picklist2026 {
  const factory Picklist2026({
    required String picklist_id,
    required String name,
    required List<Picks> picks,
  }) = _Picklist2026;

  factory Picklist2026.fromJson(Map<String, dynamic> json) =>
      _$Picklist2026FromJson(json);
}

@freezed
class Group with _$Group {
  const factory Group({
    required String group_id,
    required String owner_group_id,
    required String admin_group_id,
    required String member_group_id,
    required String name,
    required String affiliation,
    required String? join_code,
    required List<GroupEvent> events,
    required GroupSettings settings,
    required int last_update, // Added last_update field
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
class GroupEvent with _$GroupEvent {
  const factory GroupEvent(
      {required String event_code,
      required bool up_to_date,
      required GroupEventSettings settings,
      required List<AllianceGroup> alliance_groups,
      required List<Picklist2026> picklists}) = _GroupEvent;

  factory GroupEvent.fromJson(Map<String, dynamic> json) =>
      _$GroupEventFromJson(json);
}

@freezed
class GroupEventSettings with _$GroupEventSettings {
  const factory GroupEventSettings({
    required bool crowd_sourced_match_scouting,
    required bool crowd_sourced_pit_scouting,
  }) = _GroupEventSettings;

  factory GroupEventSettings.fromJson(Map<String, dynamic> json) =>
      _$GroupEventSettingsFromJson(json);
}

@freezed
class AllianceGroup with _$AllianceGroup {
  const factory AllianceGroup({
    required String group_id,
    required String name,
    required String affiliation,
  }) = _AllianceGroup;

  factory AllianceGroup.fromJson(Map<String, dynamic> json) =>
      _$AllianceGroupFromJson(json);
}

@freezed
class GroupSettings with _$GroupSettings {
  const factory GroupSettings({
    required bool approve_new_members,
  }) = _GroupSettings;

  factory GroupSettings.fromJson(Map<String, dynamic> json) =>
      _$GroupSettingsFromJson(json);
}
