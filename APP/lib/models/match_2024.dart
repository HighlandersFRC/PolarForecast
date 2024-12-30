import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/alliances.dart';

import 'score_breakdowns_2024.dart';

part 'match_2024.freezed.dart';
part 'match_2024.g.dart';

@freezed
class Match2024 with _$Match2024 {
  const factory Match2024({
    int? actual_time,
    required Alliances alliances,
    required String comp_level,
    required String event_key,
    required String key,
    required int match_number,
    int? post_result_time,
    int? predicted_time,
    ScoreBreakdowns2024? score_breakdown,
    required int set_number,
    required int time,
    required List<Map<String, dynamic>> videos,
    required String winning_alliance,
  }) = _Match2024;

  factory Match2024.fromJson(Map<String, Object?> json) =>
      _$Match2024FromJson(json);
}
