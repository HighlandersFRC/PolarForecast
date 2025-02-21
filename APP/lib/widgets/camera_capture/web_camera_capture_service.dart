import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:scouting_app/widgets/camera_capture/camera_capture_service.dart';

class WebCameraCaptureService extends CameraCaptureService {
  @override
  Future<img.Image?> getImage(BuildContext context) async {
    ImagePickerPlugin imagePicker = ImagePickerPlugin();
    XFile? file =
        await imagePicker.getImageFromSource(source: ImageSource.camera);
    if (file == null) {
      return null;
    }
    return img.decodeImage(await file.readAsBytes());
  }
}

CameraCaptureService getService() {
  return WebCameraCaptureService();
}
