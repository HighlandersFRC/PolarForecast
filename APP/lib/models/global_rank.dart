import 'package:freezed_annotation/freezed_annotation.dart';

import 'team_stats_2025.dart';

part 'global_rank.freezed.dart';
part 'global_rank.g.dart';

@freezed
class GlobalRank with _$GlobalRank {
  const factory GlobalRank({
    required String team,
    required DateTime eventDate,
    required String event,
    @Default([]) List<String> all_events,
    required TeamStats2025 data,
  }) = _GlobalRank;

  factory GlobalRank.fromJson(Map<String, dynamic> json) =>
      _$GlobalRankFromJson(json);
}
