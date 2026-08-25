import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/models/pipeline_error_code.dart';
import 'package:verimask/models/photo_result.dart';
import 'package:verimask/modules/capture_pipeline.dart';
import 'package:verimask/modules/certification_engine.dart';
import 'package:verimask/modules/image_processor.dart';
import 'package:verimask/modules/ttl_manager.dart';
import 'package:verimask/models/pipeline_stage.dart';
import 'package:verimask/pipeline/end_to_end_pipeline.dart';
import 'package:verimask/services/share_service.dart';

class _FakeCapturePipeline extends CaptureAndProcessPipeline {
  final PhotoResult resultToReturn;

  _FakeCapturePipeline({required this.resultToReturn})
      : super(
          frameCapture: _DummyFrameCapture(),
          landmarkDetector: _DummyLandmarkDetector(),
          segmentationProvider: _DummySegmentationProvider(),
        );

  @override
  Future<PhotoResult> captureAndProcess({
    void Function(PipelineStage)? onProgress,
    String? preCapturedJpegPath,
  }) async => resultToReturn;
}

class _FakeCertificationEngine implements CertificationEngine {
  bool certifyCalled = false;
  bool shouldThrow = false;

  @override
  Future<CertifiedPhoto> certify(
      Uint8List anonymizedImage,
      {Map<String, int>? faceRect}) async {
    certifyCalled = true;
    if (shouldThrow) throw Exception('Certification error');
    return CertifiedPhoto(
      imageData: anonymizedImage,
      sha256Hash: 'abc123',
      verificationCode: 'VERI1234',
      timestamp: DateTime(2025, 1, 15, 10, 30),
      digitalSignature: 'sig-base64',
    );
  }

  @override
  String generateVerificationCode(Uint8List imageData) => 'CODE1234';
  @override
  Future<void> initializeKeyPair() async {}
}

class _FakeTTLManager implements TTLManager {
  int registerCallCount = 0;
  String? lastRegisteredId;

  @override
  Future<void> registerPhoto(String photoId, DateTime createdAt) async {
    registerCallCount++;
    lastRegisteredId = photoId;
  }

  @override
  Future<int> purgeExpiredPhotos() async => 0;
  @override
  Duration getRemainingTTL(String photoId) => Duration.zero;
  @override
  bool isExpired(String photoId) => false;
}

class _FakeShareService implements ShareService {
  int shareCallCount = 0;
  String? lastMessenger;

  @override
  Future<void> shareToMessenger(Uint8List image, String messenger) async {
    shareCallCount++;
    lastMessenger = messenger;
  }
}

class _DummyFrameCapture implements FrameCapture {
  @override
  Future<CapturedFrame> captureFrame() async =>
      CapturedFrame(
          jpegPath: '/tmp/dummy.jpg',
          imageData: ImageData(
              width: 1, height: 1, pixels: Uint8List.fromList([0, 0, 0, 255])));
}

class _DummyLandmarkDetector implements LandmarkDetector {
  @override
  Future<List<LandmarkRect>> detectLandmarks(String jpegPath) async => [];
}

class _DummySegmentationProvider implements SegmentationProvider {
  @override
  Future<List<bool>> segment(String jpegPath, int width, int height) async => [true];
  @override
  Future<List<double>> segmentRaw(String jpegPath, int width, int height) async => [1.0];
}

void main() {
  group('EndToEndPipeline', () {
    late _FakeCertificationEngine certEngine;
    late _FakeTTLManager ttlManager;
    late _FakeShareService shareService;

    setUp(() {
      certEngine = _FakeCertificationEngine();
      ttlManager = _FakeTTLManager();
      shareService = _FakeShareService();
    });

    test('successful pipeline: capture → certify → register TTL', () async {
      final imageBytes = Uint8List.fromList([10, 20, 30]);
      final capturePipeline = _FakeCapturePipeline(
        resultToReturn: PhotoResult(
          success: true,
          anonymizedImage: imageBytes,
        ),
      );

      final pipeline = EndToEndPipeline(
        capturePipeline: capturePipeline,
        certificationEngine: certEngine,
        ttlManager: ttlManager,
        shareService: shareService,
      );

      final result = await pipeline.execute();

      expect(result.success, isTrue);
      expect(result.certifiedPhoto, isNotNull);
      expect(result.certifiedPhoto!.sha256Hash, 'abc123');
      expect(result.certifiedPhoto!.verificationCode, 'VERI1234');
      expect(certEngine.certifyCalled, isTrue);
      expect(ttlManager.registerCallCount, 1);
      expect(ttlManager.lastRegisteredId, 'VERI1234');
    });

    test('returns error when capture fails', () async {
      final capturePipeline = _FakeCapturePipeline(
        resultToReturn: const PhotoResult(
          success: false,
          errorCode: PipelineErrorCode.captureError,
        ),
      );

      final pipeline = EndToEndPipeline(
        capturePipeline: capturePipeline,
        certificationEngine: certEngine,
        ttlManager: ttlManager,
        shareService: shareService,
      );

      final result = await pipeline.execute();

      expect(result.success, isFalse);
      expect(result.errorCode, PipelineErrorCode.captureError);
      expect(certEngine.certifyCalled, isFalse);
      expect(ttlManager.registerCallCount, 0);
    });

    test('share delegates to ShareService', () async {
      final capturePipeline = _FakeCapturePipeline(
        resultToReturn: PhotoResult(
          success: true,
          anonymizedImage: Uint8List.fromList([1]),
        ),
      );

      final pipeline = EndToEndPipeline(
        capturePipeline: capturePipeline,
        certificationEngine: certEngine,
        ttlManager: ttlManager,
        shareService: shareService,
      );

      await pipeline.share(Uint8List.fromList([1, 2, 3]), 'whatsapp');

      expect(shareService.shareCallCount, 1);
      expect(shareService.lastMessenger, 'whatsapp');
    });
  });
}
