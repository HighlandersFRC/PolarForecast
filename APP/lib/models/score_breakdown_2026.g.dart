// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_breakdown_2026.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScoreBreakdown2026Impl _$$ScoreBreakdown2026ImplFromJson(
        Map<String, dynamic> json) =>
    _$ScoreBreakdown2026Impl(
      climb: json['climb'] as bool,
      feed_amount: (json['feed_amount'] as num).toInt(),
      intake_amount: (json['intake_amount'] as num).toInt(),
      shoot_amount: (json['shoot_amount'] as num).toInt(),
      goes_under_trench: (json['goes_under_trench'] as num).toInt(),
      goes_over_bump: (json['goes_over_bump'] as num).toInt(),
      climb_side: (json['climb_side'] as num).toInt(),
      cycles_completed: (json['cycles_completed'] as num).toInt(),
      shoots_from_X: (json['shoots_from_X'] as num).toInt(),
      shoots_from_Y: (json['shoots_from_Y'] as num).toInt(),
    );

Map<String, dynamic> _$$ScoreBreakdown2026ImplToJson(
        _$ScoreBreakdown2026Impl instance) =>
    <String, dynamic>{
      'climb': instance.climb,
      'feed_amount': instance.feed_amount,
      'intake_amount': instance.intake_amount,
      'shoot_amount': instance.shoot_amount,
      'goes_under_trench': instance.goes_under_trench,
      'goes_over_bump': instance.goes_over_bump,
      'climb_side': instance.climb_side,
      'cycles_completed': instance.cycles_completed,
      'shoots_from_X': instance.shoots_from_X,
      'shoots_from_Y': instance.shoots_from_Y,
    };
