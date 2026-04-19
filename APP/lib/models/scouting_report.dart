import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:scouting_app/models/scout_info.dart';

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
    required ScoutInfo scout,
    required String eventCode,
    required String groupId,
    required double trustRatings,
    required double entries,
    required double contribution,
  }) = _ScoutingReportEntry;

  factory ScoutingReportEntry.fromJson(Map<String, dynamic> json) =>
      _$ScoutingReportEntryFromJson(json);
}
