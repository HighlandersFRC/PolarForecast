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
      feed_amount: (json['feed_amount'] as num).toInt(),
      intake_amount: (json['intake_amount'] as num).toInt(),
      shoot_amount: (json['shoot_amount'] as num).toInt(),
      goes_under_trench: (json['goes_under_trench'] as num).toInt(),
      goes_over_bump: (json['goes_over_bump'] as num).toInt(),
      climb_side: (json['climb_side'] as num).toInt(),
    );

Map<String, dynamic> _$$AutoScoringImplToJson(_$AutoScoringImpl instance) =>
    <String, dynamic>{
      'feed_amount': instance.feed_amount,
      'intake_amount': instance.intake_amount,
      'shoot_amount': instance.shoot_amount,
      'goes_under_trench': instance.goes_under_trench,
      'goes_over_bump': instance.goes_over_bump,
      'climb_side': instance.climb_side,
    };

_$TeleopScoringImpl _$$TeleopScoringImplFromJson(Map<String, dynamic> json) =>
    _$TeleopScoringImpl(
      cycles_completed: (json['cycles_completed'] as num).toInt(),
      shoots_from_X: (json['shoots_from_X'] as num).toInt(),
      shoots_from_Y: (json['shoots_from_Y'] as num).toInt(),
      shoot_amount: (json['shoot_amount'] as num).toInt(),
    );

Map<String, dynamic> _$$TeleopScoringImplToJson(_$TeleopScoringImpl instance) =>
    <String, dynamic>{
      'cycles_completed': instance.cycles_completed,
      'shoots_from_X': instance.shoots_from_X,
      'shoots_from_Y': instance.shoots_from_Y,
      'shoot_amount': instance.shoot_amount,
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
