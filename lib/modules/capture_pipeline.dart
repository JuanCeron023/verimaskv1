import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

import '../models/photo_result.dart';
import '../models/anonymization_config.dart';
import '../models/anonymization_result.dart';
import '../models/pipeline_error_code.dart';
import '../models/pipeline_stage.dart';
import '../modules/image_processor.dart';
import '../modules/visual_anonymization_pipeline.dart';
import '../services/segmentation_provider_impl.dart';

abstract class FrameCapture {
  Future<CapturedFrame> captureFrame();
}

ImageData _decodeJpegBytes(Uint8List jpegBytes) {
  var decoded = img.decodeImage(jpegBytes);
  if (decoded == null) throw Exception('Failed to decode JPEG');
  decoded = img.bakeOrientation(decoded);
  final w = decoded.width;
  final h = decoded.height;
  final pixels = Uint8List(w * h * 4);
  var i = 0;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = decoded.getPixel(x, y);
      pixels[i] = p.b.toInt();
      pixels[i + 1] = p.g.toInt();
      pixels[i + 2] = p.r.toInt();
      pixels[i + 3] = p.a.toInt();
      i += 4;
    }
  }
  return ImageData(width: w, height: h, pixels: pixels);
}

class _AnonymizeParams {
  final ImageData source;
  final List<bool> mask;
  final LandmarkRect faceBbox;
  final List<LandmarkRect> landmarks;

  _AnonymizeParams({
    required this.source,
    required this.mask,
    required this.faceBbox,
    this.landmarks = const [],
  });
}

Future<AnonymizationResult> _anonymizeInIsolate(_AnonymizeParams params) {
  final pipeline = VisualAnonymizationPipeline();
  return pipeline.anonymize(
    params.source,
    params.mask,
    params.faceBbox,
    landmarks: params.landmarks,
  );
}

class CapturedFrame {
  final String jpegPath;
  final ImageData imageData;

  CapturedFrame({required this.jpegPath, required this.imageData});

  Future<void> cleanup() async {
    try {
      final file = File(jpegPath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}

abstract class LandmarkDetector {
  Future<List<LandmarkRect>> detectLandmarks(String jpegPath);
}

/// Orchestrates frame capture → face detection → anonymization → PNG encoding.
class CaptureAndProcessPipeline {
  final FrameCapture _frameCapture;
  final LandmarkDetector _landmarkDetector;
  final SegmentationProvider _segmentationProvider;

  CaptureAndProcessPipeline({
    required FrameCapture frameCapture,
    required LandmarkDetector landmarkDetector,
    required SegmentationProvider segmentationProvider,
  })  : _frameCapture = frameCapture,
        _landmarkDetector = landmarkDetector,
        _segmentationProvider = segmentationProvider;

  Future<PhotoResult> captureAndProcess({
    void Function(PipelineStage)? onProgress,
    String? preCapturedJpegPath,
  }) async {
    onProgress?.call(PipelineStage.processingPhoto);

    CapturedFrame? capture;
    try {
      if (preCapturedJpegPath != null) {
        final jpegBytes = await File(preCapturedJpegPath).readAsBytes();
        final imageData = await compute(_decodeJpegBytes, jpegBytes);
        capture = CapturedFrame(jpegPath: preCapturedJpegPath, imageData: imageData);
      } else {
        capture = await _frameCapture.captureFrame();
      }
    } catch (e) {
      return const PhotoResult(
        success: false,
        errorCode: PipelineErrorCode.captureError,
      );
    }

    final frame = capture.imageData;
    ImageData anonymized;
    LandmarkRect? faceBbox;

    try {
      final landmarks = await _landmarkDetector.detectLandmarks(capture.jpegPath);
      final rawConfidence = await _segmentationProvider.segmentRaw(
        capture.jpegPath,
        frame.width,
        frame.height,
      );
      final mask = List<bool>.filled(frame.width * frame.height, false);
      for (var i = 0; i < rawConfidence.length; i++) {
        mask[i] = rawConfidence[i] >= 0.35;
      }

      if (landmarks.isNotEmpty) {
        faceBbox = landmarks.first;
      } else {
        faceBbox = LandmarkRect(
          x: (frame.width * 0.25).toInt(),
          y: (frame.height * 0.20).toInt(),
          width: (frame.width * 0.50).toInt(),
          height: (frame.height * 0.45).toInt(),
        );
      }

      final result = await compute(
        _anonymizeInIsolate,
        _AnonymizeParams(
          source: frame,
          mask: mask,
          faceBbox: faceBbox,
          landmarks: landmarks,
        ),
      );

      anonymized = result.anonymizedImage;
    } catch (e) {
      await capture.cleanup();
      return const PhotoResult(
        success: false,
        errorCode: PipelineErrorCode.processingError,
      );
    }

    await capture.cleanup();

    final pngImage = img.Image(
      width: anonymized.width,
      height: anonymized.height,
      numChannels: 4,
    );
    for (var y = 0; y < anonymized.height; y++) {
      for (var x = 0; x < anonymized.width; x++) {
        final i = (y * anonymized.width + x) * 4;
        pngImage.setPixelRgba(
          x,
          y,
          anonymized.pixels[i + 2],
          anonymized.pixels[i + 1],
          anonymized.pixels[i],
          anonymized.pixels[i + 3],
        );
      }
    }
    final pngBytes = Uint8List.fromList(img.encodePng(pngImage));

    return PhotoResult(
      success: true,
      anonymizedImage: pngBytes,
      faceRect: {
        'x': faceBbox.x,
        'y': faceBbox.y,
        'width': faceBbox.width,
        'height': faceBbox.height,
      },
    );
  }
}
