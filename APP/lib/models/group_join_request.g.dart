// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_join_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GroupJoinRequestImpl _$$GroupJoinRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$GroupJoinRequestImpl(
      group_name: json['group_name'] as String,
      group_id: json['group_id'] as String,
      user_id: json['user_id'] as String,
      username: json['username'] as String,
      request_time: (json['request_time'] as num).toInt(),
      accepted: json['accepted'] as bool,
    );

Map<String, dynamic> _$$GroupJoinRequestImplToJson(
        _$GroupJoinRequestImpl instance) =>
    <String, dynamic>{
      'group_name': instance.group_name,
      'group_id': instance.group_id,
      'user_id': instance.user_id,
      'username': instance.username,
      'request_time': instance.request_time,
      'accepted': instance.accepted,
    };
