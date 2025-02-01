import 'package:freezed_annotation/freezed_annotation.dart';

part 'group_join_request.freezed.dart';
part 'group_join_request.g.dart';

@freezed
class GroupJoinRequest with _$GroupJoinRequest {
  const factory GroupJoinRequest(
      {required String group_name,
      required String group_id,
      required String user_id,
      required String username,
      required int request_time,
      required bool accepted}) = _GroupJoinRequest;

  factory GroupJoinRequest.fromJson(Map<String, Object?> json) =>
      _$GroupJoinRequestFromJson(json);
}
