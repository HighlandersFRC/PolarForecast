import 'package:freezed_annotation/freezed_annotation.dart';

part 'alliance_request.freezed.dart';
part 'alliance_request.g.dart';

@freezed
class AllianceRequest with _$AllianceRequest {
  const factory AllianceRequest(
      {required String group_1,
      required String group_2,
      required String group_1_affiliation,
      required String group_2_affiliation,
      required String event,
      required int request_time,
      required bool accepted}) = _AllianceRequest;

  factory AllianceRequest.fromJson(Map<String, Object?> json) =>
      _$AllianceRequestFromJson(json);
}
