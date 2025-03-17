import 'dart:typed_data';

import 'package:flutter/src/widgets/framework.dart';
import 'package:scouting_app/widgets/camera_capture/camera_capture_service.dart';

class UnsupportedStub extends CameraCaptureService {
  @override
  Future<Uint8List?> getImage(BuildContext context) {
    // TODO: implement getImage
    throw UnimplementedError();
  }

  @override
  Future<Uint8List?> pickImageFromGallery(BuildContext context) {
    // TODO: implement pickImageFromGallery
    throw UnimplementedError();
  }
}

CameraCaptureService getService() {
  return UnsupportedStub();
}
