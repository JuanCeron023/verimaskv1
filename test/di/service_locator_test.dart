import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/di/service_locator.dart';
import 'package:verimask/modules/capture_pipeline.dart';
import 'package:verimask/modules/certification_engine.dart';
import 'package:verimask/modules/ttl_manager.dart';
import 'package:verimask/services/device_info_service.dart';
import 'package:verimask/services/permission_manager.dart';
import 'package:verimask/services/secure_storage_service.dart';

void main() {
  group('Service Locator', () {
    setUp(() async {
      if (getIt.isRegistered<PermissionManager>()) {
        await getIt.reset();
      }
    });

    test('setupDependencies registers all core services', () async {
      await setupDependencies();

      expect(getIt.isRegistered<PermissionManager>(), isTrue);
      expect(getIt.isRegistered<DeviceInfoService>(), isTrue);
      expect(getIt.isRegistered<SecureStorageService>(), isTrue);

      expect(getIt.isRegistered<FrameCapture>(), isTrue);
      expect(getIt.isRegistered<LandmarkDetector>(), isTrue);
      expect(getIt.isRegistered<SegmentationProvider>(), isTrue);

      expect(getIt.isRegistered<TTLManager>(), isTrue);
      expect(getIt.isRegistered<CaptureAndProcessPipeline>(), isTrue);
      expect(getIt.isRegistered<CertificationEngine>(), isTrue);
    }, skip: 'Requires Flutter bindings and device platform channels');

    test('services are singletons', () async {
      await setupDependencies();

      final permissionManager1 = getIt<PermissionManager>();
      final permissionManager2 = getIt<PermissionManager>();
      expect(identical(permissionManager1, permissionManager2), isTrue);
    }, skip: 'Requires Flutter bindings and device platform channels');
  });
}
