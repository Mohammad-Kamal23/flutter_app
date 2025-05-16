// File: lib/classifier_page.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'camera_feed_handler.dart';
import 'object_tracker.dart';
import 'image_utils.dart';

import 'inference_service.dart';
import 'tracker_overlay.dart';

class ClassifierPage extends StatefulWidget {
  const ClassifierPage({Key? key}) : super(key: key);

  @override
  State<ClassifierPage> createState() => _ClassifierPageState();
}

class _ClassifierPageState extends State<ClassifierPage> {
  final CameraFeedHandler _cameraFeedHandler = CameraFeedHandler();
  final ObjectTracker _objectTracker = ObjectTracker();
  final TrackerOverlay _overlay = TrackerOverlay(previewWidth: 224, previewHeight: 224);

  List<PositionedBox> _overlayBoxes = [];
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initializePipeline();
  }

  Future<void> _initializePipeline() async {
    await InferenceService.loadModel('assets/mobilenetv2_best.tflite');
    _cameraFeedHandler.frameStream.listen(_processFrame);
    _cameraFeedHandler.startFeed();
  }

  Future<void> _processFrame(Uint8List bytes) async {
    if (_isCapturing) return;

    final rgb = ImageUtils.convertBytesToRGBTensor(bytes, 224, 224);
    final norm = ImageUtils.normalizeTensor(rgb);
    final input = ImageUtils.flattenNormalizedTensor(norm);

    final outputs = await InferenceService.runInferenceBytes(input);

    // Assume `outputs` returns List<Map<String, dynamic>> each with 'label', 'confidence', and 'bbox' Rect
    final tracked = _objectTracker.update(outputs);

    final boxes = _overlay.buildOverlay(tracked);
    setState(() => _overlayBoxes = boxes);

    for (final box in boxes) {
      if (_isCentered(box)) {
        _isCapturing = true;
        onObjectAligned();
        break;
      }
    }
  }

  bool _isCentered(PositionedBox box) {
    final centerX = box.left + box.width / 2;
    final centerY = box.top + box.height / 2;
    return centerX > 84 && centerX < 140 && centerY > 84 && centerY < 140;
  }

  void onObjectAligned() {
    debugPrint('Object aligned! Ready for capture');
    // Placeholder for future auto-capture logic
  }

  @override
  void dispose() {
    _cameraFeedHandler.dispose();
    InferenceService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tuta Severity Classifier')),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),
          ..._overlayBoxes.map((box) => Positioned(
                left: box.left,
                top: box.top,
                width: box.width,
                height: box.height,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      color: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Text(
                        '${box.label} ${(box.confidence * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}