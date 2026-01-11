// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_prediction_2026.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchPrediction2026Impl _$$MatchPrediction2026ImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchPrediction2026Impl(
      comp_level: json['comp_level'] as String,
      key: json['key'] as String,
      match_number: (json['match_number'] as num).toInt(),
      set_number: (json['set_number'] as num).toInt(),
      blue_teams: (json['blue_teams'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      blue_mobility: (json['blue_mobility'] as num).toDouble(),
      blue_score: (json['blue_score'] as num).toDouble(),
      blue_climbing: (json['blue_climbing'] as num).toDouble(),
      blue_auto_points: (json['blue_auto_points'] as num).toDouble(),
      blue_teleop_points: (json['blue_teleop_points'] as num).toDouble(),
      blue_endgame_points: (json['blue_endgame_points'] as num).toDouble(),
      blue_actual_score: (json['blue_actual_score'] as num?)?.toInt(),
      red_teams:
          (json['red_teams'] as List<dynamic>).map((e) => e as String).toList(),
      red_mobility: (json['red_mobility'] as num).toDouble(),
      red_score: (json['red_score'] as num).toDouble(),
      red_climbing: (json['red_climbing'] as num).toDouble(),
      red_auto_points: (json['red_auto_points'] as num).toDouble(),
      red_teleop_points: (json['red_teleop_points'] as num).toDouble(),
      red_endgame_points: (json['red_endgame_points'] as num).toDouble(),
      red_actual_score: (json['red_actual_score'] as num?)?.toInt(),
      predicted: json['predicted'] as bool,
      blue_win_rp: (json['blue_win_rp'] as num).toInt(),
      blue_auto_rp: (json['blue_auto_rp'] as num).toInt(),
      blue_barge_rp: (json['blue_barge_rp'] as num).toInt(),
      blue_coral_rp: (json['blue_coral_rp'] as num).toInt(),
      blue_total_rp: (json['blue_total_rp'] as num).toInt(),
      blue_display_rp: (json['blue_display_rp'] as num).toInt(),
      red_win_rp: (json['red_win_rp'] as num).toInt(),
      red_total_rp: (json['red_total_rp'] as num).toInt(),
      red_display_rp: (json['red_display_rp'] as num).toInt(),
    );

Map<String, dynamic> _$$MatchPrediction2026ImplToJson(
        _$MatchPrediction2026Impl instance) =>
    <String, dynamic>{
      'comp_level': instance.comp_level,
      'key': instance.key,
      'match_number': instance.match_number,
      'set_number': instance.set_number,
      'blue_teams': instance.blue_teams,
      'blue_mobility': instance.blue_mobility,
      'blue_score': instance.blue_score,
      'blue_climbing': instance.blue_climbing,
      'blue_auto_points': instance.blue_auto_points,
      'blue_teleop_points': instance.blue_teleop_points,
      'blue_endgame_points': instance.blue_endgame_points,
      'blue_actual_score': instance.blue_actual_score,
      'red_teams': instance.red_teams,
      'red_mobility': instance.red_mobility,
      'red_score': instance.red_score,
      'red_climbing': instance.red_climbing,
      'red_auto_points': instance.red_auto_points,
      'red_teleop_points': instance.red_teleop_points,
      'red_endgame_points': instance.red_endgame_points,
      'red_actual_score': instance.red_actual_score,
      'predicted': instance.predicted,
      'blue_win_rp': instance.blue_win_rp,
      'blue_auto_rp': instance.blue_auto_rp,
      'blue_barge_rp': instance.blue_barge_rp,
      'blue_coral_rp': instance.blue_coral_rp,
      'blue_total_rp': instance.blue_total_rp,
      'blue_display_rp': instance.blue_display_rp,
      'red_win_rp': instance.red_win_rp,
      'red_total_rp': instance.red_total_rp,
      'red_display_rp': instance.red_display_rp,
    };
