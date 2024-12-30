// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_scouting_2024.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchScouting2024Impl _$$MatchScouting2024ImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchScouting2024Impl(
      event_code: json['event_code'] as String,
      team_number: json['team_number'] as String,
      match_number: (json['match_number'] as num).toInt(),
      active: json['active'] as bool,
      scout_info:
          ScoutInfo2024.fromJson(json['scout_info'] as Map<String, dynamic>),
      data: MatchData2024.fromJson(json['data'] as Map<String, dynamic>),
      time: (json['time'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchScouting2024ImplToJson(
        _$MatchScouting2024Impl instance) =>
    <String, dynamic>{
      'event_code': instance.event_code,
      'team_number': instance.team_number,
      'match_number': instance.match_number,
      'active': instance.active,
      'scout_info': instance.scout_info.toJson(),
      'data': instance.data.toJson(),
      'time': instance.time,
    };

_$ScoutInfo2024Impl _$$ScoutInfo2024ImplFromJson(Map<String, dynamic> json) =>
    _$ScoutInfo2024Impl(
      name: json['name'] as String,
    );

Map<String, dynamic> _$$ScoutInfo2024ImplToJson(_$ScoutInfo2024Impl instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

_$MatchData2024Impl _$$MatchData2024ImplFromJson(Map<String, dynamic> json) =>
    _$MatchData2024Impl(
      auto: AutoData2024.fromJson(json['auto'] as Map<String, dynamic>),
      teleop: TeleopData2024.fromJson(json['teleop'] as Map<String, dynamic>),
      miscellaneous: MiscellaneousData2024.fromJson(
          json['miscellaneous'] as Map<String, dynamic>),
      selectedPieces: (json['selectedPieces'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$$MatchData2024ImplToJson(_$MatchData2024Impl instance) =>
    <String, dynamic>{
      'auto': instance.auto.toJson(),
      'teleop': instance.teleop.toJson(),
      'miscellaneous': instance.miscellaneous.toJson(),
      'selectedPieces': instance.selectedPieces,
    };

_$AutoData2024Impl _$$AutoData2024ImplFromJson(Map<String, dynamic> json) =>
    _$AutoData2024Impl(
      amp: (json['amp'] as num).toInt(),
      speaker: (json['speaker'] as num).toInt(),
    );

Map<String, dynamic> _$$AutoData2024ImplToJson(_$AutoData2024Impl instance) =>
    <String, dynamic>{
      'amp': instance.amp,
      'speaker': instance.speaker,
    };

_$TeleopData2024Impl _$$TeleopData2024ImplFromJson(Map<String, dynamic> json) =>
    _$TeleopData2024Impl(
      amp: (json['amp'] as num).toInt(),
      speaker: (json['speaker'] as num).toInt(),
      amped_speaker: (json['amped_speaker'] as num).toInt(),
      pass: (json['pass'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$TeleopData2024ImplToJson(
        _$TeleopData2024Impl instance) =>
    <String, dynamic>{
      'amp': instance.amp,
      'speaker': instance.speaker,
      'amped_speaker': instance.amped_speaker,
      'pass': instance.pass,
    };

_$MiscellaneousData2024Impl _$$MiscellaneousData2024ImplFromJson(
        Map<String, dynamic> json) =>
    _$MiscellaneousData2024Impl(
      died: json['died'] as bool,
      comments: json['comments'] as String,
    );

Map<String, dynamic> _$$MiscellaneousData2024ImplToJson(
        _$MiscellaneousData2024Impl instance) =>
    <String, dynamic>{
      'died': instance.died,
      'comments': instance.comments,
    };
