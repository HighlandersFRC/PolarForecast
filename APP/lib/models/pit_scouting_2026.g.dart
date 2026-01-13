// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pit_scouting_2026.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PitScouting2026Impl _$$PitScouting2026ImplFromJson(
        Map<String, dynamic> json) =>
    _$PitScouting2026Impl(
      user_id: json['user_id'] as String,
      scout_info:
          ScoutInfo.fromJson(json['scout_info'] as Map<String, dynamic>),
      team_number: (json['team_number'] as num).toInt(),
      event_code: json['event_code'] as String,
      time: (json['time'] as num).toInt(),
      data: PitData2026.fromJson(json['data'] as Map<String, dynamic>),
      auto: Auto2026.fromJson(json['auto'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PitScouting2026ImplToJson(
        _$PitScouting2026Impl instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'scout_info': instance.scout_info.toJson(),
      'team_number': instance.team_number,
      'event_code': instance.event_code,
      'time': instance.time,
      'data': instance.data.toJson(),
      'auto': instance.auto.toJson(),
    };

_$PitData2026Impl _$$PitData2026ImplFromJson(Map<String, dynamic> json) =>
    _$PitData2026Impl(
      driver_experience_events:
          (json['driver_experience_events'] as num).toInt(),
      drive_train: json['drive_train'] as String,
      can_feed_human_player: json['can_feed_human_player'] as bool,
      can_pick_up_from_ground: json['can_pick_up_from_ground'] as bool,
      distance_to_shoot: (json['distance_to_shoot'] as num).toInt(),
      cycles_in_25_seconds: (json['cycles_in_25_seconds'] as num).toInt(),
      cycle_time: (json['cycle_time'] as num).toInt(),
      go_over_bump: json['go_over_bump'] as bool,
      go_under_trench: json['go_under_trench'] as bool,
      can_climb: json['can_climb'] as bool,
      climbing: (json['climbing'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      can_climb_in_autonomous: json['can_climb_in_autonomous'] as bool,
      can_climb_with_others: json['can_climb_with_others'] as bool,
      automatically_shooting: json['automatically_shooting'] as bool,
      shooting_while_moving: json['shooting_while_moving'] as bool,
      main_strategy: json['main_strategy'] as String,
      spare_parts: (json['spare_parts'] as num).toInt(),
      favorite_color: json['favorite_color'] as String,
      auto: Auto2026.fromJson(json['auto'] as Map<String, dynamic>),
      autos: json['autos'] as List<dynamic>,
    );

Map<String, dynamic> _$$PitData2026ImplToJson(_$PitData2026Impl instance) =>
    <String, dynamic>{
      'driver_experience_events': instance.driver_experience_events,
      'drive_train': instance.drive_train,
      'can_feed_human_player': instance.can_feed_human_player,
      'can_pick_up_from_ground': instance.can_pick_up_from_ground,
      'distance_to_shoot': instance.distance_to_shoot,
      'cycles_in_25_seconds': instance.cycles_in_25_seconds,
      'cycle_time': instance.cycle_time,
      'go_over_bump': instance.go_over_bump,
      'go_under_trench': instance.go_under_trench,
      'can_climb': instance.can_climb,
      'climbing': instance.climbing,
      'can_climb_in_autonomous': instance.can_climb_in_autonomous,
      'can_climb_with_others': instance.can_climb_with_others,
      'automatically_shooting': instance.automatically_shooting,
      'shooting_while_moving': instance.shooting_while_moving,
      'main_strategy': instance.main_strategy,
      'spare_parts': instance.spare_parts,
      'favorite_color': instance.favorite_color,
      'auto': instance.auto.toJson(),
      'autos': instance.autos,
    };

_$Auto2026Impl _$$Auto2026ImplFromJson(Map<String, dynamic> json) =>
    _$Auto2026Impl(
      starting_position_meters_from_hub_center:
          (json['starting_position_meters_from_hub_center'] as num).toDouble(),
      steps: json['steps'] as List<dynamic>,
      field_side: (json['field_side'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      preload: json['preload'] as bool,
      climb: json['climb'] as bool,
      contacts_robot: json['contacts_robot'] as bool,
      both_sides: json['both_sides'] as bool? ?? false,
      autoPieces: (json['autoPieces'] as num?)?.toInt() ?? 0,
      fuelShotsInAuto: (json['fuelShotsInAuto'] as num?)?.toInt() ?? 0,
      intakedAmountInAuto: (json['intakedAmountInAuto'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$Auto2026ImplToJson(_$Auto2026Impl instance) =>
    <String, dynamic>{
      'starting_position_meters_from_hub_center':
          instance.starting_position_meters_from_hub_center,
      'steps': instance.steps,
      'field_side': instance.field_side,
      'preload': instance.preload,
      'climb': instance.climb,
      'contacts_robot': instance.contacts_robot,
      'both_sides': instance.both_sides,
      'autoPieces': instance.autoPieces,
      'fuelShotsInAuto': instance.fuelShotsInAuto,
      'intakedAmountInAuto': instance.intakedAmountInAuto,
    };

_$AutoStep2026Impl _$$AutoStep2026ImplFromJson(Map<String, dynamic> json) =>
    _$AutoStep2026Impl(
      name: json['name'] as String,
      extra_data: json['extra_data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$AutoStep2026ImplToJson(_$AutoStep2026Impl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'extra_data': instance.extra_data,
    };

_$DataImpl _$$DataImplFromJson(Map<String, dynamic> json) => _$DataImpl(
      auto: Auto2026.fromJson(json['auto'] as Map<String, dynamic>),
      auto_scoring:
          AutoScoring.fromJson(json['auto_scoring'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$DataImplToJson(_$DataImpl instance) =>
    <String, dynamic>{
      'auto': instance.auto.toJson(),
      'auto_scoring': instance.auto_scoring.toJson(),
    };
