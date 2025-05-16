// lib/ui/tracker_overlay.dart

import '../object_tracker.dart';
import 'geometry.dart';

class PositionedBox {
  final double left;
  final double top;
  final double width;
  final double height;
  final String label;
  final double confidence;

  const PositionedBox({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.label,
    required this.confidence,
  });
}

class TrackerOverlay {
  final double previewWidth;
  final double previewHeight;

  TrackerOverlay({required this.previewWidth, required this.previewHeight});

  List<PositionedBox> buildOverlay(List<TrackedObject> trackedObjects) {
    final boxes = <PositionedBox>[];

    for (final obj in trackedObjects) {
      boxes.add(PositionedBox(
        left: obj.bbox.left,
        top: obj.bbox.top,
        width: obj.bbox.width,
        height: obj.bbox.height,
        label: obj.label,
        confidence: obj.confidence,
      ));
    }

    return boxes;
  }
}

/// Example usage
void main() {
  final overlay = TrackerOverlay(previewWidth: 224, previewHeight: 224);

  final tracked = [
    TrackedObject(
      id: 1,
      label: 'leaf',
      confidence: 0.93,
      bbox: Rect(left: 60, top: 60, width: 80, height: 80),
    )
  ];

  final widgets = overlay.buildOverlay(tracked);

  for (final box in widgets) {
    print(
        'Overlay Box: (${box.left}, ${box.top}, ${box.width}, ${box.height}), Label: ${box.label}, Confidence: ${box.confidence}');
  }
}
