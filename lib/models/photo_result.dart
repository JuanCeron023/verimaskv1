import 'dart:typed_data';

import 'package:verimask/models/pipeline_error_code.dart';

/// Result of the complete capture-and-process pipeline.
///
/// Contains the anonymized image on success, or an error code on failure.
class PhotoResult {
  /// Whether the pipeline completed successfully.
  final bool success;

  /// The anonymized image (visual pipeline + background replaced).
  /// Null on failure.
  final Uint8List? anonymizedImage;

  /// Error code on failure. Null on success.
  /// Screens map this to localized user-facing strings via l10n.
  final PipelineErrorCode? errorCode;

  /// Face bounding box for viewfinder corner positioning.
  /// Map with keys {x, y, width, height}. Null if face detection failed.
  final Map<String, int>? faceRect;

  const PhotoResult({
    required this.success,
    this.anonymizedImage,
    this.errorCode,
    this.faceRect,
  });
}
