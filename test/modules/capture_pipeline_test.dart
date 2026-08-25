import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/models/pipeline_error_code.dart';
import 'package:verimask/modules/capture_pipeline.dart';
import 'package:verimask/modules/image_processor.dart';

class _FakeFrameCapture implements FrameCapture {
  final bool shouldThrow;
  _FakeFrameCapture({this.shouldThrow = false});

  @override
  Future<CapturedFrame> captureFrame() async {
    if (shouldThrow) throw Exception('Camera error');
    final pixels = Uint8List(4 * 4 * 4);
    return CapturedFrame(
      jpegPath: '/tmp/fake_frame.jpg',
      imageData: ImageData(width: 4, height: 4, pixels: pixels),
    );
  }
}

class _FakeLandmarkDetector implements LandmarkDetector {
  @override
  Future<List<LandmarkRect>> detectLandmarks(String jpegPath) async {
    return [
      const LandmarkRect(x: 0, y: 0, width: 2, height: 1),
    ];
  }
}

class _FakeSegmentationProvider implements SegmentationProvider {
  @override
  Future<List<bool>> segment(String jpegPath, int width, int height) async =>
      List.filled(width * height, true);

  @override
  Future<List<double>> segmentRaw(String jpegPath, int width, int height) async =>
      List.filled(width * height, 1.0);
}

void main() {
  group('CaptureAndProcessPipeline', () {
    test('handles capture failure gracefully', () async {
      final pipeline = CaptureAndProcessPipeline(
        frameCapture: _FakeFrameCapture(shouldThrow: true),
        landmarkDetector: _FakeLandmarkDetector(),
        segmentationProvider: _FakeSegmentationProvider(),
      );

      final result = await pipeline.captureAndProcess();

      expect(result.success, isFalse);
      expect(result.errorCode, PipelineErrorCode.captureError);
    });
  });
}
