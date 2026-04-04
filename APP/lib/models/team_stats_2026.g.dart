// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_stats_2026.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TeamStats2026Impl _$$TeamStats2026ImplFromJson(Map<String, dynamic> json) =>
    _$TeamStats2026Impl(
      historical: json['historical'] as bool,
      key: json['key'] as String,
      rank: (json['rank'] as num).toInt(),
      team_number: json['team_number'] as String,
      match_count: (json['match_count'] as num?)?.toDouble() ?? 0,
      OPR: (json['OPR'] as num?)?.toDouble() ?? 0.0,
      OPRRank: (json['OPRRank'] as num?)?.toInt(),
      total_pass: (json['total_pass'] as num?)?.toDouble() ?? 0.0,
      auto_pass: (json['auto_pass'] as num?)?.toDouble() ?? 0.0,
      teleop_pass: (json['teleop_pass'] as num?)?.toDouble() ?? 0.0,
      endgame_points: (json['endgame_points'] as num?)?.toDouble() ?? 0.0,
      teleop_points: (json['teleop_points'] as num?)?.toDouble() ?? 0.0,
      auto_points: (json['auto_points'] as num?)?.toDouble() ?? 0.0,
      climbing_points: (json['climbing_points'] as num?)?.toDouble() ?? 0.0,
      death_rate: (json['death_rate'] as num?)?.toDouble() ?? 0.0,
      defense_rate: (json['defense_rate'] as num?)?.toDouble() ?? 0.0,
      auto_fuel_scored: (json['auto_fuel_scored'] as num?)?.toDouble() ?? 0.0,
      teleop_fuel_scored:
          (json['teleop_fuel_scored'] as num?)?.toDouble() ?? 0.0,
      total_fuel_scored: (json['total_fuel_scored'] as num?)?.toDouble() ?? 0.0,
      foul_points: (json['foul_points'] as num?)?.toDouble() ?? 0.0,
      simulated_rp: (json['simulated_rp'] as num?)?.toInt() ?? 0,
      simulated_rank: (json['simulated_rank'] as num?)?.toInt() ?? 0,
      auto_fuel_denied: (json['auto_fuel_denied'] as num?)?.toDouble() ?? 0.0,
      teleop_fuel_denied:
          (json['teleop_fuel_denied'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$$TeamStats2026ImplToJson(_$TeamStats2026Impl instance) =>
    <String, dynamic>{
      'historical': instance.historical,
      'key': instance.key,
      'rank': instance.rank,
      'team_number': instance.team_number,
      'match_count': instance.match_count,
      'OPR': instance.OPR,
      'OPRRank': instance.OPRRank,
      'total_pass': instance.total_pass,
      'auto_pass': instance.auto_pass,
      'teleop_pass': instance.teleop_pass,
      'endgame_points': instance.endgame_points,
      'teleop_points': instance.teleop_points,
      'auto_points': instance.auto_points,
      'climbing_points': instance.climbing_points,
      'death_rate': instance.death_rate,
      'defense_rate': instance.defense_rate,
      'auto_fuel_scored': instance.auto_fuel_scored,
      'teleop_fuel_scored': instance.teleop_fuel_scored,
      'total_fuel_scored': instance.total_fuel_scored,
      'foul_points': instance.foul_points,
      'simulated_rp': instance.simulated_rp,
      'simulated_rank': instance.simulated_rank,
      'auto_fuel_denied': instance.auto_fuel_denied,
      'teleop_fuel_denied': instance.teleop_fuel_denied,
    };
