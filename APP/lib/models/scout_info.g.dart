// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scout_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScoutInfoImpl _$$ScoutInfoImplFromJson(Map<String, dynamic> json) =>
    _$ScoutInfoImpl(
      user_id: json['user_id'] as String,
      first_name: json['first_name'] as String,
      username: json['username'] as String,
      team_number: (json['team_number'] as num).toInt(),
    );

Map<String, dynamic> _$$ScoutInfoImplToJson(_$ScoutInfoImpl instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'first_name': instance.first_name,
      'username': instance.username,
      'team_number': instance.team_number,
    };
