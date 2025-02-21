import 'package:flutter/src/widgets/framework.dart';
import 'package:image/src/image.dart';
import 'package:scouting_app/widgets/camera_capture/camera_capture_service.dart';

class UnsupportedStub extends CameraCaptureService {
  @override
  Future<Image?> getImage(BuildContext context) {
    // TODO: implement getImage
    throw UnimplementedError();
  }
}

CameraCaptureService getService() {
  return UnsupportedStub();
}
