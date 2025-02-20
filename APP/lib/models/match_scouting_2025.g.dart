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
      l_1: (json['l_1'] as num).toInt(),
      l_2: (json['l_2'] as num).toInt(),
      l_3: (json['l_3'] as num).toInt(),
      l_4: (json['l_4'] as num).toInt(),
      net: (json['net'] as num).toInt(),
      processor: (json['processor'] as num).toInt(),
    );

Map<String, dynamic> _$$AutoScoringImplToJson(_$AutoScoringImpl instance) =>
    <String, dynamic>{
      'l_1': instance.l_1,
      'l_2': instance.l_2,
      'l_3': instance.l_3,
      'l_4': instance.l_4,
      'net': instance.net,
      'processor': instance.processor,
    };

_$TeleopScoringImpl _$$TeleopScoringImplFromJson(Map<String, dynamic> json) =>
    _$TeleopScoringImpl(
      l_1: (json['l_1'] as num).toInt(),
      l_2: (json['l_2'] as num).toInt(),
      l_3: (json['l_3'] as num).toInt(),
      l_4: (json['l_4'] as num).toInt(),
      net: (json['net'] as num).toInt(),
      processor: (json['processor'] as num).toInt(),
    );

Map<String, dynamic> _$$TeleopScoringImplToJson(_$TeleopScoringImpl instance) =>
    <String, dynamic>{
      'l_1': instance.l_1,
      'l_2': instance.l_2,
      'l_3': instance.l_3,
      'l_4': instance.l_4,
      'net': instance.net,
      'processor': instance.processor,
    };

_$MiscellaneousImpl _$$MiscellaneousImplFromJson(Map<String, dynamic> json) =>
    _$MiscellaneousImpl(
      died: json['died'] as bool,
      comments: json['comments'] as String,
    );

Map<String, dynamic> _$$MiscellaneousImplToJson(_$MiscellaneousImpl instance) =>
    <String, dynamic>{
      'died': instance.died,
      'comments': instance.comments,
    };
