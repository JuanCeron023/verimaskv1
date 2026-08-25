import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../modules/capture_pipeline.dart';
import '../modules/image_processor.dart';
import 'permission_manager.dart';

/// Decodes JPEG bytes to ImageData in an isolate-safe top-level function.
/// Applies EXIF orientation and converts to BGRA format.
ImageData _decodeJpegToImageData(Uint8List jpegBytes) {
  img.Image? decodedImage = img.decodeImage(jpegBytes);
  if (decodedImage == null) {
    throw Exception('Failed to decode captured image');
  }

  decodedImage = img.bakeOrientation(decodedImage);

  final int width = decodedImage.width;
  final int height = decodedImage.height;

  final Uint8List pixels = Uint8List(width * height * 4);
  int pixelIndex = 0;
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final pixel = decodedImage.getPixel(x, y);
      pixels[pixelIndex] = pixel.b.toInt();
      pixels[pixelIndex + 1] = pixel.g.toInt();
      pixels[pixelIndex + 2] = pixel.r.toInt();
      pixels[pixelIndex + 3] = pixel.a.toInt();
      pixelIndex += 4;
    }
  }

  return ImageData(width: width, height: height, pixels: pixels);
}

/// Implementation of [FrameCapture] using Flutter camera plugin.
///
/// Captures frames from the device's front camera with minimum resolution
/// of 640x480 pixels (ResolutionPreset.medium).
class FrameCaptureImpl implements FrameCapture {
  final PermissionManager _permissionManager;
  CameraController? _controller;
  bool _isInitialized = false;

  FrameCaptureImpl({
    required PermissionManager permissionManager,
  }) : _permissionManager = permissionManager;

  /// Initializes the front camera with ResolutionPreset.medium (640x480+).
  ///
  /// Steps:
  /// 1. Verify camera permissions
  /// 2. Get list of available cameras
  /// 3. Select front camera (lensDirection == front)
  /// 4. Create CameraController with ResolutionPreset.medium
  /// 5. Initialize controller
  ///
  /// Throws [CameraException] if camera is not available or initialization fails.
  /// Throws [PermissionDeniedException] if camera permissions are denied.
  Future<void> initialize() async {
    final hasPermission = await _permissionManager.ensureCameraPermission();
    if (!hasPermission) {
      throw PermissionDeniedException('Camera permission denied');
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException('No cameras available', 'No cameras found');
    }

    CameraDescription? frontCamera;
    for (final camera in cameras) {
      if (camera.lensDirection == CameraLensDirection.front) {
        frontCamera = camera;
        break;
      }
    }
    frontCamera ??= cameras.first;

    // Retry loop: wait for camera hardware to be truly available.
    // This handles the case where a previous CameraController was just disposed
    // and the hardware hasn't fully released yet.
    const maxAttempts = 5;
    print('[FrameCapture] initialize() starting, up to $maxAttempts attempts...');
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        print('[FrameCapture] Init attempt ${attempt + 1}/$maxAttempts — creating controller...');
        _controller = CameraController(
          frontCamera,
          ResolutionPreset.high,
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );

        await _controller!.initialize().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            throw CameraException('Timeout', 'Camera init timed out');
          },
        );

        _isInitialized = true;
        print('[FrameCapture] Init SUCCESS on attempt ${attempt + 1}');

        // Set continuous autofocus to avoid the slow lock/wait/capture cycle.
        // Front camera at 720p doesn't need precise AF per shot.
        try {
          await _controller!.setFocusMode(FocusMode.auto);
          print('[FrameCapture] Focus mode set to continuous auto');
        } catch (e) {
          print('[FrameCapture] setFocusMode failed (non-critical): $e');
        }

        // Pre-warm the ImageReader by executing a discardable takePicture().
        // The first takePicture() after initialize() often fails because the
        // ImageReader hardware is not fully ready. By doing it here and
        // discarding the result, the real captureFrame() will succeed on
        // the first try.
        await _preWarmImageReader();
        return; // Success — exit retry loop.
      } catch (e) {
        print('[FrameCapture] Init FAILED attempt ${attempt + 1}: $e');
        // Dispose failed controller before retrying.
        try { await _controller?.dispose(); } catch (_) {}
        _controller = null;

        if (attempt < maxAttempts - 1) {
          // Wait progressively longer: 500ms, 1000ms, 1500ms, 2000ms
          final waitMs = 500 * (attempt + 1);
          print('[FrameCapture] Waiting ${waitMs}ms before retry...');
          await Future.delayed(Duration(milliseconds: waitMs));
        } else {
          // All attempts failed.
          print('[FrameCapture] All $maxAttempts init attempts FAILED');
          throw CameraException(
            'Initialization failed',
            'Camera not available after $maxAttempts attempts: $e',
          );
        }
      }
    }
  }

  /// Pre-warms the ImageReader by executing a discardable takePicture().
  ///
  /// The camera hardware's ImageReader is often not fully ready immediately
  /// after initialize(). This method forces its initialization by taking
  /// a throwaway picture. If it fails, it retries with progressive delays
  /// (200ms, 400ms, 600ms) instead of doing a full reinitialization.
  ///
  /// After a successful pre-warm (or after exhausting retries with an
  /// increased stabilization fallback), [_isImageReaderWarmed] is set to
  /// true so that [captureFrame] knows the reader is ready.
  Future<void> _preWarmImageReader() async {
    const maxPreWarmAttempts = 3;
    print('[FrameCapture] Pre-warming ImageReader...');

    for (var attempt = 0; attempt < maxPreWarmAttempts; attempt++) {
      try {
        // Short stabilization before each attempt.
        final stabilizationMs = 100 * (attempt + 1); // 100ms, 200ms, 300ms
        print('[FrameCapture] Pre-warm attempt ${attempt + 1}/$maxPreWarmAttempts — waiting ${stabilizationMs}ms...');
        await Future.delayed(Duration(milliseconds: stabilizationMs));

        final xFile = await _controller!.takePicture();
        // Discard the file — we only needed to wake up the ImageReader.
        try {
          final file = File(xFile.path);
          if (await file.exists()) await file.delete();
        } catch (_) {}

        _isImageReaderWarmed = true;
        print('[FrameCapture] Pre-warm SUCCESS on attempt ${attempt + 1}');

        // Brief cooldown so the ImageReader is fully settled for the next real capture.
        await Future.delayed(const Duration(milliseconds: 150));
        return;
      } catch (e) {
        print('[FrameCapture] Pre-warm FAILED attempt ${attempt + 1}: $e');
        // Don't reinitialize — just wait longer and retry on the same controller.
      }
    }

    // All pre-warm attempts failed. Fall back to a longer stabilization wait
    // so that captureFrame() has the best chance of succeeding.
    print('[FrameCapture] Pre-warm exhausted — falling back to extended stabilization (600ms)');
    await Future.delayed(const Duration(milliseconds: 600));
    _isImageReaderWarmed = true; // Mark as warmed; captureFrame will handle any remaining failure.
  }

  /// Captures a single frame as ImageData with RGBA buffer.
  ///
  /// Returns [ImageData] with width, height, and RGBA pixel buffer.
  ///
  /// When takePicture() fails (e.g. ImageReader null / channel-error),
  /// the controller's internal state is corrupted. We must fully dispose
  /// and reinitialize before retrying — retrying on the same controller
  /// will always fail again.
  ///
  /// Throws [CameraException] if camera is not initialized or capture fails.
  @override
  Future<CapturedFrame> captureFrame() async {
    // Auto-initialize on first use if not already initialized.
    if (!_isInitialized || _controller == null) {
      print('[FrameCapture] Not initialized, calling initialize()...');
      await initialize();
      // initialize() already calls _preWarmImageReader(), so no extra wait needed.
    }

    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        print('[FrameCapture] takePicture() attempt ${attempt + 1}/$maxAttempts...');
        final XFile imageFile = await _controller!.takePicture();
        final Uint8List imageBytes = await imageFile.readAsBytes();
        final String jpegPath = imageFile.path; // Keep the file for face_verification
        print('[FrameCapture] takePicture() OK — ${imageBytes.length} bytes at $jpegPath');

        // Wait between captures to let ImageReader recover for next call.
        await Future.delayed(const Duration(milliseconds: 150));

        final imageData = await compute(_decodeJpegToImageData, imageBytes);
        print('[FrameCapture] Decoded to ${imageData.width}x${imageData.height} BGRA');
        return CapturedFrame(jpegPath: jpegPath, imageData: imageData);
      } catch (e) {
        print('[FrameCapture] takePicture() FAILED attempt ${attempt + 1}: $e');

        if (attempt >= maxAttempts - 1) {
          // All attempts exhausted.
          throw CameraException(
            'Capture failed',
            'All $maxAttempts capture attempts failed. Last error: $e',
          );
        }

        // The ImageReader is corrupted — dispose and fully reinitialize.
        print('[FrameCapture] Disposing broken controller and reinitializing...');
        try { await _controller?.dispose(); } catch (_) {}
        _controller = null;
        _isInitialized = false;
        _isImageReaderWarmed = false;

        // Wait for hardware to release (progressive: 500ms, 750ms).
        final waitMs = 500 + (attempt * 250);
        print('[FrameCapture] Waiting ${waitMs}ms for hardware release...');
        await Future.delayed(Duration(milliseconds: waitMs));

        // Reinitialize from scratch.
        print('[FrameCapture] Reinitializing camera...');
        await initialize();
        // initialize() already calls _preWarmImageReader(), so no extra wait needed.
      }
    }

    throw CameraException('Capture failed', 'All capture attempts failed');
  }

  /// Liberates camera resources.
  ///
  /// Should be called when the camera is no longer needed or when
  /// the app goes to background.
  Future<void> dispose() async {
    print('[FrameCapture] dispose() called, isInitialized=$_isInitialized');
    try {
      await _controller?.dispose();
    } catch (e) {
      print('[FrameCapture] dispose() error (non-critical): $e');
    }
    _controller = null;
    _isInitialized = false;
    _isImageReaderWarmed = false;
    print('[FrameCapture] dispose() complete');
  }

  /// Returns whether the camera is initialized.
  bool get isInitialized => _isInitialized;
}

/// Exception thrown when camera permissions are denied.
class PermissionDeniedException implements Exception {
  final String message;

  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}
