import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import '../models/alliance.dart';

part 'alliances.freezed.dart';
part 'alliances.g.dart';

@freezed
class Alliances with _$Alliances {
  const factory Alliances({
    required Alliance red,
    required Alliance blue,
  }) = _Alliances;

  factory Alliances.fromJson(Map<String, Object?> json) =>
      _$AlliancesFromJson(json);
}
