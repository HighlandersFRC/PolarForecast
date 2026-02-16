// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_scouting_2026.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchScouting2026Impl _$$MatchScouting2026ImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchScouting2026Impl(
      event_code: json['event_code'] as String,
      team_number: (json['team_number'] as num).toInt(),
      match_number: (json['match_number'] as num).toInt(),
      scout_info:
          ScoutInfo.fromJson(json['scout_info'] as Map<String, dynamic>),
      data: Data.fromJson(json['data'] as Map<String, dynamic>),
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchScouting2026ImplToJson(
        _$MatchScouting2026Impl instance) =>
    <String, dynamic>{
      'event_code': instance.event_code,
      'team_number': instance.team_number,
      'match_number': instance.match_number,
      'scout_info': instance.scout_info.toJson(),
      'data': instance.data.toJson(),
      'time': instance.time,
    };

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
      auto: Auto2026.fromJson(json['auto'] as Map<String, dynamic>),
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
      passing_cycles: (json['passing_cycles'] as num).toInt(),
      scoring_cycles: (json['scoring_cycles'] as num).toInt(),
      fuel_cycles: (json['fuel_cycles'] as num).toInt(),
      cycles_completed: (json['cycles_completed'] as num).toInt(),
      climb_side: json['climb_side'] as String,
    );

Map<String, dynamic> _$$AutoScoringImplToJson(_$AutoScoringImpl instance) =>
    <String, dynamic>{
      'passing_cycles': instance.passing_cycles,
      'scoring_cycles': instance.scoring_cycles,
      'fuel_cycles': instance.fuel_cycles,
      'cycles_completed': instance.cycles_completed,
      'climb_side': instance.climb_side,
    };

_$TeleopScoringImpl _$$TeleopScoringImplFromJson(Map<String, dynamic> json) =>
    _$TeleopScoringImpl(
      fuel_cycles: (json['fuel_cycles'] as num).toInt(),
      passing_cycles: (json['passing_cycles'] as num).toInt(),
    );

Map<String, dynamic> _$$TeleopScoringImplToJson(_$TeleopScoringImpl instance) =>
    <String, dynamic>{
      'fuel_cycles': instance.fuel_cycles,
      'passing_cycles': instance.passing_cycles,
    };

_$MiscellaneousImpl _$$MiscellaneousImplFromJson(Map<String, dynamic> json) =>
    _$MiscellaneousImpl(
      died: json['died'] as bool,
      defense: json['defense'] as bool,
      comments: json['comments'] as String,
    );

Map<String, dynamic> _$$MiscellaneousImplToJson(_$MiscellaneousImpl instance) =>
    <String, dynamic>{
      'died': instance.died,
      'defense': instance.defense,
      'comments': instance.comments,
    };
