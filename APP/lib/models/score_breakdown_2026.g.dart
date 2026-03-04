// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_breakdown_2026.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HubScoreImpl _$$HubScoreImplFromJson(Map<String, dynamic> json) =>
    _$HubScoreImpl(
      autoCount: (json['autoCount'] as num?)?.toInt(),
      autoPoints: (json['autoPoints'] as num?)?.toInt(),
      endgameCount: (json['endgameCount'] as num?)?.toInt(),
      endgamePoints: (json['endgamePoints'] as num?)?.toInt(),
      shift1Count: (json['shift1Count'] as num?)?.toInt(),
      shift1Points: (json['shift1Points'] as num?)?.toInt(),
      shift2Count: (json['shift2Count'] as num?)?.toInt(),
      shift2Points: (json['shift2Points'] as num?)?.toInt(),
      shift3Count: (json['shift3Count'] as num?)?.toInt(),
      shift3Points: (json['shift3Points'] as num?)?.toInt(),
      shift4Count: (json['shift4Count'] as num?)?.toInt(),
      shift4Points: (json['shift4Points'] as num?)?.toInt(),
      teleopCount: (json['teleopCount'] as num?)?.toInt(),
      totalCount: (json['totalCount'] as num?)?.toInt(),
      totalPoints: (json['totalPoints'] as num?)?.toInt(),
      transitionCount: (json['transitionCount'] as num?)?.toInt(),
      transitionPoints: (json['transitionPoints'] as num?)?.toInt(),
      uncounted: (json['uncounted'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$HubScoreImplToJson(_$HubScoreImpl instance) =>
    <String, dynamic>{
      'autoCount': instance.autoCount,
      'autoPoints': instance.autoPoints,
      'endgameCount': instance.endgameCount,
      'endgamePoints': instance.endgamePoints,
      'shift1Count': instance.shift1Count,
      'shift1Points': instance.shift1Points,
      'shift2Count': instance.shift2Count,
      'shift2Points': instance.shift2Points,
      'shift3Count': instance.shift3Count,
      'shift3Points': instance.shift3Points,
      'shift4Count': instance.shift4Count,
      'shift4Points': instance.shift4Points,
      'teleopCount': instance.teleopCount,
      'totalCount': instance.totalCount,
      'totalPoints': instance.totalPoints,
      'transitionCount': instance.transitionCount,
      'transitionPoints': instance.transitionPoints,
      'uncounted': instance.uncounted,
    };

_$ScoreBreakdown2026Impl _$$ScoreBreakdown2026ImplFromJson(
        Map<String, dynamic> json) =>
    _$ScoreBreakdown2026Impl(
      adjustPoints: (json['adjustPoints'] as num?)?.toInt(),
      autoTowerPoints: (json['autoTowerPoints'] as num?)?.toInt(),
      autoTowerRobot1: json['autoTowerRobot1'] as String?,
      autoTowerRobot2: json['autoTowerRobot2'] as String?,
      autoTowerRobot3: json['autoTowerRobot3'] as String?,
      endGameTowerPoints: (json['endGameTowerPoints'] as num?)?.toInt(),
      endGameTowerRobot1: json['endGameTowerRobot1'] as String?,
      endGameTowerRobot2: json['endGameTowerRobot2'] as String?,
      endGameTowerRobot3: json['endGameTowerRobot3'] as String?,
      energizedAchieved: json['energizedAchieved'] as bool?,
      foulPoints: (json['foulPoints'] as num?)?.toInt(),
      g206Penalty: json['g206Penalty'] as bool?,
      hubScore: json['hubScore'] == null
          ? null
          : HubScore.fromJson(json['hubScore'] as Map<String, dynamic>),
      majorFoulCount: (json['majorFoulCount'] as num?)?.toInt(),
      minorFoulCount: (json['minorFoulCount'] as num?)?.toInt(),
      penalties: json['penalties'] as String?,
      rp: (json['rp'] as num?)?.toInt(),
      superchargedAchieved: json['superchargedAchieved'] as bool?,
      totalAutoPoints: (json['totalAutoPoints'] as num?)?.toInt(),
      totalPoints: (json['totalPoints'] as num?)?.toInt(),
      totalTeleopPoints: (json['totalTeleopPoints'] as num?)?.toInt(),
      totalTowerPoints: (json['totalTowerPoints'] as num?)?.toInt(),
      traversalAchieved: json['traversalAchieved'] as bool?,
    );

Map<String, dynamic> _$$ScoreBreakdown2026ImplToJson(
        _$ScoreBreakdown2026Impl instance) =>
    <String, dynamic>{
      'adjustPoints': instance.adjustPoints,
      'autoTowerPoints': instance.autoTowerPoints,
      'autoTowerRobot1': instance.autoTowerRobot1,
      'autoTowerRobot2': instance.autoTowerRobot2,
      'autoTowerRobot3': instance.autoTowerRobot3,
      'endGameTowerPoints': instance.endGameTowerPoints,
      'endGameTowerRobot1': instance.endGameTowerRobot1,
      'endGameTowerRobot2': instance.endGameTowerRobot2,
      'endGameTowerRobot3': instance.endGameTowerRobot3,
      'energizedAchieved': instance.energizedAchieved,
      'foulPoints': instance.foulPoints,
      'g206Penalty': instance.g206Penalty,
      'hubScore': instance.hubScore?.toJson(),
      'majorFoulCount': instance.majorFoulCount,
      'minorFoulCount': instance.minorFoulCount,
      'penalties': instance.penalties,
      'rp': instance.rp,
      'superchargedAchieved': instance.superchargedAchieved,
      'totalAutoPoints': instance.totalAutoPoints,
      'totalPoints': instance.totalPoints,
      'totalTeleopPoints': instance.totalTeleopPoints,
      'totalTowerPoints': instance.totalTowerPoints,
      'traversalAchieved': instance.traversalAchieved,
    };
