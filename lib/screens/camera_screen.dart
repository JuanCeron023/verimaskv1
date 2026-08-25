import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:verimask/l10n/app_localizations.dart';
import 'package:verimask/models/pipeline_error_code.dart';
import 'package:verimask/models/pipeline_stage.dart';
import 'package:verimask/modules/capture_pipeline.dart';
import 'package:verimask/pipeline/end_to_end_pipeline.dart';
import 'package:verimask/screens/result_screen.dart';
import 'package:verimask/services/frame_capture_impl.dart';

/// Camera screen for capturing anonymized photos.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

@visibleForTesting
class CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  bool _isProcessing = false;
  String? _statusMessage;
  String? _errorMessage;

  Uint8List? _frozenFrame;
  PipelineStage? _currentStage;

  late final EndToEndPipeline _endToEndPipeline;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _endToEndPipeline = GetIt.instance<EndToEndPipeline>();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!mounted) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() {
          _errorMessage = l10n.cameraNotAvailable;
        });
        return;
      }

      CameraDescription? frontCamera;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }
      frontCamera ??= cameras.first;

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _errorMessage = l10n.cameraPermissionRequired;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      final controllerToDispose = _cameraController;
      _cameraController = null;
      if (mounted) {
        setState(() => _isCameraInitialized = false);
      }
      controllerToDispose?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (!_isProcessing) {
        _initializeCamera();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _onCapturePressed() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = null;
      _errorMessage = null;
      _frozenFrame = null;
      _currentStage = null;
    });

    String? preCapturedJpegPath;
    try {
      final xFile = await _cameraController!.takePicture();
      final bytes = await xFile.readAsBytes();
      preCapturedJpegPath = xFile.path;
      if (mounted) setState(() => _frozenFrame = bytes);
    } catch (_) {}

    final controllerToDispose = _cameraController;
    _cameraController = null;
    if (mounted) setState(() => _isCameraInitialized = false);
    await controllerToDispose?.dispose();
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final l10n = AppLocalizations.of(context)!;
      final result = await _endToEndPipeline.execute(
        onProgress: (stage) {
          if (mounted) {
            setState(() => _currentStage = stage);
          }
        },
        preCapturedJpegPath: preCapturedJpegPath,
      );

      if (!mounted) return;

      setState(() {
        _frozenFrame = null;
        _currentStage = null;
      });

      if (result.success && result.certifiedPhoto != null) {
        HapticFeedback.mediumImpact();
        setState(() {
          _isProcessing = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              imageData: result.certifiedPhoto!.imageData,
            ),
          ),
        );
      } else {
        setState(() {
          _isProcessing = false;
          _frozenFrame = null;
          _currentStage = null;
          _errorMessage = result.errorCode != null
              ? _mapErrorCodeToL10n(result.errorCode!, l10n)
              : l10n.genericError;
        });
      }
    } catch (e) {
      if (!mounted) return;
      final l10nFallback = AppLocalizations.of(context)!;
      setState(() {
        _isProcessing = false;
        _frozenFrame = null;
        _currentStage = null;
        _errorMessage = l10nFallback.genericError;
      });
    }

    if (mounted) {
      final frameCaptureImpl = GetIt.instance<FrameCapture>();
      if (frameCaptureImpl is FrameCaptureImpl) {
        await frameCaptureImpl.dispose();
      }
      _initializeCamera();
    }
  }

  String _mapErrorCodeToL10n(PipelineErrorCode code, AppLocalizations l10n) {
    return switch (code) {
      PipelineErrorCode.captureError => l10n.captureError,
      PipelineErrorCode.processingError => l10n.processingError,
      PipelineErrorCode.certificationError => l10n.processingError,
      PipelineErrorCode.genericError => l10n.genericError,
    };
  }

  String _mapStageToL10n(PipelineStage stage, AppLocalizations l10n) {
    return switch (stage) {
      PipelineStage.processingPhoto => l10n.progressProcessingPhoto,
      PipelineStage.certifying => l10n.progressCertifying,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.cameraTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildCameraPreview(theme, l10n),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: _buildStatusArea(theme, l10n),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: _buildCaptureButton(theme, l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(ThemeData theme, AppLocalizations l10n) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_isProcessing && _frozenFrame != null)
          SizedBox.expand(
            child: Transform.flip(
              flipX: true,
              child: Image.memory(
                _frozenFrame!,
                fit: BoxFit.cover,
              ),
            ),
          )
        else if (_isCameraInitialized && _cameraController != null)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _cameraController!.value.previewSize?.height ?? 1,
                height: _cameraController!.value.previewSize?.width ?? 1,
                child: CameraPreview(_cameraController!),
              ),
            ),
          )
        else
          Container(
            color: const Color(0xFF1A1A1A),
            child: Center(
              child: _errorMessage != null
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.white54),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        if (_isProcessing && _frozenFrame != null)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    if (_currentStage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _mapStageToL10n(_currentStage!, l10n),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        Positioned(
          top: 8,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    l10n.privacyBadge,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusArea(ThemeData theme, AppLocalizations l10n) {
    if (_errorMessage != null) {
      return Text(
        _errorMessage!,
        style: TextStyle(color: theme.colorScheme.error),
        textAlign: TextAlign.center,
      );
    }

    if (_statusMessage != null) {
      return Text(
        _statusMessage!,
        style: theme.textTheme.bodyMedium,
        textAlign: TextAlign.center,
        key: const Key('camera_status_message'),
      );
    }

    if (_isProcessing) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(l10n.processingPhoto),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCaptureButton(ThemeData theme, AppLocalizations l10n) {
    final enabled = !_isProcessing && _isCameraInitialized;

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        key: const Key('capture_button'),
        onPressed: enabled ? _onCapturePressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.black,
          textStyle: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(l10n.captureButtonSimple, textAlign: TextAlign.center),
      ),
    );
  }
}
