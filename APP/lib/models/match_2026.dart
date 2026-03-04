import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/alliances.dart';

import 'score_breakdown_2026.dart';

part 'match_2026.freezed.dart';
part 'match_2026.g.dart';

@freezed
class Match2026 with _$Match2026 {
  const factory Match2026({
    int? actual_time,
    required Alliances alliances,
    required String comp_level,
    required String event_key,
    required String key,
    required int match_number,
    int? post_result_time,
    int? predicted_time,
    ScoreBreakdown2026? score_breakdown,
    required int set_number,
    required int time,
    required List<Map<String, dynamic>> videos,
    required String winning_alliance,
  }) = _Match2026;

  factory Match2026.fromJson(Map<String, Object?> json) =>
      _$Match2026FromJson(json);
}
