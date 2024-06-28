import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'dart:async';
import 'dart:html' as html; // Adicionado

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ObjectDetectionScreen(),
    );
  }
}

class ObjectDetectionScreen extends StatefulWidget {
  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  CameraController? cameraController;
  FlutterVision vision = FlutterVision();
  List<CameraDescription>? cameras;
  bool isDetecting = false;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    cameraController = CameraController(cameras![0], ResolutionPreset.high);
    await cameraController!.initialize();
    setState(() {});
  }

  Future<void> detectObjects() async {
    if (cameraController != null &&
        cameraController!.value.isInitialized &&
        !isDetecting) {
      isDetecting = true;
      final cameraImage = await cameraController!.takePicture();
      final imageBytes = await cameraImage.readAsBytes();

      final html.ImageElement imageElement = html.ImageElement();
      imageElement.src = cameraImage.path;
      await imageElement.onLoad.first;
      final imageHeight = imageElement.height;
      final imageWidth = imageElement.width;

      await vision.loadYoloModel(
        labels: 'assets/labels.txt',
        modelPath: 'assets/yolov8n.tflite',
        modelVersion: "yolov8",
        quantization: false,
        numThreads: 1,
        useGpu: false,
      );

      final result = await vision.yoloOnImage(
        bytesList: imageBytes,
        imageHeight: imageHeight,
        imageWidth: imageWidth,
        iouThreshold: 0.4,
        confThreshold: 0.4,
        classThreshold: 0.5,
      );

      print(result);
      isDetecting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Object Detection with YOLOv8 Nano'),
      ),
      body: Column(
        children: [
          if (cameraController != null && cameraController!.value.isInitialized)
            AspectRatio(
              aspectRatio: cameraController!.value.aspectRatio,
              child: CameraPreview(cameraController!),
            ),
          ElevatedButton(
            onPressed: detectObjects,
            child: Text('Detect Objects'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    vision.closeYoloModel();
    super.dispose();
  }
}
