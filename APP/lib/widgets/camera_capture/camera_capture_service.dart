import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'unsupported_stub.dart'
    if (dart.library.io) 'unsupported_stub.dart'
    if (dart.library.html) 'web_camera_capture_service.dart';

// TODO: Implement the CameraCaptureServices for more than just web
abstract class CameraCaptureService {
  Future<img.Image?> getImage(BuildContext context);
}

CameraCaptureService createCameraCaptureService() {
  return getService();
}
