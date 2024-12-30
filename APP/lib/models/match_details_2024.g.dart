// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_details_2024.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchDetails2024Impl _$$MatchDetails2024ImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchDetails2024Impl(
      match: Match2024.fromJson(json['match'] as Map<String, dynamic>),
      prediction: MatchPrediction2024.fromJson(
          json['prediction'] as Map<String, dynamic>),
      red_teams: (json['red_teams'] as List<dynamic>)
          .map((e) => TeamStats2024.fromJson(e as Map<String, dynamic>))
          .toList(),
      blue_teams: (json['blue_teams'] as List<dynamic>)
          .map((e) => TeamStats2024.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$MatchDetails2024ImplToJson(
        _$MatchDetails2024Impl instance) =>
    <String, dynamic>{
      'match': instance.match.toJson(),
      'prediction': instance.prediction.toJson(),
      'red_teams': instance.red_teams.map((e) => e.toJson()).toList(),
      'blue_teams': instance.blue_teams.map((e) => e.toJson()).toList(),
    };
