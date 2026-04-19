import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> downloadFile(Uint8List bytes, String filename) async {
  try {
    // Get the downloads directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getDownloadsDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      // Fallback
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory == null) {
      debugPrint("Could not get directory for saving file");
      return;
    }

    final filePath = '${directory.path}/$filename';
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // Share the file or open it
    await Share.shareXFiles([XFile(filePath)], text: 'Downloaded $filename');

    debugPrint("File saved to $filePath");
  } catch (e) {
    debugPrint("Error saving file: $e");
  }
}