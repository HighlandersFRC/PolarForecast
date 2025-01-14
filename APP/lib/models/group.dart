import 'package:freezed_annotation/freezed_annotation.dart';

part 'group.freezed.dart';
part 'group.g.dart';

@freezed
class Group with _$Group {
  const factory Group({
    required String group_id,
    required String name,
    required String join_code,
    required List<GroupEvent> events,
    required GroupSettings settings,
  }) = _Group;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
}

@freezed
class GroupEvent with _$GroupEvent {
  const factory GroupEvent({
    required String event_code,
    required GroupEventSettings settings,
  }) = _GroupEvent;

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
class GroupSettings with _$GroupSettings {
  const factory GroupSettings({
    required bool approve_new_members,
  }) = _GroupSettings;

  factory GroupSettings.fromJson(Map<String, dynamic> json) =>
      _$GroupSettingsFromJson(json);
}
