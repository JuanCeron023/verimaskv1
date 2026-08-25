import 'dart:math' as math;
import 'dart:typed_data';

/// Simple image representation using a flat BGRA pixel buffer.
///
/// Each pixel occupies 4 bytes: B, G, R, A.
class ImageData {
  final int width;
  final int height;
  final Uint8List pixels;

  ImageData({
    required this.width,
    required this.height,
    required this.pixels,
  }) {
    if (pixels.length != width * height * 4) {
      throw ArgumentError(
        'Pixel buffer length (${pixels.length}) must equal width × height × 4 (${width * height * 4})',
      );
    }
  }

  ImageData clone() => ImageData(
        width: width,
        height: height,
        pixels: Uint8List.fromList(pixels),
      );
}

/// Rectangular region representing a facial landmark area or face bounding box.
class LandmarkRect {
  final int x;
  final int y;
  final int width;
  final int height;

  const LandmarkRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });
}

/// Expands a face bounding box with configurable margins.
LandmarkRect expandFaceBbox(
  LandmarkRect original,
  int imgW,
  int imgH, {
  double downFactor = 0.20,
  double sideFactor = 0.15,
  double upFactor = 0.15,
}) {
  final expandDown = (original.height * downFactor).round();
  final expandSide = (original.width * sideFactor).round();
  final expandUp = (original.height * upFactor).round();

  final newX = (original.x - expandSide).clamp(0, imgW);
  final newY = (original.y - expandUp).clamp(0, imgH);
  final newRight = (original.x + original.width + expandSide).clamp(0, imgW);
  final newBottom = (original.y + original.height + expandDown).clamp(0, imgH);

  return LandmarkRect(
    x: newX,
    y: newY,
    width: newRight - newX,
    height: newBottom - newY,
  );
}

/// Applies a Gaussian blur (via fast box blur approximation) to the specified [rect] region in the image.
ImageData applyFaceBlur(
  ImageData source,
  LandmarkRect rect, {
  int radius = 25,
  int passes = 3,
  double featherRatio = 0.1,
}) {
  final result = source.clone();
  final w = result.width;
  final h = result.height;
  final px = result.pixels;
  final orig = source.pixels;

  final x0 = rect.x.clamp(0, w);
  final y0 = rect.y.clamp(0, h);
  final x1 = (rect.x + rect.width).clamp(0, w);
  final y1 = (rect.y + rect.height).clamp(0, h);
  final rw = x1 - x0;
  final rh = y1 - y0;

  if (rw <= 0 || rh <= 0) return result;

  // Perform a horizontal and vertical blur over the cropped face bounding box
  final subPixels = Uint8List(rw * rh * 4);
  for (var y = 0; y < rh; y++) {
    final srcOffset = ((y0 + y) * w + x0) * 4;
    final dstOffset = y * rw * 4;
    subPixels.setRange(dstOffset, dstOffset + rw * 4, orig, srcOffset);
  }

  var currentSub = subPixels;
  var bufferSub = Uint8List(subPixels.length);

  for (var pass = 0; pass < passes; pass++) {
    // Horizontal pass
    for (var y = 0; y < rh; y++) {
      for (var x = 0; x < rw; x++) {
        int sumB = 0, sumG = 0, sumR = 0;
        int count = 0;
        final kx0 = (x - radius).clamp(0, rw - 1);
        final kx1 = (x + radius).clamp(0, rw - 1);
        for (var kx = kx0; kx <= kx1; kx++) {
          final off = (y * rw + kx) * 4;
          sumB += currentSub[off];
          sumG += currentSub[off + 1];
          sumR += currentSub[off + 2];
          count++;
        }
        final off = (y * rw + x) * 4;
        bufferSub[off] = sumB ~/ count;
        bufferSub[off + 1] = sumG ~/ count;
        bufferSub[off + 2] = sumR ~/ count;
        bufferSub[off + 3] = currentSub[off + 3];
      }
    }

    final tmp = currentSub;
    currentSub = bufferSub;
    bufferSub = tmp;

    // Vertical pass
    for (var y = 0; y < rh; y++) {
      for (var x = 0; x < rw; x++) {
        int sumB = 0, sumG = 0, sumR = 0;
        int count = 0;
        final ky0 = (y - radius).clamp(0, rh - 1);
        final ky1 = (y + radius).clamp(0, rh - 1);
        for (var ky = ky0; ky <= ky1; ky++) {
          final off = (ky * rw + x) * 4;
          sumB += currentSub[off];
          sumG += currentSub[off + 1];
          sumR += currentSub[off + 2];
          count++;
        }
        final off = (y * rw + x) * 4;
        bufferSub[off] = sumB ~/ count;
        bufferSub[off + 1] = sumG ~/ count;
        bufferSub[off + 2] = sumR ~/ count;
        bufferSub[off + 3] = currentSub[off + 3];
      }
    }

    final tmp2 = currentSub;
    currentSub = bufferSub;
    bufferSub = tmp2;
  }

  // Composite blurred face back into the main image with feathering
  final featherW = math.max(1, (rw * featherRatio).round());
  final featherH = math.max(1, (rh * featherRatio).round());

  for (var y = 0; y < rh; y++) {
    for (var x = 0; x < rw; x++) {
      final srcX = x0 + x;
      final srcY = y0 + y;
      final mainOffset = (srcY * w + srcX) * 4;
      final subOffset = (y * rw + x) * 4;

      final distLeft = x;
      final distRight = rw - 1 - x;
      final distTop = y;
      final distBottom = rh - 1 - y;

      final alphaX = featherW > 0 ? (math.min(distLeft, distRight) / featherW).clamp(0.0, 1.0) : 1.0;
      final alphaY = featherH > 0 ? (math.min(distTop, distBottom) / featherH).clamp(0.0, 1.0) : 1.0;
      final edgeAlpha = alphaX * alphaY;

      for (var c = 0; c < 3; c++) {
        final blurVal = currentSub[subOffset + c];
        final origVal = orig[mainOffset + c];
        px[mainOffset + c] = (origVal * (1.0 - edgeAlpha) + blurVal * edgeAlpha).round().clamp(0, 255);
      }
      px[mainOffset + 3] = orig[mainOffset + 3];
    }
  }

  return result;
}

/// Simple radial gradient background generator in pure Dart.
ImageData generateRadialGradient(
  int width,
  int height, {
  List<int> innerColor = const [220, 220, 220, 255],
  List<int> outerColor = const [60, 60, 60, 255],
}) {
  final pixels = Uint8List(width * height * 4);
  final centerX = width / 2.0;
  final centerY = height / 2.0;
  final maxDist = math.sqrt(centerX * centerX + centerY * centerY);

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final dx = x - centerX;
      final dy = y - centerY;
      final dist = math.sqrt(dx * dx + dy * dy);
      final t = maxDist > 0 ? (dist / maxDist).clamp(0.0, 1.0) : 0.0;

      final offset = (y * width + x) * 4;
      for (var c = 0; c < 4; c++) {
        pixels[offset + c] = (innerColor[c] + (outerColor[c] - innerColor[c]) * t).round().clamp(0, 255);
      }
    }
  }

  return ImageData(width: width, height: height, pixels: pixels);
}

/// Composites the source image (where foregroundMask is true) with a background image.
ImageData compositeWithBackground(
  ImageData foreground,
  ImageData background,
  List<bool> foregroundMask, {
  int featherPixels = 5,
}) {
  final result = background.clone();
  final w = foreground.width;
  final h = foreground.height;
  final resPx = result.pixels;
  final fgPx = foreground.pixels;

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final idx = y * w + x;
      if (foregroundMask[idx]) {
        final offset = idx * 4;
        resPx[offset] = fgPx[offset];
        resPx[offset + 1] = fgPx[offset + 1];
        resPx[offset + 2] = fgPx[offset + 2];
        resPx[offset + 3] = fgPx[offset + 3];
      }
    }
  }

  return result;
}
