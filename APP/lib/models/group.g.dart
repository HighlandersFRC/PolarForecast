// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      group_id: json['group_id'] as String,
      owner_group_id: json['owner_group_id'] as String,
      admin_group_id: json['admin_group_id'] as String,
      member_group_id: json['member_group_id'] as String,
      name: json['name'] as String,
      affiliation: json['affiliation'] as String,
      join_code: json['join_code'] as String,
      events: (json['events'] as List<dynamic>)
          .map((e) => GroupEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings:
          GroupSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'group_id': instance.group_id,
      'owner_group_id': instance.owner_group_id,
      'admin_group_id': instance.admin_group_id,
      'member_group_id': instance.member_group_id,
      'name': instance.name,
      'affiliation': instance.affiliation,
      'join_code': instance.join_code,
      'events': instance.events.map((e) => e.toJson()).toList(),
      'settings': instance.settings.toJson(),
    };

_$GroupEventImpl _$$GroupEventImplFromJson(Map<String, dynamic> json) =>
    _$GroupEventImpl(
      event_code: json['event_code'] as String,
      settings:
          GroupEventSettings.fromJson(json['settings'] as Map<String, dynamic>),
      alliance_groups: (json['alliance_groups'] as List<dynamic>)
          .map((e) => AllianceGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$GroupEventImplToJson(_$GroupEventImpl instance) =>
    <String, dynamic>{
      'event_code': instance.event_code,
      'settings': instance.settings.toJson(),
      'alliance_groups':
          instance.alliance_groups.map((e) => e.toJson()).toList(),
    };

_$GroupEventSettingsImpl _$$GroupEventSettingsImplFromJson(
        Map<String, dynamic> json) =>
    _$GroupEventSettingsImpl(
      crowd_sourced_match_scouting:
          json['crowd_sourced_match_scouting'] as bool,
      crowd_sourced_pit_scouting: json['crowd_sourced_pit_scouting'] as bool,
    );

Map<String, dynamic> _$$GroupEventSettingsImplToJson(
        _$GroupEventSettingsImpl instance) =>
    <String, dynamic>{
      'crowd_sourced_match_scouting': instance.crowd_sourced_match_scouting,
      'crowd_sourced_pit_scouting': instance.crowd_sourced_pit_scouting,
    };

_$AllianceGroupImpl _$$AllianceGroupImplFromJson(Map<String, dynamic> json) =>
    _$AllianceGroupImpl(
      group_id: json['group_id'] as String,
      name: json['name'] as String,
      affiliation: json['affiliation'] as String,
    );

Map<String, dynamic> _$$AllianceGroupImplToJson(_$AllianceGroupImpl instance) =>
    <String, dynamic>{
      'group_id': instance.group_id,
      'name': instance.name,
      'affiliation': instance.affiliation,
    };

_$GroupSettingsImpl _$$GroupSettingsImplFromJson(Map<String, dynamic> json) =>
    _$GroupSettingsImpl(
      approve_new_members: json['approve_new_members'] as bool,
    );

Map<String, dynamic> _$$GroupSettingsImplToJson(_$GroupSettingsImpl instance) =>
    <String, dynamic>{
      'approve_new_members': instance.approve_new_members,
    };
