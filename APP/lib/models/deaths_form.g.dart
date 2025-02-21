// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deaths_form.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeathImpl _$$DeathImplFromJson(Map<String, dynamic> json) => _$DeathImpl(
      match_number: (json['match_number'] as num).toInt(),
      severity: (json['severity'] as num?)?.toInt() ?? -1,
      death_reason: json['death_reason'] as String? ?? '',
    );

Map<String, dynamic> _$$DeathImplToJson(_$DeathImpl instance) =>
    <String, dynamic>{
      'match_number': instance.match_number,
      'severity': instance.severity,
      'death_reason': instance.death_reason,
    };

_$DeathsImpl _$$DeathsImplFromJson(Map<String, dynamic> json) => _$DeathsImpl(
      scout_info:
          ScoutInfo.fromJson(json['scout_info'] as Map<String, dynamic>),
      event_code: json['event_code'] as String,
      team_key: json['team_key'] as String,
      deaths: (json['deaths'] as List<dynamic>?)
              ?.map((e) => Death.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      total: (json['total'] as num).toInt(),
      average: (json['average'] as num).toInt(),
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$$DeathsImplToJson(_$DeathsImpl instance) =>
    <String, dynamic>{
      'scout_info': instance.scout_info.toJson(),
      'event_code': instance.event_code,
      'team_key': instance.team_key,
      'deaths': instance.deaths.map((e) => e.toJson()).toList(),
      'total': instance.total,
      'average': instance.average,
      'time': instance.time,
    };
