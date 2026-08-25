abstract class SegmentationProvider {
  Future<List<bool>> segment(String jpegPath, int width, int height);
  Future<List<double>> segmentRaw(String jpegPath, int width, int height);
}

/// Mock implementation of [SegmentationProvider] for the boilerplate template.
///
/// Returns a mock mask (foreground central circle) to avoid native ML model dependency.
class SegmentationProviderImpl implements SegmentationProvider {
  SegmentationProviderImpl();

  @override
  Future<List<bool>> segment(String jpegPath, int width, int height) async {
    final pixelCount = width * height;
    final mask = List<bool>.filled(pixelCount, false);

    // Create a mock central segment representing a person
    final centerX = width / 2.0;
    final centerY = height * 0.55; // Slightly lower center
    final radiusX = width * 0.35;
    final radiusY = height * 0.40;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final dx = (x - centerX) / radiusX;
        final dy = (y - centerY) / radiusY;
        if (dx * dx + dy * dy <= 1.0) {
          mask[y * width + x] = true;
        }
      }
    }
    return mask;
  }

  @override
  Future<List<double>> segmentRaw(String jpegPath, int width, int height) async {
    final boolMask = await segment(jpegPath, width, height);
    return boolMask.map((val) => val ? 1.0 : 0.0).toList();
  }

  void dispose() {}
}

class SegmentationException implements Exception {
  final String type;
  final String message;
  SegmentationException(this.type, this.message);
  @override
  String toString() => 'SegmentationException($type): $message';
}
