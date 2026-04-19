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
      scout: ScoutInfo.fromJson(json['scout'] as Map<String, dynamic>),
      eventCode: json['eventCode'] as String,
      groupId: json['groupId'] as String,
      trustRatings: (json['trustRatings'] as num).toDouble(),
      entries: (json['entries'] as num).toDouble(),
      contribution: (json['contribution'] as num).toDouble(),
    );

Map<String, dynamic> _$$ScoutingReportEntryImplToJson(
        _$ScoutingReportEntryImpl instance) =>
    <String, dynamic>{
      'scout': instance.scout.toJson(),
      'eventCode': instance.eventCode,
      'groupId': instance.groupId,
      'trustRatings': instance.trustRatings,
      'entries': instance.entries,
      'contribution': instance.contribution,
    };
