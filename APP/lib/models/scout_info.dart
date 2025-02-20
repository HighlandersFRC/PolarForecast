import 'package:freezed_annotation/freezed_annotation.dart';

part 'scout_info.freezed.dart';
part 'scout_info.g.dart';

@freezed
class ScoutInfo with _$ScoutInfo {
  const factory ScoutInfo({
    required String user_id,
    String? first_name,
    String? username,
    required int team_number,
  }) = _ScoutInfo;

  factory ScoutInfo.fromJson(Map<String, dynamic> json) =>
      _$ScoutInfoFromJson(json);
}
