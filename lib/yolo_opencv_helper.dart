import 'package:flutter/services.dart';
import 'dart:typed_data';

class YoloOpencvHelper {
  static const platform =
      MethodChannel('com.yourcompany.cam_droid/yolo_opencv');

  Future<Uint8List> processImage(Uint8List imageData) async {
    try {
      final Uint8List result =
          await platform.invokeMethod('processImage', imageData);
      return result;
    } on PlatformException catch (e) {
      print("Failed to process image: '${e.message}'.");
      return Uint8List(0);
    }
  }
}
