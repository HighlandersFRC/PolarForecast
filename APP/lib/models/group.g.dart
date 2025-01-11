// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupImpl _$$GroupImplFromJson(Map<String, dynamic> json) => _$GroupImpl(
      name: json['name'] as String,
      surrogate_team_keys: (json['surrogate_team_keys'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      team_keys:
          (json['team_keys'] as List<dynamic>).map((e) => e as String).toList(),
      score: (json['score'] as num).toInt(),
    );

Map<String, dynamic> _$$GroupImplToJson(_$GroupImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'surrogate_team_keys': instance.surrogate_team_keys,
      'team_keys': instance.team_keys,
      'score': instance.score,
    };
