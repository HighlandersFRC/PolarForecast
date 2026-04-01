import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'camera_capture_service.dart';

class WebCameraCaptureService implements CameraCaptureService {
  @override
  Future<Uint8List?> getImage(BuildContext context) async {
    // your web logic here
    return null;
  }

  @override
  Future<Uint8List?> pickImageFromGallery(BuildContext context) async {
    // your web logic here
    return null;
  }
}

CameraCaptureService getService() {
  return WebCameraCaptureService();
}
