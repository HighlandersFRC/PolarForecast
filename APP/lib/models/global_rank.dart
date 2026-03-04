import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scouting_app/models/team_stats_2026.dart';

part 'global_rank.freezed.dart';
part 'global_rank.g.dart';

@freezed
class GlobalRank with _$GlobalRank {
  const factory GlobalRank({
    required String team,
    required DateTime eventDate,
    required String event,
    @Default([]) List<String> all_events,
    required TeamStats2026 data,
  }) = _GlobalRank;

  factory GlobalRank.fromJson(Map<String, dynamic> json) =>
      _$GlobalRankFromJson(json);
}
