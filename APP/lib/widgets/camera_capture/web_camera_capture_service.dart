import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:scouting_app/widgets/camera_capture/camera_capture_service.dart';

class WebCameraCaptureService extends CameraCaptureService {
  @override
  Future<Uint8List?> getImage(BuildContext context) async {
    ImagePickerPlugin imagePicker = ImagePickerPlugin();
    return await (await imagePicker.getImageFromSource(
            source: ImageSource.camera))
        ?.readAsBytes();
  }

  @override
  Future<Uint8List?> pickImageFromGallery(BuildContext context) async {
    ImagePickerPlugin imagePicker = ImagePickerPlugin();
    return await (await imagePicker.getImageFromSource(
            source: ImageSource.gallery))
        ?.readAsBytes();
  }
}

CameraCaptureService getService() {
  return WebCameraCaptureService();
}
