import 'dart:math' as math;
import '../models/anonymization_config.dart';
import '../models/anonymization_result.dart';
import 'image_processor.dart';

/// Simplified visual anonymization pipeline for the boilerplate template.
///
/// Steps:
/// 1. Expands face bounding box.
/// 2. Applies a soft box blur with feathering over the face region using pure Dart.
/// 3. Generates a radial gradient background and composites it behind the person.
class VisualAnonymizationPipeline {
  Future<AnonymizationResult> anonymize(
    ImageData source,
    List<bool> mask,
    LandmarkRect faceBbox, {
    List<LandmarkRect> landmarks = const [],
    AnonymizationConfig config = const AnonymizationConfig(),
    List<LandmarkRect> handRegions = const [],
  }) async {
    final stopwatch = Stopwatch()..start();
    final warnings = <String>[];

    _validateInputs(source, mask, faceBbox);

    final w = source.width;
    final h = source.height;
    var current = source.clone();

    // 1. Expand Face Bounding Box
    late LandmarkRect expandedFace;
    try {
      expandedFace = expandFaceBbox(
        faceBbox, w, h,
        downFactor: config.faceExpandDown,
        sideFactor: config.faceExpandSide,
        upFactor: config.faceExpandUp,
      );
    } catch (e) {
      expandedFace = faceBbox;
      warnings.add('expandFaceBboxFailed');
    }

    // 2. Apply Pure-Dart Face Blur
    try {
      final faceSize = math.min(expandedFace.width, expandedFace.height);
      final blurRadius = ((faceSize * 0.12).round()).clamp(5, 100);

      current = applyFaceBlur(
        current,
        expandedFace,
        radius: blurRadius,
        passes: 3,
        featherRatio: config.faceFeatherRatio,
      );
    } catch (e) {
      warnings.add('faceBlurFailed');
    }

    // 3. Background gradient + composition
    try {
      final gradient = generateRadialGradient(
        w,
        h,
        innerColor: config.gradientInnerColor,
        outerColor: config.gradientOuterColor,
      );
      current = compositeWithBackground(
        current,
        gradient,
        mask,
        featherPixels: config.backgroundFeatherPixels,
      );
    } catch (e) {
      warnings.add('backgroundCompositionFailed');
    }

    stopwatch.stop();
    return AnonymizationResult(
      anonymizedImage: current,
      warnings: warnings,
      processingTime: stopwatch.elapsed,
    );
  }

  void _validateInputs(ImageData source, List<bool> mask, LandmarkRect faceBbox) {
    if (source.width <= 0 || source.height <= 0) {
      throw ArgumentError('Image dimensions must be positive: ${source.width}×${source.height}');
    }
    if (mask.length != source.width * source.height) {
      throw ArgumentError('Mask length (${mask.length}) must equal width × height (${source.width * source.height})');
    }
    if (faceBbox.width <= 0 || faceBbox.height <= 0) {
      throw ArgumentError('Face bbox must have positive dimensions: ${faceBbox.width}×${faceBbox.height}');
    }
  }
}
