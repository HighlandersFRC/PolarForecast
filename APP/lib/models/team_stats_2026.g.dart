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
      match_count: (json['match_count'] as num).toDouble(),
      OPR: (json['OPR'] as num).toDouble(),
      OPRRank: (json['OPRRank'] as num?)?.toInt(),
      total_pass: (json['total_pass'] as num).toDouble(),
      auto_pass: (json['auto_pass'] as num).toDouble(),
      teleop_pass: (json['teleop_pass'] as num).toDouble(),
      endgame_points: (json['endgame_points'] as num).toDouble(),
      teleop_points: (json['teleop_points'] as num).toDouble(),
      auto_points: (json['auto_points'] as num).toDouble(),
      climbing_points: (json['climbing_points'] as num).toDouble(),
      death_rate: (json['death_rate'] as num).toDouble(),
      auto_fuel_cycles: (json['auto_fuel_cycles'] as num).toDouble(),
      teleop_fuel_cycles: (json['teleop_fuel_cycles'] as num).toDouble(),
      foul_points: (json['foul_points'] as num).toDouble(),
      simulated_rp: (json['simulated_rp'] as num).toInt(),
      simulated_rank: (json['simulated_rank'] as num).toInt(),
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
      'auto_fuel_cycles': instance.auto_fuel_cycles,
      'teleop_fuel_cycles': instance.teleop_fuel_cycles,
      'foul_points': instance.foul_points,
      'simulated_rp': instance.simulated_rp,
      'simulated_rank': instance.simulated_rank,
    };
