// lib/image_utils.dart

import 'dart:typed_data';

class ImageUtils {
  static List<List<List<int>>> convertBytesToRGBTensor(Uint8List bytes, int width, int height) {
    final tensor = List.generate(height, (_) => List.generate(width, (_) => List.filled(3, 0)));
    int pixelIndex = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final r = bytes[pixelIndex++];
        final g = bytes[pixelIndex++];
        final b = bytes[pixelIndex++];
        tensor[y][x][0] = r;
        tensor[y][x][1] = g;
        tensor[y][x][2] = b;
      }
    }

    return tensor;
  }

  static List<List<List<double>>> normalizeTensor(List<List<List<int>>> tensor) {
    final height = tensor.length;
    final width = tensor[0].length;
    final normalized = List.generate(height, (y) => List.generate(width, (x) => List.filled(3, 0.0)));

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        for (int c = 0; c < 3; c++) {
          normalized[y][x][c] = tensor[y][x][c] / 255.0;
        }
      }
    }

    return normalized;
  }

  static Uint8List flattenNormalizedTensor(List<List<List<double>>> tensor) {
    final height = tensor.length;
    final width = tensor[0].length;
    final buffer = Float32List(width * height * 3);
    int index = 0;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        for (int c = 0; c < 3; c++) {
          buffer[index++] = tensor[y][x][c];
        }
      }
    }

    return buffer.buffer.asUint8List();
  }
}

/// Example usage
void main() {
  final raw = Uint8List.fromList(List.generate(224 * 224 * 3, (i) => i % 256));
  final rgb = ImageUtils.convertBytesToRGBTensor(raw, 224, 224);
  final norm = ImageUtils.normalizeTensor(rgb);
  final flat = ImageUtils.flattenNormalizedTensor(norm);

  print('Flattened tensor length: ${flat.length}');
}