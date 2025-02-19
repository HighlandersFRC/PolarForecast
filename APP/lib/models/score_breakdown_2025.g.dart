// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'score_breakdown_2025.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ScoreBreakdown2025Impl _$$ScoreBreakdown2025ImplFromJson(
        Map<String, dynamic> json) =>
    _$ScoreBreakdown2025Impl(
      adjustPoints: (json['adjustPoints'] as num).toInt(),
      algaePoints: (json['algaePoints'] as num).toInt(),
      autoBonusAchieved: json['autoBonusAchieved'] as bool,
      autoCoralCount: (json['autoCoralCount'] as num).toInt(),
      autoCoralPoints: (json['autoCoralPoints'] as num).toInt(),
      autoLineRobot1: json['autoLineRobot1'] as String,
      autoLineRobot2: json['autoLineRobot2'] as String,
      autoLineRobot3: json['autoLineRobot3'] as String,
      autoMobilityPoints: (json['autoMobilityPoints'] as num).toInt(),
      autoPoints: (json['autoPoints'] as num).toInt(),
      autoReef: Reef.fromJson(json['autoReef'] as Map<String, dynamic>),
      bargeBonusAchieved: json['bargeBonusAchieved'] as bool,
      coopertitionCriteriaMet: json['coopertitionCriteriaMet'] as bool,
      coralBonusAchieved: json['coralBonusAchieved'] as bool,
      endGameBargePoints: (json['endGameBargePoints'] as num).toInt(),
      endGameRobot1: json['endGameRobot1'] as String,
      endGameRobot2: json['endGameRobot2'] as String,
      endGameRobot3: json['endGameRobot3'] as String,
      foulPoints: (json['foulPoints'] as num).toInt(),
      g206Penalty: json['g206Penalty'] as bool,
      g408Penalty: json['g408Penalty'] as bool,
      g424Penalty: json['g424Penalty'] as bool,
      netAlgaeCount: (json['netAlgaeCount'] as num).toInt(),
      rp: (json['rp'] as num).toInt(),
      techFoulCount: (json['techFoulCount'] as num).toInt(),
      teleopCoralCount: (json['teleopCoralCount'] as num).toInt(),
      teleopCoralPoints: (json['teleopCoralPoints'] as num).toInt(),
      teleopPoints: (json['teleopPoints'] as num).toInt(),
      teleopReef: Reef.fromJson(json['teleopReef'] as Map<String, dynamic>),
      totalPoints: (json['totalPoints'] as num).toInt(),
      wallAlgaeCount: (json['wallAlgaeCount'] as num).toInt(),
    );

Map<String, dynamic> _$$ScoreBreakdown2025ImplToJson(
        _$ScoreBreakdown2025Impl instance) =>
    <String, dynamic>{
      'adjustPoints': instance.adjustPoints,
      'algaePoints': instance.algaePoints,
      'autoBonusAchieved': instance.autoBonusAchieved,
      'autoCoralCount': instance.autoCoralCount,
      'autoCoralPoints': instance.autoCoralPoints,
      'autoLineRobot1': instance.autoLineRobot1,
      'autoLineRobot2': instance.autoLineRobot2,
      'autoLineRobot3': instance.autoLineRobot3,
      'autoMobilityPoints': instance.autoMobilityPoints,
      'autoPoints': instance.autoPoints,
      'autoReef': instance.autoReef.toJson(),
      'bargeBonusAchieved': instance.bargeBonusAchieved,
      'coopertitionCriteriaMet': instance.coopertitionCriteriaMet,
      'coralBonusAchieved': instance.coralBonusAchieved,
      'endGameBargePoints': instance.endGameBargePoints,
      'endGameRobot1': instance.endGameRobot1,
      'endGameRobot2': instance.endGameRobot2,
      'endGameRobot3': instance.endGameRobot3,
      'foulPoints': instance.foulPoints,
      'g206Penalty': instance.g206Penalty,
      'g408Penalty': instance.g408Penalty,
      'g424Penalty': instance.g424Penalty,
      'netAlgaeCount': instance.netAlgaeCount,
      'rp': instance.rp,
      'techFoulCount': instance.techFoulCount,
      'teleopCoralCount': instance.teleopCoralCount,
      'teleopCoralPoints': instance.teleopCoralPoints,
      'teleopPoints': instance.teleopPoints,
      'teleopReef': instance.teleopReef.toJson(),
      'totalPoints': instance.totalPoints,
      'wallAlgaeCount': instance.wallAlgaeCount,
    };

_$ReefImpl _$$ReefImplFromJson(Map<String, dynamic> json) => _$ReefImpl(
      botRow: ReefRow.fromJson(json['botRow'] as Map<String, dynamic>),
      midRow: ReefRow.fromJson(json['midRow'] as Map<String, dynamic>),
      topRow: ReefRow.fromJson(json['topRow'] as Map<String, dynamic>),
      trough: (json['trough'] as num).toInt(),
    );

Map<String, dynamic> _$$ReefImplToJson(_$ReefImpl instance) =>
    <String, dynamic>{
      'botRow': instance.botRow.toJson(),
      'midRow': instance.midRow.toJson(),
      'topRow': instance.topRow.toJson(),
      'trough': instance.trough,
    };

_$ReefRowImpl _$$ReefRowImplFromJson(Map<String, dynamic> json) =>
    _$ReefRowImpl(
      nodeA: json['nodeA'] as bool,
      nodeB: json['nodeB'] as bool,
      nodeC: json['nodeC'] as bool,
      nodeD: json['nodeD'] as bool,
      nodeE: json['nodeE'] as bool,
      nodeF: json['nodeF'] as bool,
      nodeG: json['nodeG'] as bool,
      nodeH: json['nodeH'] as bool,
      nodeI: json['nodeI'] as bool,
      nodeJ: json['nodeJ'] as bool,
      nodeK: json['nodeK'] as bool,
      nodeL: json['nodeL'] as bool,
    );

Map<String, dynamic> _$$ReefRowImplToJson(_$ReefRowImpl instance) =>
    <String, dynamic>{
      'nodeA': instance.nodeA,
      'nodeB': instance.nodeB,
      'nodeC': instance.nodeC,
      'nodeD': instance.nodeD,
      'nodeE': instance.nodeE,
      'nodeF': instance.nodeF,
      'nodeG': instance.nodeG,
      'nodeH': instance.nodeH,
      'nodeI': instance.nodeI,
      'nodeJ': instance.nodeJ,
      'nodeK': instance.nodeK,
      'nodeL': instance.nodeL,
    };
