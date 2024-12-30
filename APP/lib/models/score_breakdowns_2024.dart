import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import 'score_breakdown_2024.dart';

part 'score_breakdowns_2024.freezed.dart';
part 'score_breakdowns_2024.g.dart';

@freezed
class ScoreBreakdowns2024 with _$ScoreBreakdowns2024 {
  const factory ScoreBreakdowns2024({
    required ScoreBreakdown2024 red,
    required ScoreBreakdown2024 blue,
  }) = _ScoreBreakdowns2024;

  factory ScoreBreakdowns2024.fromJson(Map<String, Object?> json) =>
      _$ScoreBreakdowns2024FromJson(json);
}
