import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'alliance.freezed.dart';
part 'alliance.g.dart';

@freezed
class Alliance with _$Alliance {
  const factory Alliance({
    required List<String> dq_team_keys,
    required List<String> surrogate_team_keys,
    required List<String> team_keys,
    required int score,
  }) = _Alliance;

  factory Alliance.fromJson(Map<String, Object?> json) =>
      _$AllianceFromJson(json);
}
