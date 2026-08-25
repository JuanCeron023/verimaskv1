import 'dart:typed_data';

import '../models/pipeline_error_code.dart';
import '../models/pipeline_stage.dart';
import '../modules/capture_pipeline.dart';
import '../modules/certification_engine.dart';
import '../modules/ttl_manager.dart';
import '../services/share_service.dart';

/// Result of the full end-to-end pipeline execution.
class PipelineResult {
  final bool success;
  final CertifiedPhoto? certifiedPhoto;
  final PipelineErrorCode? errorCode;

  const PipelineResult({
    required this.success,
    this.certifiedPhoto,
    this.errorCode,
  });
}

/// Wires the complete end-to-end pipeline:
///
/// CameraScreen → CaptureAndProcessPipeline (LandmarkDetector
/// → anonymization) → CertificationEngine → ResultScreen → ShareService
///
/// Key guarantees:
/// - Original image never written to disk (only in-memory during processing).
/// - All ML processing occurs on-device without internet.
/// - Photo is registered with TTLManager for auto-expiration.
class EndToEndPipeline {
  final CaptureAndProcessPipeline _capturePipeline;
  final CertificationEngine _certificationEngine;
  final TTLManager _ttlManager;
  final ShareService _shareService;

  EndToEndPipeline({
    required CaptureAndProcessPipeline capturePipeline,
    required CertificationEngine certificationEngine,
    required TTLManager ttlManager,
    required ShareService shareService,
  })  : _capturePipeline = capturePipeline,
        _certificationEngine = certificationEngine,
        _ttlManager = ttlManager,
        _shareService = shareService;

  /// Executes the full pipeline from capture to certified photo.
  ///
  /// If [preCapturedJpegPath] is provided, it will be used as frame 1
  /// instead of capturing a new photo. This ensures the processed image
  /// matches exactly what the user saw when they pressed the button.
  Future<PipelineResult> execute({
    void Function(PipelineStage)? onProgress,
    String? preCapturedJpegPath,
  }) async {
    // Step 1: Capture and anonymize.
    print('[E2E] ========================================');
    print('[E2E] Starting full end-to-end pipeline...');
    if (preCapturedJpegPath != null) {
      print('[E2E] Using pre-captured frame: $preCapturedJpegPath');
    }
    print('[E2E] ========================================');
    final captureResult = await _capturePipeline.captureAndProcess(
      onProgress: onProgress,
      preCapturedJpegPath: preCapturedJpegPath,
    );

    print('[E2E] Capture result: success=${captureResult.success}, errorCode=${captureResult.errorCode}, hasImage=${captureResult.anonymizedImage != null}, imageSize=${captureResult.anonymizedImage?.length ?? 0}');

    if (!captureResult.success || captureResult.anonymizedImage == null) {
      print('[E2E] Capture failed, returning error');
      return PipelineResult(
        success: false,
        errorCode: captureResult.errorCode,
      );
    }

    // Step 2: Certify the anonymized image.
    onProgress?.call(PipelineStage.certifying);
    final CertifiedPhoto certified;
    try {
      print('[E2E] Starting certification with ${captureResult.anonymizedImage!.length} bytes...');
      certified = await _certificationEngine.certify(
        captureResult.anonymizedImage!,
        faceRect: captureResult.faceRect,
      );
      print('[E2E] Certification success: hash=${certified.sha256Hash.substring(0, 8)}, code=${certified.verificationCode}');
    } catch (e) {
      print('[E2E] Certification FAILED: $e');
      return const PipelineResult(
        success: false,
        errorCode: PipelineErrorCode.certificationError,
      );
    }

    // Step 3: Register photo with TTLManager for auto-expiration.
    try {
      final photoId = certified.verificationCode;
      await _ttlManager.registerPhoto(photoId, certified.timestamp);
    } catch (_) {
      // Non-critical — don't fail the pipeline for TTL registration errors.
    }

    return PipelineResult(
      success: true,
      certifiedPhoto: certified,
    );
  }

  /// Shares a certified photo via the specified messenger.
  Future<void> share(Uint8List imageData, String messenger) async {
    await _shareService.shareToMessenger(imageData, messenger);
  }
}
