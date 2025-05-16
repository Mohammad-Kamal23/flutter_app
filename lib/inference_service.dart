// File: lib/inference_service.dart

import 'dart:typed_data';
import 'geometry.dart';
import 'tflite_helper.dart';

class InferenceService {
  static bool _modelLoaded = false;

  static Future<void> loadModel(String modelPath) async {
    if (_modelLoaded) return;
    await TFLiteHelper.loadModel();
    _modelLoaded = true;
  }

  static Future<List<Map<String, dynamic>>> runInferenceBytes(Uint8List inputBytes) async {
    if (!_modelLoaded) {
      throw Exception('Model not loaded. Call loadModel() first.');
    }

    final inputFloat = inputBytes.buffer.asFloat32List();
    final reshaped = List.generate(1, (_) => List.generate(224, (y) =>
      List.generate(224, (x) => List.generate(3, (c) {
        final i = (y * 224 + x) * 3 + c;
        return inputFloat[i];
      }))
    ));

    final labelCount = TFLiteHelper.labels.length;
    final output = List.generate(1, (_) => List.filled(labelCount, 0.0));

    TFLiteHelper.interpreter.run(reshaped, output);

    final scores = output[0];
    final labelIndex = scores.indexWhere((v) => v == scores.reduce((a, b) => a > b ? a : b));

    return [
      {
        'label': TFLiteHelper.labels[labelIndex],
        'confidence': scores[labelIndex],
        'bbox': Rect(left: 60, top: 60, width: 80, height: 80), // Placeholder for UI alignment
      }
    ];
  }

  static void dispose() {
    if (_modelLoaded) {
      TFLiteHelper.dispose();
      _modelLoaded = false;
    }
  }
}
