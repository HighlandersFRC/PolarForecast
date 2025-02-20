// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_details_2025.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchDetails2025Impl _$$MatchDetails2025ImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchDetails2025Impl(
      match: Match2025.fromJson(json['match'] as Map<String, dynamic>),
      prediction: MatchPrediction2025.fromJson(
          json['prediction'] as Map<String, dynamic>),
      red_teams: (json['red_teams'] as List<dynamic>)
          .map((e) => TeamStats2025.fromJson(e as Map<String, dynamic>))
          .toList(),
      blue_teams: (json['blue_teams'] as List<dynamic>)
          .map((e) => TeamStats2025.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MatchDetails2025ImplToJson(
        _$MatchDetails2025Impl instance) =>
    <String, dynamic>{
      'match': instance.match.toJson(),
      'prediction': instance.prediction.toJson(),
      'red_teams': instance.red_teams.map((e) => e.toJson()).toList(),
      'blue_teams': instance.blue_teams.map((e) => e.toJson()).toList(),
    };
