import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'unsupported_stub.dart'
    if (dart.library.io) 'unsupported_stub.dart'
    if (dart.library.html) 'web_camera_capture_service.dart';

// TODO: Implement the CameraCaptureServices for more than just web
abstract class CameraCaptureService {
  Future<Uint8List?> getImage(BuildContext context);
  Future<Uint8List?> pickImageFromGallery(BuildContext context);
}

CameraCaptureService createCameraCaptureService() {
  return getService();
}
