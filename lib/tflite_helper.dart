/*
// File: lib/tflite_helper.dart
// Comprehensive TFLite helper without external helper dependencies

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Represents a classification label with confidence score.
class Category {
  final String label;
  final double score;
  Category(this.label, this.score);

  @override
  String toString() => '$label: ${(score * 100).toStringAsFixed(1)}%';
}

/// Helper class to load a TFLite model, run inference on images, and
/// return sorted classification results.
class TFLiteHelper {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static const String _modelFile = 'assets/mobilenetv2_best.tflite';
  static const String _labelsFile = 'assets/labels.txt';
  static const int _inputSize = 224;

  /// Loads the TFLite model and label file. Call once at app startup.
  static Future<void> loadModel({int numThreads = 4}) async {
    final options = InterpreterOptions()..threads = numThreads;
    _interpreter = await Interpreter.fromAsset(_modelFile, options: options);

    final rawLabels = await rootBundle.loadString(_labelsFile);
    _labels = rawLabels
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }

  /// Classifies the given image file and returns top [maxResults] categories.
  static Future<List<Category>> classifyImage(
    File imageFile, {
    int maxResults = 4,
  }) async {
    if (_interpreter == null || _labels == null) {
      throw Exception('TFLite model or labels not loaded. Call loadModel() first.');
    }

    final bytes = await imageFile.readAsBytes();
    img.Image? ori = img.decodeImage(bytes);
    if (ori == null) throw Exception('Cannot decode image bytes');
    final resized = img.copyResize(ori, width: _inputSize, height: _inputSize);

    final input = _imageToByteListFloat32(resized);

    final labelCount = _labels!.length;
    final output = List.generate(1, (_) => List.filled(labelCount, 0.0));

    _interpreter!.run(input, output);

    final List<Category> predictions = [];
    for (int i = 0; i < labelCount; i++) {
      predictions.add(Category(_labels![i], output[0][i]));
    }
    predictions.sort((a, b) => b.score.compareTo(a.score));

    return predictions.take(maxResults).toList();
  }

  /// Converts [image] to Float32List normalized to [-1,1].
  static Float32List _imageToByteListFloat32(img.Image image) {
    final convertedBytes = Float32List(_inputSize * _inputSize * 3);
    int idx = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        final r = (pixel.r - 127.5) / 127.5;
        final g = (pixel.g - 127.5) / 127.5;
        final b = (pixel.b - 127.5) / 127.5;
        convertedBytes[idx++] = r;
        convertedBytes[idx++] = g;
        convertedBytes[idx++] = b;
      }
    }
    return convertedBytes;
  }

  /// Get labels list (public).
  static List<String> get labels {
    if (_labels == null) {
      throw Exception('Labels not loaded. Call loadModel() first.');
    }
    return _labels!;
  }

  /// Releases interpreter resources.
  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
*/








// File: lib/tflite_helper.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class Category {
  final String label;
  final double score;
  Category(this.label, this.score);

  @override
  String toString() => '$label: ${(score * 100).toStringAsFixed(1)}%';
}

class TFLiteHelper {
  static Interpreter? _interpreter;
  static List<String>? _labels;
  static const String _modelFile = 'assets/mobilenetv2_best.tflite';
  static const String _labelsFile = 'assets/labels.txt';
  static const int _inputSize = 224;

  static Future<void> loadModel({int numThreads = 4}) async {
    final options = InterpreterOptions()..threads = numThreads;
    _interpreter = await Interpreter.fromAsset(_modelFile, options: options);

    final rawLabels = await rootBundle.loadString(_labelsFile);
    _labels = rawLabels
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();
  }

  static Future<List<Category>> classifyImage(File imageFile, {int maxResults = 4}) async {
    if (_interpreter == null || _labels == null) {
      throw Exception('TFLite model or labels not loaded. Call loadModel() first.');
    }

    final bytes = await imageFile.readAsBytes();
    final img.Image? ori = img.decodeImage(bytes);
    if (ori == null) throw Exception('Cannot decode image bytes');

    final resized = img.copyResize(ori, width: _inputSize, height: _inputSize);
    final input = _imageToByteListFloat32(resized);

    final labelCount = _labels!.length;
    final output = List.generate(1, (_) => List.filled(labelCount, 0.0));

    _interpreter!.run(input, output);

    final List<Category> predictions = [];
    for (int i = 0; i < labelCount; i++) {
      predictions.add(Category(_labels![i], output[0][i]));
    }
    predictions.sort((a, b) => b.score.compareTo(a.score));

    return predictions.take(maxResults).toList();
  }

  static Float32List _imageToByteListFloat32(img.Image image) {
    final Float32List convertedBytes = Float32List(_inputSize * _inputSize * 3);
    int idx = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        final pixel = image.getPixel(x, y);
        convertedBytes[idx++] = (pixel.r - 127.5) / 127.5;
        convertedBytes[idx++] = (pixel.g - 127.5) / 127.5;
        convertedBytes[idx++] = (pixel.b - 127.5) / 127.5;
      }
    }
    return convertedBytes;
  }

  static Interpreter get interpreter {
    if (_interpreter == null) {
      throw Exception('Interpreter not loaded. Call loadModel() first.');
    }
    return _interpreter!;
  }

  static List<String> get labels {
    if (_labels == null) {
      throw Exception('Labels not loaded. Call loadModel() first.');
    }
    return _labels!;
  }

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _labels = null;
  }
}
