// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alliances.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlliancesImpl _$$AlliancesImplFromJson(Map<String, dynamic> json) =>
    _$AlliancesImpl(
      red: Alliance.fromJson(json['red'] as Map<String, dynamic>),
      blue: Alliance.fromJson(json['blue'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$AlliancesImplToJson(_$AlliancesImpl instance) =>
    <String, dynamic>{
      'red': instance.red.toJson(),
      'blue': instance.blue.toJson(),
    };
