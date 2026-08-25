import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/modules/image_processor.dart';

ImageData _solidImage(int w, int h, int r, int g, int b, [int a = 255]) {
  final pixels = Uint8List(w * h * 4);
  for (var i = 0; i < w * h; i++) {
    pixels[i * 4] = r;
    pixels[i * 4 + 1] = g;
    pixels[i * 4 + 2] = b;
    pixels[i * 4 + 3] = a;
  }
  return ImageData(width: w, height: h, pixels: pixels);
}

void main() {
  group('ImageData', () {
    test('creates valid image with correct buffer size', () {
      final img = _solidImage(4, 3, 128, 64, 32);
      expect(img.width, equals(4));
      expect(img.height, equals(3));
      expect(img.pixels.length, equals(4 * 3 * 4));
    });

    test('throws on mismatched buffer size', () {
      expect(
        () => ImageData(width: 2, height: 2, pixels: Uint8List(10)),
        throwsArgumentError,
      );
    });

    test('clone produces independent copy', () {
      final original = _solidImage(2, 2, 100, 100, 100);
      final copy = original.clone();
      copy.pixels[0] = 0;
      expect(original.pixels[0], equals(100));
    });
  });

  group('expandFaceBbox', () {
    test('expands bbox with default factors', () {
      const original = LandmarkRect(x: 100, y: 100, width: 100, height: 100);
      final result = expandFaceBbox(original, 500, 500);

      expect(result.x, equals(85));
      expect(result.y, equals(85));
      expect(result.width, equals(130));
      expect(result.height, equals(135));
    });
  });

  group('applyFaceBlur', () {
    test('applies blur to bounding box region without modifying original', () {
      final source = _solidImage(10, 10, 255, 255, 255);
      const faceRect = LandmarkRect(x: 2, y: 2, width: 6, height: 6);

      final blurred = applyFaceBlur(source, faceRect, radius: 2, passes: 1);
      expect(blurred.width, equals(10));
      expect(blurred.height, equals(10));
      expect(source.pixels[0], equals(255));
    });
  });

  group('generateRadialGradient', () {
    test('generates gradient image of specified dimensions', () {
      final gradient = generateRadialGradient(20, 20);
      expect(gradient.width, equals(20));
      expect(gradient.height, equals(20));
      expect(gradient.pixels.length, equals(20 * 20 * 4));
    });
  });
}
