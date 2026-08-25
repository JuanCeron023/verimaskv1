import 'dart:io';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import '../modules/capture_pipeline.dart';
import '../modules/image_processor.dart';

/// Implementation of [LandmarkDetector] using Google ML Kit Face Detection.
///
/// Accepts a JPEG file path (with EXIF intact) for reliable face detection.
/// Detects facial landmarks and returns LandmarkRect for anonymization.
///
/// Landmarks are transformed from ML Kit's EXIF-rotated coordinate space
/// to the ImageData (post-bakeOrientation) coordinate space. This is critical
/// when EXIF rotation is 90° or 270°, which transposes width↔height.
class LandmarkDetectorImpl implements LandmarkDetector {
  late final FaceDetector _detector;

  static const double eyeMarginFactor = 1.5;
  static const double noseMarginFactor = 2.0;
  static const double mouthMarginFactor = 1.8;
  static const int baseLandmarkSize = 30;

  LandmarkDetectorImpl() {
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableLandmarks: true,
        enableContours: true,
        enableClassification: false,
        enableTracking: false,
      ),
    );
  }

  @override
  Future<List<LandmarkRect>> detectLandmarks(String jpegPath) async {
    try {
      final inputImage = InputImage.fromFile(File(jpegPath));
      final faces = await _detector.processImage(inputImage);

      if (faces.isEmpty) return [];

      // Determine if coordinate transformation is needed.
      // ML Kit applies EXIF rotation internally, so landmarks are in the
      // EXIF-rotated coordinate space. ImageData uses bakeOrientation(),
      // which produces the same final pixel layout. When EXIF rotation is
      // 90° or 270°, the raw JPEG dimensions differ from the baked
      // dimensions (width↔height are swapped). We detect this to transform
      // landmark coordinates from EXIF-rotated space to ImageData space.
      final jpegBytes = await File(jpegPath).readAsBytes();
      final rawImage = img.decodeImage(jpegBytes);
      if (rawImage == null) {
        throw LandmarkDetectionException(
          'decode_failed',
          'Failed to decode JPEG for EXIF analysis',
        );
      }

      final rawWidth = rawImage.width;
      final rawHeight = rawImage.height;
      final bakedImage = img.bakeOrientation(rawImage);
      final bakedWidth = bakedImage.width;
      final bakedHeight = bakedImage.height;

      // If dimensions changed, EXIF rotation is 90° or 270° (transposing).
      final needsTranspose = (rawWidth != bakedWidth || rawHeight != bakedHeight);

      print('[LandmarkDetector] Raw JPEG: ${rawWidth}x$rawHeight, '
          'Baked: ${bakedWidth}x$bakedHeight, needsTranspose=$needsTranspose');

      final face = faces.first;
      final landmarks = <LandmarkRect>[];

      // Use face bounding box to create bars proportional to face size.
      final faceRect = face.boundingBox;
      final faceWidth = faceRect.width.toInt();
      final faceHeight = faceRect.height.toInt();

      // Include the full face bounding box as the first landmark.
      // This ensures _extractFaceBbox in the pipeline covers the entire face
      // (forehead to chin), not just the eye-to-mouth region from individual landmarks.
      int fbX = faceRect.left.toInt();
      int fbY = faceRect.top.toInt();
      if (needsTranspose) {
        final tx = fbY;
        final ty = fbX;
        fbX = tx;
        fbY = ty;
      }
      landmarks.add(LandmarkRect(
        x: fbX,
        y: fbY,
        width: needsTranspose ? faceHeight : faceWidth,
        height: needsTranspose ? faceWidth : faceHeight,
      ));

      // Bar width = face width (spans the whole face horizontally)
      final barWidth = faceWidth;

      // Bar heights as percentage of face height — scales with distance
      final eyeBarHeight = (faceHeight * 0.08).round().clamp(8, 200);   // 8% of face
      final noseBarHeight = (faceHeight * 0.10).round().clamp(10, 250);  // 10% of face
      final mouthBarHeight = (faceHeight * 0.12).round().clamp(12, 300); // 12% of face (wider than eyes/nose)

      final leftEye = face.landmarks[FaceLandmarkType.leftEye];
      if (leftEye != null) {
        landmarks.add(_createBarRect(
          leftEye,
          barWidth: barWidth,
          barHeight: eyeBarHeight,
          faceLeft: faceRect.left.toInt(),
          needsTranspose: needsTranspose,
        ));
      }

      final rightEye = face.landmarks[FaceLandmarkType.rightEye];
      if (rightEye != null) {
        landmarks.add(_createBarRect(
          rightEye,
          barWidth: barWidth,
          barHeight: eyeBarHeight,
          faceLeft: faceRect.left.toInt(),
          needsTranspose: needsTranspose,
        ));
      }

      final noseBase = face.landmarks[FaceLandmarkType.noseBase];
      if (noseBase != null) {
        landmarks.add(_createBarRect(
          noseBase,
          barWidth: barWidth,
          barHeight: noseBarHeight,
          faceLeft: faceRect.left.toInt(),
          needsTranspose: needsTranspose,
        ));
      }

      final bottomMouth = face.landmarks[FaceLandmarkType.bottomMouth];
      if (bottomMouth != null) {
        landmarks.add(_createBarRect(
          bottomMouth,
          barWidth: barWidth,
          barHeight: mouthBarHeight,
          faceLeft: faceRect.left.toInt(),
          needsTranspose: needsTranspose,
        ));
      }

      return landmarks;
    } catch (e) {
      if (e is LandmarkDetectionException) rethrow;
      throw LandmarkDetectionException('Landmark detection failed', 'Failed to detect landmarks: $e');
    }
  }

  /// Creates a horizontal bar [LandmarkRect] spanning the face width.
  ///
  /// The bar is centered vertically on the landmark point and uses
  /// [faceLeft] as the x origin so all bars align to the face bounding box.
  LandmarkRect _createBarRect(
    FaceLandmark landmark, {
    required int barWidth,
    required int barHeight,
    required int faceLeft,
    bool needsTranspose = false,
  }) {
    final position = landmark.position;

    int lx = position.x;
    int ly = position.y;

    if (needsTranspose) {
      final tx = ly;
      final ty = lx;
      lx = tx;
      ly = ty;
      print('[LandmarkDetector] Transposed landmark: '
          '(${position.x},${position.y}) -> ($lx,$ly)');
    }

    // Bar starts at face left edge, centered vertically on the landmark
    return LandmarkRect(
      x: needsTranspose ? (ly - barWidth ~/ 2) : faceLeft,
      y: (ly - barHeight ~/ 2),
      width: barWidth,
      height: barHeight,
    );
  }

  void dispose() {
    _detector.close();
  }
}

class LandmarkDetectionException implements Exception {
  final String type;
  final String message;
  LandmarkDetectionException(this.type, this.message);
  @override
  String toString() => 'LandmarkDetectionException($type): $message';
}
