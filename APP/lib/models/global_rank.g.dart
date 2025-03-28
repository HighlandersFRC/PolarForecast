// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_rank.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GlobalRankImpl _$$GlobalRankImplFromJson(Map<String, dynamic> json) =>
    _$GlobalRankImpl(
      team: json['team'] as String,
      eventDate: DateTime.parse(json['eventDate'] as String),
      event: json['event'] as String,
      data: TeamStats2025.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GlobalRankImplToJson(_$GlobalRankImpl instance) =>
    <String, dynamic>{
      'team': instance.team,
      'eventDate': instance.eventDate.toIso8601String(),
      'event': instance.event,
      'data': instance.data.toJson(),
    };
