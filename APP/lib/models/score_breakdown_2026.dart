import 'package:freezed_annotation/freezed_annotation.dart';

part 'score_breakdown_2026.freezed.dart';
part 'score_breakdown_2026.g.dart';

@freezed
class ScoreBreakdown2026 with _$ScoreBreakdown2026 {
  const factory ScoreBreakdown2026(
      {required bool climb,
      required int feed_amount,
      required int intake_amount,
      required int shoot_amount,
      required int goes_under_trench,
      required int goes_over_bump,
      required int climb_side,
      required int cycles_completed,
      required int shoots_from_X,
      required int shoots_from_Y}) = _ScoreBreakdown2026;

  factory ScoreBreakdown2026.fromJson(Map<String, Object?> json) =>
      _$ScoreBreakdown2026FromJson(json);
}
