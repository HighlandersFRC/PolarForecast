// filepath: /c:/Users/Highlander/Documents/GitHub/PolarForecast/APP/lib/models/deaths_form.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'scout_info.dart';

part 'deaths_form.freezed.dart';
part 'deaths_form.g.dart';

@freezed
class Death with _$Death {
  const factory Death({
    required int match_number,
    @Default(-1) int severity,
    @Default('') String death_reason,
  }) = _Death;

  factory Death.fromJson(Map<String, dynamic> json) => _$DeathFromJson(json);
}

@freezed
class Deaths with _$Deaths {
  const factory Deaths({
    required ScoutInfo scout_info,
    required String event_code,
    required String team_key,
    @Default([]) List<Death> deaths,
    required int total,
    required int average,
    required int time,
  }) = _Deaths;

  factory Deaths.fromJson(Map<String, dynamic> json) => _$DeathsFromJson(json);
}
