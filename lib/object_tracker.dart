// File: lib/object_tracker.dart

import 'dart:math';
import 'geometry.dart';

class TrackedObject {
  final int id;
  final String label;
  final double confidence;
  Rect bbox;
  int missedFrames;

  TrackedObject({
    required this.id,
    required this.label,
    required this.confidence,
    required this.bbox,
    this.missedFrames = 0,
  });
}

class ObjectTracker {
  final double iouThreshold;
  final int maxMissedFrames;
  int _nextId = 0;
  final List<TrackedObject> _trackedObjects = [];

  ObjectTracker({this.iouThreshold = 0.3, this.maxMissedFrames = 5});

  List<TrackedObject> update(List<Map<String, dynamic>> detections) {
    final updated = <TrackedObject>[];
    final matched = <int>{};

    for (final detection in detections) {
      final bbox = detection['bbox'] as Rect;
      final label = detection['label'] as String;
      final confidence = detection['confidence'] as double;

      TrackedObject? bestMatch;
      double bestIoU = 0.0;

      for (var i = 0; i < _trackedObjects.length; i++) {
        final existing = _trackedObjects[i];
        final iou = _calculateIoU(existing.bbox, bbox);
        if (iou > bestIoU && iou > iouThreshold) {
          bestIoU = iou;
          bestMatch = existing;
        }
      }

      if (bestMatch != null) {
        bestMatch.bbox = bbox;
        bestMatch.missedFrames = 0;
        updated.add(bestMatch);
        matched.add(bestMatch.id);
      } else {
        final newObj = TrackedObject(
          id: _nextId++,
          label: label,
          confidence: confidence,
          bbox: bbox,
        );
        updated.add(newObj);
      }
    }

    for (var i = 0; i < _trackedObjects.length; i++) {
      final candidate = _trackedObjects[i];
      if (!matched.contains(candidate.id)) {
        candidate.missedFrames += 1;
        if (candidate.missedFrames <= maxMissedFrames) {
          updated.add(candidate);
        }
      }
    }

    _trackedObjects
      ..clear()
      ..addAll(updated);

    return _trackedObjects;
  }

  double _calculateIoU(Rect a, Rect b) {
    final double x1 = max(a.left, b.left);
    final double y1 = max(a.top, b.top);
    final double x2 = min(a.right, b.right);
    final double y2 = min(a.bottom, b.bottom);

    final double interArea = max(0, x2 - x1) * max(0, y2 - y1);
    final double unionArea = a.width * a.height + b.width * b.height - interArea;

    return unionArea == 0 ? 0.0 : interArea / unionArea;
  }
}

void main() {
  final tracker = ObjectTracker();

  final detections = [
    {
      'label': 'leaf',
      'confidence': 0.95,
      'bbox': Rect(left: 50, top: 50, width: 100, height: 100),
    }
  ];

  final tracked = tracker.update(detections);
  for (final obj in tracked) {
    print('Tracked ID: ${obj.id}, Label: ${obj.label}, BBox: (${obj.bbox.left}, ${obj.bbox.top}, ${obj.bbox.width}, ${obj.bbox.height})');
  }
}
