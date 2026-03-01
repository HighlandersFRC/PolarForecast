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
      all_events: (json['all_events'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      data: TeamStats2026.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$GlobalRankImplToJson(_$GlobalRankImpl instance) =>
    <String, dynamic>{
      'team': instance.team,
      'eventDate': instance.eventDate.toIso8601String(),
      'event': instance.event,
      'all_events': instance.all_events,
      'data': instance.data.toJson(),
    };
