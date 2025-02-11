// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'picture_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PictureDataImpl _$$PictureDataImplFromJson(Map<String, dynamic> json) =>
    _$PictureDataImpl(
      user_id: json['user_id'] as String,
      team_number: (json['team_number'] as num).toInt(),
      time: (json['time'] as num).toInt(),
      event_code: json['event_code'] as String,
      image_id: json['image_id'] as String,
      link: json['link'] as String,
      permissions: (json['permissions'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$PictureDataImplToJson(_$PictureDataImpl instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'team_number': instance.team_number,
      'time': instance.time,
      'event_code': instance.event_code,
      'image_id': instance.image_id,
      'link': instance.link,
      'permissions': instance.permissions,
    };
