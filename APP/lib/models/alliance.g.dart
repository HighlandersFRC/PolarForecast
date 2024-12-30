// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alliance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AllianceImpl _$$AllianceImplFromJson(Map<String, dynamic> json) =>
    _$AllianceImpl(
      dq_team_keys: (json['dq_team_keys'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      surrogate_team_keys: (json['surrogate_team_keys'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      team_keys:
          (json['team_keys'] as List<dynamic>).map((e) => e as String).toList(),
      score: (json['score'] as num).toInt(),
    );

Map<String, dynamic> _$$AllianceImplToJson(_$AllianceImpl instance) =>
    <String, dynamic>{
      'dq_team_keys': instance.dq_team_keys,
      'surrogate_team_keys': instance.surrogate_team_keys,
      'team_keys': instance.team_keys,
      'score': instance.score,
    };
