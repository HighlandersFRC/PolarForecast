// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pit_scouting_2025.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PitScouting2025Impl _$$PitScouting2025ImplFromJson(
        Map<String, dynamic> json) =>
    _$PitScouting2025Impl(
      user_id: json['user_id'] as String,
      team_number: (json['team_number'] as num).toInt(),
      time: (json['time'] as num).toInt(),
      event_code: json['event_code'] as String,
      data: PitData2025.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PitScouting2025ImplToJson(
        _$PitScouting2025Impl instance) =>
    <String, dynamic>{
      'user_id': instance.user_id,
      'team_number': instance.team_number,
      'time': instance.time,
      'event_code': instance.event_code,
      'data': instance.data.toJson(),
    };

_$PitData2025Impl _$$PitData2025ImplFromJson(Map<String, dynamic> json) =>
    _$PitData2025Impl(
      driver_experience_events:
          (json['driver_experience_events'] as num).toInt(),
      drive_train: json['drive_train'] as String,
      can_score_coral: json['can_score_coral'] as bool,
      coral_levels: (json['coral_levels'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      can_score_processor: json['can_score_processor'] as bool,
      can_score_net: json['can_score_net'] as bool,
      ground_coral_pickup: json['ground_coral_pickup'] as bool,
      feeder_coral_pickup: json['feeder_coral_pickup'] as bool,
      ground_algae_pickup: json['ground_algae_pickup'] as bool,
      reef_algae_pickup: json['reef_algae_pickup'] as bool,
      climbing:
          (json['climbing'] as List<dynamic>).map((e) => e as String).toList(),
      spare_parts: (json['spare_parts'] as num).toInt(),
      favorite_color: json['favorite_color'] as String,
      autos: (json['autos'] as List<dynamic>)
          .map((e) => PitAuto2025.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$PitData2025ImplToJson(_$PitData2025Impl instance) =>
    <String, dynamic>{
      'driver_experience_events': instance.driver_experience_events,
      'drive_train': instance.drive_train,
      'can_score_coral': instance.can_score_coral,
      'coral_levels': instance.coral_levels,
      'can_score_processor': instance.can_score_processor,
      'can_score_net': instance.can_score_net,
      'ground_coral_pickup': instance.ground_coral_pickup,
      'feeder_coral_pickup': instance.feeder_coral_pickup,
      'ground_algae_pickup': instance.ground_algae_pickup,
      'reef_algae_pickup': instance.reef_algae_pickup,
      'climbing': instance.climbing,
      'spare_parts': instance.spare_parts,
      'favorite_color': instance.favorite_color,
      'autos': instance.autos.map((e) => e.toJson()).toList(),
    };

_$PitAuto2025Impl _$$PitAuto2025ImplFromJson(Map<String, dynamic> json) =>
    _$PitAuto2025Impl(
      starting_position_meters_from_processor:
          (json['starting_position_meters_from_processor'] as num).toDouble(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => PitAutoStep2025.fromJson(e as Map<String, dynamic>))
          .toList(),
      field_side: (json['field_side'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      exit: json['exit'] as bool,
      preload: json['preload'] as bool,
    );

Map<String, dynamic> _$$PitAuto2025ImplToJson(_$PitAuto2025Impl instance) =>
    <String, dynamic>{
      'starting_position_meters_from_processor':
          instance.starting_position_meters_from_processor,
      'steps': instance.steps.map((e) => e.toJson()).toList(),
      'field_side': instance.field_side,
      'exit': instance.exit,
      'preload': instance.preload,
    };

_$PitAutoStep2025Impl _$$PitAutoStep2025ImplFromJson(
        Map<String, dynamic> json) =>
    _$PitAutoStep2025Impl(
      name: json['name'] as String,
      extra_data: json['extra_data'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$$PitAutoStep2025ImplToJson(
        _$PitAutoStep2025Impl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'extra_data': instance.extra_data,
    };
