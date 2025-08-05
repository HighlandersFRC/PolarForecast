import 'package:freezed_annotation/freezed_annotation.dart';

part 'scouting_report.freezed.dart';
part 'scouting_report.g.dart';

@freezed
class ScoutingReport with _$ScoutingReport {
  const factory ScoutingReport({
    required String group,
    required String event,
    required List<ScoutingReportEntry> report,
  }) = _ScoutingReport;

  factory ScoutingReport.fromJson(Map<String, dynamic> json) =>
      _$ScoutingReportFromJson(json);
}

@freezed
class ScoutingReportEntry with _$ScoutingReportEntry {
  const factory ScoutingReportEntry({
    required List<ScoutingReportScout> scouts,
    required String eventCode,
    required String groupId,
    required double trustRatings,
    required double entries,
    required double contribution,
  }) = _ScoutingReportEntry;

  factory ScoutingReportEntry.fromJson(Map<String, dynamic> json) =>
      _$ScoutingReportEntryFromJson(json);
}

@freezed
class ScoutingReportScout with _$ScoutingReportScout {
  const factory ScoutingReportScout({
    required ScoutingReportUser name,
  }) = _ScoutingReportScout;

  factory ScoutingReportScout.fromJson(Map<String, dynamic> json) =>
      _$ScoutingReportScoutFromJson(json);
}

@freezed
class ScoutingReportUser with _$ScoutingReportUser {
  const factory ScoutingReportUser({
    required String user_id,
    String? first_name,
    String? username,
    required int team_number,
  }) = _ScoutingReportUser;

  factory ScoutingReportUser.fromJson(Map<String, dynamic> json) =>
      _$ScoutingReportUserFromJson(json);
}
