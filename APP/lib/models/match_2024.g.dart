// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_2024.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$Match2024Impl _$$Match2024ImplFromJson(Map<String, dynamic> json) =>
    _$Match2024Impl(
      actual_time: (json['actual_time'] as num?)?.toInt(),
      alliances: Alliances.fromJson(json['alliances'] as Map<String, dynamic>),
      comp_level: json['comp_level'] as String,
      event_key: json['event_key'] as String,
      key: json['key'] as String,
      match_number: (json['match_number'] as num).toInt(),
      post_result_time: (json['post_result_time'] as num?)?.toInt(),
      predicted_time: (json['predicted_time'] as num?)?.toInt(),
      score_breakdown: json['score_breakdown'] == null
          ? null
          : ScoreBreakdowns2024.fromJson(
              json['score_breakdown'] as Map<String, dynamic>),
      set_number: (json['set_number'] as num).toInt(),
      time: (json['time'] as num).toInt(),
      videos: (json['videos'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      winning_alliance: json['winning_alliance'] as String,
    );

Map<String, dynamic> _$$Match2024ImplToJson(_$Match2024Impl instance) =>
    <String, dynamic>{
      'actual_time': instance.actual_time,
      'alliances': instance.alliances.toJson(),
      'comp_level': instance.comp_level,
      'event_key': instance.event_key,
      'key': instance.key,
      'match_number': instance.match_number,
      'post_result_time': instance.post_result_time,
      'predicted_time': instance.predicted_time,
      'score_breakdown': instance.score_breakdown?.toJson(),
      'set_number': instance.set_number,
      'time': instance.time,
      'videos': instance.videos,
      'winning_alliance': instance.winning_alliance,
    };
