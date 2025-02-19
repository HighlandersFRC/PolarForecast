import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/alliances.dart';

import 'score_breakdowns_2025.dart';

part 'match_2025.freezed.dart';
part 'match_2025.g.dart';

@freezed
class Match2025 with _$Match2025 {
  const factory Match2025({
    int? actual_time,
    required Alliances alliances,
    required String comp_level,
    required String event_key,
    required String key,
    required int match_number,
    int? post_result_time,
    int? predicted_time,
    ScoreBreakdowns2025? score_breakdown,
    required int set_number,
    required int time,
    required List<Map<String, dynamic>> videos,
    required String winning_alliance,
  }) = _Match2025;

  factory Match2025.fromJson(Map<String, Object?> json) =>
      _$Match2025FromJson(json);
}
