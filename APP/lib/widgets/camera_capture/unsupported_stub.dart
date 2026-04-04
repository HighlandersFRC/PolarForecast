import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'camera_capture_service.dart';

class UnsupportedCameraCaptureService implements CameraCaptureService {
  @override
  Future<Uint8List?> getImage(BuildContext context) async {
    debugPrint("Camera not supported on this platform");
    return null;
  }

  @override
  Future<Uint8List?> pickImageFromGallery(BuildContext context) async {
    debugPrint("Gallery not supported on this platform");
    return null;
  }
}

CameraCaptureService getService() {
  return UnsupportedCameraCaptureService();
}
