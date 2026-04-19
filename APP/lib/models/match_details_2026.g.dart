// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_details_2026.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchDetails2026Impl _$$MatchDetails2026ImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchDetails2026Impl(
      match: Match2026.fromJson(json['match'] as Map<String, dynamic>),
      prediction: json['prediction'] == null
          ? null
          : MatchPrediction2026.fromJson(
              json['prediction'] as Map<String, dynamic>),
      red_teams: (json['red_teams'] as List<dynamic>?)
          ?.map((e) => TeamStats2026.fromJson(e as Map<String, dynamic>))
          .toList(),
      blue_teams: (json['blue_teams'] as List<dynamic>?)
          ?.map((e) => TeamStats2026.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MatchDetails2026ImplToJson(
        _$MatchDetails2026Impl instance) =>
    <String, dynamic>{
      'match': instance.match.toJson(),
      'prediction': instance.prediction?.toJson(),
      'red_teams': instance.red_teams?.map((e) => e.toJson()).toList(),
      'blue_teams': instance.blue_teams?.map((e) => e.toJson()).toList(),
    };
