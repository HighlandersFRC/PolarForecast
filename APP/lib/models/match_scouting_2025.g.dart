// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_scouting_2025.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchScouting2025Impl _$$MatchScouting2025ImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchScouting2025Impl(
      event_code: json['event_code'] as String,
      team_number: (json['team_number'] as num).toInt(),
      match_number: (json['match_number'] as num).toInt(),
      scout_info:
          ScoutInfo.fromJson(json['scout_info'] as Map<String, dynamic>),
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchScouting2025ImplToJson(
        _$MatchScouting2025Impl instance) =>
    <String, dynamic>{
      'event_code': instance.event_code,
      'team_number': instance.team_number,
      'match_number': instance.match_number,
      'scout_info': instance.scout_info.toJson(),
      'data': instance.data.toJson(),
      'time': instance.time,
    };

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
      auto: Auto2025.fromJson(json['auto'] as Map<String, dynamic>),
      auto_scoring:
          AutoScoring.fromJson(json['auto_scoring'] as Map<String, dynamic>),
      teleop_scoring: TeleopScoring.fromJson(
          json['teleop_scoring'] as Map<String, dynamic>),
      miscellaneous:
          Miscellaneous.fromJson(json['miscellaneous'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'auto': instance.auto.toJson(),
      'auto_scoring': instance.auto_scoring.toJson(),
      'teleop_scoring': instance.teleop_scoring.toJson(),
      'miscellaneous': instance.miscellaneous.toJson(),
    };

_$AutoScoringImpl _$$AutoScoringImplFromJson(Map<String, dynamic> json) =>
    _$AutoScoringImpl(
      l1: (json['l1'] as num).toInt(),
      l2: (json['l2'] as num).toInt(),
      l3: (json['l3'] as num).toInt(),
      l4: (json['l4'] as num).toInt(),
      net: (json['net'] as num).toInt(),
      processor: (json['processor'] as num).toInt(),
    );

Map<String, dynamic> _$$AutoScoringImplToJson(_$AutoScoringImpl instance) =>
    <String, dynamic>{
      'l1': instance.l1,
      'l2': instance.l2,
      'l3': instance.l3,
      'l4': instance.l4,
      'net': instance.net,
      'processor': instance.processor,
    };

_$TeleopScoringImpl _$$TeleopScoringImplFromJson(Map<String, dynamic> json) =>
    _$TeleopScoringImpl(
      l1: (json['l1'] as num).toInt(),
      l2: (json['l2'] as num).toInt(),
      l3: (json['l3'] as num).toInt(),
      l4: (json['l4'] as num).toInt(),
      net: (json['net'] as num).toInt(),
      processor: (json['processor'] as num).toInt(),
    );

Map<String, dynamic> _$$TeleopScoringImplToJson(_$TeleopScoringImpl instance) =>
    <String, dynamic>{
      'l1': instance.l1,
      'l2': instance.l2,
      'l3': instance.l3,
      'l4': instance.l4,
      'net': instance.net,
      'processor': instance.processor,
    };

_$MiscellaneousImpl _$$MiscellaneousImplFromJson(Map<String, dynamic> json) =>
    _$MiscellaneousImpl(
      died: (json['died'] as num).toInt(),
      comments: json['comments'] as String,
    );

Map<String, dynamic> _$$MiscellaneousImplToJson(_$MiscellaneousImpl instance) =>
    <String, dynamic>{
      'died': instance.died,
      'comments': instance.comments,
    };
