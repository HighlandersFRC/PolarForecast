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
      endgame_points: (json['endgame_points'] as num).toDouble(),
      teleop_points: (json['teleop_points'] as num).toDouble(),
      auto_points: (json['auto_points'] as num).toDouble(),
      climbing_points: (json['climbing_points'] as num).toDouble(),
      mobility: (json['mobility'] as num).toDouble(),
      death_rate: (json['death_rate'] as num).toDouble(),
      parking: (json['parking'] as num).toDouble(),
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
      'endgame_points': instance.endgame_points,
      'teleop_points': instance.teleop_points,
      'auto_points': instance.auto_points,
      'climbing_points': instance.climbing_points,
      'mobility': instance.mobility,
      'death_rate': instance.death_rate,
      'parking': instance.parking,
      'simulated_rp': instance.simulated_rp,
      'simulated_rank': instance.simulated_rank,
    };
