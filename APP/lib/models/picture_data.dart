import 'package:freezed_annotation/freezed_annotation.dart';

part 'picture_data.freezed.dart';
part 'picture_data.g.dart';

@freezed
class PictureData with _$PictureData {
  const factory PictureData({
    required String user_id,
    required int team_number,
    required int time,
    required String event_code,
    required String image_id,
    required String link,
  }) = _PictureData;

  factory PictureData.fromJson(Map<String, dynamic> json) =>
      _$PictureDataFromJson(json);
}
