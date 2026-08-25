import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/modules/image_processor.dart';
import 'package:verimask/services/landmark_detector_impl.dart';

/// Unit tests for LandmarkDetectorImpl.
///
/// Note: Tests that create detector instances require Flutter binding initialization
/// and are marked as integration tests. These tests verify constants and data structures.
void main() {
  group('LandmarkDetectorImpl Unit Tests', () {
    test('should have correct margin factors', () {
      expect(LandmarkDetectorImpl.eyeMarginFactor, 1.5);
      expect(LandmarkDetectorImpl.noseMarginFactor, 2.0);
      expect(LandmarkDetectorImpl.mouthMarginFactor, 1.8);
    });

    test('should have correct base landmark size', () {
      expect(LandmarkDetectorImpl.baseLandmarkSize, 30);
    });

    test('LandmarkDetectionException should have correct format', () {
      final exception = LandmarkDetectionException('test_type', 'test message');
      
      expect(exception.type, 'test_type');
      expect(exception.message, 'test message');
      expect(
        exception.toString(),
        'LandmarkDetectionException(test_type): test message',
      );
    });

    test('should validate ImageData format', () {
      // Valid ImageData
      final validImage = ImageData(
        width: 100,
        height: 100,
        pixels: Uint8List(100 * 100 * 4),
      );
      expect(validImage.width, 100);
      expect(validImage.height, 100);
      expect(validImage.pixels.length, 100 * 100 * 4);

      // Invalid ImageData should throw
      expect(
        () => ImageData(
          width: 100,
          height: 100,
          pixels: Uint8List(100), // Wrong size
        ),
        throwsArgumentError,
      );
    });

    test('should create valid LandmarkRect', () {
      const rect = LandmarkRect(
        x: 10,
        y: 20,
        width: 30,
        height: 40,
      );

      expect(rect.x, 10);
      expect(rect.y, 20);
      expect(rect.width, 30);
      expect(rect.height, 40);
    });

    test('should calculate correct landmark sizes with margin factors', () {
      const baseSize = LandmarkDetectorImpl.baseLandmarkSize;

      // Eye size: 30 * 1.5 = 45
      final eyeSize = (baseSize * LandmarkDetectorImpl.eyeMarginFactor).toInt();
      expect(eyeSize, 45);

      // Nose size: 30 * 2.0 = 60
      final noseSize = (baseSize * LandmarkDetectorImpl.noseMarginFactor).toInt();
      expect(noseSize, 60);

      // Mouth size: 30 * 1.8 = 54
      final mouthSize = (baseSize * LandmarkDetectorImpl.mouthMarginFactor).toInt();
      expect(mouthSize, 54);
    });
  });
}
