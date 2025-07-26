// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_prediction_2025.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchPrediction2025Impl _$$MatchPrediction2025ImplFromJson(
        Map<String, dynamic> json) =>
    _$MatchPrediction2025Impl(
      comp_level: json['comp_level'] as String,
      key: json['key'] as String,
      match_number: (json['match_number'] as num).toInt(),
      set_number: (json['set_number'] as num).toInt(),
      red: AlliancePrediction2025.fromJson(json['red'] as Map<String, dynamic>),
      blue:
          AlliancePrediction2025.fromJson(json['blue'] as Map<String, dynamic>),
      predicted: json['predicted'] as bool,
    );

Map<String, dynamic> _$$MatchPrediction2025ImplToJson(
        _$MatchPrediction2025Impl instance) =>
    <String, dynamic>{
      'comp_level': instance.comp_level,
      'key': instance.key,
      'match_number': instance.match_number,
      'set_number': instance.set_number,
      'red': instance.red.toJson(),
      'blue': instance.blue.toJson(),
      'predicted': instance.predicted,
    };

_$AlliancePrediction2025Impl _$$AlliancePrediction2025ImplFromJson(
        Map<String, dynamic> json) =>
    _$AlliancePrediction2025Impl(
      teams: (json['teams'] as List<dynamic>).map((e) => e as String).toList(),
      mobility: (json['mobility'] as num).toDouble(),
      score: (json['score'] as num).toDouble(),
      climbing: (json['climbing'] as num).toDouble(),
      auto_points: (json['auto_points'] as num).toDouble(),
      teleop_points: (json['teleop_points'] as num).toDouble(),
      endgame_points: (json['endgame_points'] as num).toDouble(),
      coopertition: (json['coopertition'] as num).toDouble(),
      coral_l_1: (json['coral_l_1'] as num).toDouble(),
      coral_l_2: (json['coral_l_2'] as num).toDouble(),
      coral_l_3: (json['coral_l_3'] as num).toDouble(),
      coral_l_4: (json['coral_l_4'] as num).toDouble(),
      processor: (json['processor'] as num).toDouble(),
      net: (json['net'] as num).toDouble(),
      auto_coral: (json['auto_coral'] as num).toDouble(),
      win_rp: (json['win_rp'] as num).toInt(),
      auto_rp: (json['auto_rp'] as num).toInt(),
      barge_rp: (json['barge_rp'] as num).toInt(),
      coral_rp: (json['coral_rp'] as num).toInt(),
      total_rp: (json['total_rp'] as num).toInt(),
      display_rp: (json['display_rp'] as num).toInt(),
      actual_score: (json['actual_score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$AlliancePrediction2025ImplToJson(
        _$AlliancePrediction2025Impl instance) =>
    <String, dynamic>{
      'teams': instance.teams,
      'mobility': instance.mobility,
      'score': instance.score,
      'climbing': instance.climbing,
      'auto_points': instance.auto_points,
      'teleop_points': instance.teleop_points,
      'endgame_points': instance.endgame_points,
      'coopertition': instance.coopertition,
      'coral_l_1': instance.coral_l_1,
      'coral_l_2': instance.coral_l_2,
      'coral_l_3': instance.coral_l_3,
      'coral_l_4': instance.coral_l_4,
      'processor': instance.processor,
      'net': instance.net,
      'auto_coral': instance.auto_coral,
      'win_rp': instance.win_rp,
      'auto_rp': instance.auto_rp,
      'barge_rp': instance.barge_rp,
      'coral_rp': instance.coral_rp,
      'total_rp': instance.total_rp,
      'display_rp': instance.display_rp,
      'actual_score': instance.actual_score,
    };
