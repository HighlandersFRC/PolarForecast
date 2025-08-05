// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scouting_report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScoutingReportImpl _$$ScoutingReportImplFromJson(Map<String, dynamic> json) =>
    _$ScoutingReportImpl(
      group: json['group'] as String,
      event: json['event'] as String,
      report: (json['report'] as List<dynamic>)
          .map((e) => ScoutingReportEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$ScoutingReportImplToJson(
        _$ScoutingReportImpl instance) =>
    <String, dynamic>{
      'group': instance.group,
      'event': instance.event,
      'report': instance.report.map((e) => e.toJson()).toList(),
    };

_$ScoutingReportEntryImpl _$$ScoutingReportEntryImplFromJson(
        Map<String, dynamic> json) =>
    _$ScoutingReportEntryImpl(
      scouts: (json['scouts'] as List<dynamic>)
          .map((e) => ScoutingReportScout.fromJson(e as Map<String, dynamic>))
          .toList(),
      eventCode: json['eventCode'] as String,
      groupId: json['groupId'] as String,
      trustRatings: (json['trustRatings'] as num).toDouble(),
      entries: (json['entries'] as num).toDouble(),
      contribution: (json['contribution'] as num).toDouble(),
    );

Map<String, dynamic> _$$ScoutingReportEntryImplToJson(
        _$ScoutingReportEntryImpl instance) =>
    <String, dynamic>{
      'scouts': instance.scouts.map((e) => e.toJson()).toList(),
      'eventCode': instance.eventCode,
      'groupId': instance.groupId,
      'trustRatings': instance.trustRatings,
      'entries': instance.entries,
      'contribution': instance.contribution,
    };

_$ScoutingReportScoutImpl _$$ScoutingReportScoutImplFromJson(
        Map<String, dynamic> json) =>
    _$ScoutingReportScoutImpl(
      name: ScoutingReportUser.fromJson(json['name'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ScoutingReportScoutImplToJson(
        _$ScoutingReportScoutImpl instance) =>
    <String, dynamic>{
      'name': instance.name.toJson(),
    };

_$ScoutingReportUserImpl _$$ScoutingReportUserImplFromJson(
        Map<String, dynamic> json) =>
    _$ScoutingReportUserImpl(
      user_id: json['user_id'] as String,
      first_name: json['first_name'] as String?,
      username: json['username'] as String?,
      team_number: (json['team_number'] as num).toInt(),
    );

Map<String, dynamic> _$$ScoutingReportUserImplToJson(
        _$ScoutingReportUserImpl instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'first_name': instance.first_name,
      'username': instance.username,
      'team_number': instance.team_number,
    };
