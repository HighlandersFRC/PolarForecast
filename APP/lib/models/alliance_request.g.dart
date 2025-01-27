// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alliance_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AllianceRequestImpl _$$AllianceRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$AllianceRequestImpl(
      group_1: json['group_1'] as String,
      group_2: json['group_2'] as String,
      group_1_affiliation: json['group_1_affiliation'] as String,
      group_2_affiliation: json['group_2_affiliation'] as String,
      event: json['event'] as String,
      request_time: (json['request_time'] as num).toInt(),
      accepted: json['accepted'] as bool,
    );

Map<String, dynamic> _$$AllianceRequestImplToJson(
        _$AllianceRequestImpl instance) =>
    <String, dynamic>{
      'group_1': instance.group_1,
      'group_2': instance.group_2,
      'group_1_affiliation': instance.group_1_affiliation,
      'group_2_affiliation': instance.group_2_affiliation,
      'event': instance.event,
      'request_time': instance.request_time,
      'accepted': instance.accepted,
    };
