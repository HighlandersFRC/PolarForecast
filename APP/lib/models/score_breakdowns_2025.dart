import 'package:freezed_annotation/freezed_annotation.dart';

import 'score_breakdown_2025.dart';

part 'score_breakdowns_2025.freezed.dart';
part 'score_breakdowns_2025.g.dart';

@freezed
class ScoreBreakdowns2025 with _$ScoreBreakdowns2025 {
  const factory ScoreBreakdowns2025({
    required ScoreBreakdown2025 red,
    required ScoreBreakdown2025 blue,
  }) = _ScoreBreakdowns2025;

  factory ScoreBreakdowns2025.fromJson(Map<String, Object?> json) =>
      _$ScoreBreakdowns2025FromJson(json);
}
