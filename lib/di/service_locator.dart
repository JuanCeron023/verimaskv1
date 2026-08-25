import 'package:get_it/get_it.dart';
import 'package:verimask/modules/capture_pipeline.dart';
import 'package:verimask/modules/certification_engine.dart';
import 'package:verimask/modules/ttl_manager.dart';
import 'package:verimask/pipeline/end_to_end_pipeline.dart';
import 'package:verimask/services/device_info_service.dart';
import 'package:verimask/services/frame_capture_impl.dart';
import 'package:verimask/services/landmark_detector_impl.dart';
import 'package:verimask/services/permission_manager.dart';
import 'package:verimask/services/permission_manager_impl.dart';
import 'package:verimask/services/secure_storage_service.dart';
import 'package:verimask/services/segmentation_provider_impl.dart';
import 'package:verimask/services/share_service.dart';

final getIt = GetIt.instance;

/// Configures dependency injection for the application.
Future<void> setupDependencies() async {
  // Infrastructure
  getIt.registerLazySingleton<PermissionManager>(
    () => PermissionManagerImpl(),
  );

  getIt.registerLazySingleton<DeviceInfoService>(
    () => DeviceInfoServiceImpl(),
  );

  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageServiceImpl(),
  );

  // Camera & ML Services
  getIt.registerLazySingleton<FrameCapture>(
    () => FrameCaptureImpl(
      permissionManager: getIt<PermissionManager>(),
    ),
  );

  getIt.registerLazySingleton<LandmarkDetector>(
    () => LandmarkDetectorImpl(),
  );

  getIt.registerLazySingleton<SegmentationProvider>(
    () => SegmentationProviderImpl(),
  );

  // Business Modules
  getIt.registerLazySingleton<TTLManager>(
    () => TTLManagerImpl(),
  );

  getIt.registerLazySingleton<CaptureAndProcessPipeline>(
    () => CaptureAndProcessPipeline(
      frameCapture: getIt<FrameCapture>(),
      landmarkDetector: getIt<LandmarkDetector>(),
      segmentationProvider: getIt<SegmentationProvider>(),
    ),
  );

  getIt.registerLazySingleton<CertificationEngine>(
    () => CertificationEngineImpl(
      storage: getIt<SecureStorageService>(),
    ),
  );

  getIt.registerLazySingleton<ShareService>(
    () => ShareServiceImpl(),
  );

  getIt.registerLazySingleton<EndToEndPipeline>(
    () => EndToEndPipeline(
      capturePipeline: getIt<CaptureAndProcessPipeline>(),
      certificationEngine: getIt<CertificationEngine>(),
      ttlManager: getIt<TTLManager>(),
      shareService: getIt<ShareService>(),
    ),
  );

  await _initializeServices();
}

Future<void> _initializeServices() async {
  final certEngine = getIt<CertificationEngine>() as CertificationEngineImpl;
  await certEngine.initializeKeyPair();
}

Future<void> disposeDependencies() async {
  final frameCapture = getIt<FrameCapture>() as FrameCaptureImpl;
  await frameCapture.dispose();

  final landmarkDetector = getIt<LandmarkDetector>() as LandmarkDetectorImpl;
  landmarkDetector.dispose();

  final segmentationProvider = getIt<SegmentationProvider>() as SegmentationProviderImpl;
  segmentationProvider.dispose();

  await getIt.reset();
}
