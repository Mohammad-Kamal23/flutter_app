// lib/core/camera_feed_handler.dart

import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

class CameraFeedHandler {
  final int width;
  final int height;
  final int fps;
  final StreamController<Uint8List> _frameStreamController = StreamController.broadcast();
  Timer? _frameTimer;

  CameraFeedHandler({
    this.width = 224,
    this.height = 224,
    this.fps = 15,
  });

  Stream<Uint8List> get frameStream => _frameStreamController.stream;

  void startFeed() {
    final frameDuration = Duration(milliseconds: (1000 / fps).floor());

    _frameTimer = Timer.periodic(frameDuration, (_) async {
      Uint8List frame = await _generateMockCameraFrame();
      _frameStreamController.add(frame);
    });
  }

  void stopFeed() {
    _frameTimer?.cancel();
    _frameTimer = null;
  }

  Future<Uint8List> _generateMockCameraFrame() async {
    // This simulates camera data. Replace with platform channel call or camera API later.
    final pixels = width * height * 3; // RGB
    final random = Random();
    return Uint8List.fromList(List.generate(pixels, (_) => random.nextInt(256)));
  }

  void dispose() {
    stopFeed();
    _frameStreamController.close();
  }
}

/// Example usage
void main() {
  final cameraHandler = CameraFeedHandler();

  cameraHandler.frameStream.listen((frameData) {
    print('Received frame of length: ${frameData.length}');
  });

  cameraHandler.startFeed();

  // Stop after 5 seconds for demo
  Future.delayed(Duration(seconds: 5), cameraHandler.dispose);
}
