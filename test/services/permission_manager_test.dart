import 'package:flutter_test/flutter_test.dart';
import 'package:verimask/services/permission_manager.dart';
import 'package:verimask/services/permission_manager_impl.dart';

void main() {
  group('PermissionManager', () {
    test('PermissionState enum has all expected values', () {
      expect(PermissionState.values.length, 4);
      expect(PermissionState.values, contains(PermissionState.granted));
      expect(PermissionState.values, contains(PermissionState.denied));
      expect(PermissionState.values, contains(PermissionState.permanentlyDenied));
      expect(PermissionState.values, contains(PermissionState.restricted));
    });

    test('PermissionManagerImpl can be instantiated', () {
      final permissionManager = PermissionManagerImpl();
      expect(permissionManager, isA<PermissionManager>());
    });

    test('PermissionManagerImpl implements all required methods', () {
      final permissionManager = PermissionManagerImpl();
      
      // Verify that all methods exist and have correct signatures
      expect(permissionManager.checkCameraPermission, isA<Function>());
      expect(permissionManager.requestCameraPermission, isA<Function>());
      expect(permissionManager.ensureCameraPermission, isA<Function>());
      expect(permissionManager.openAppSettings, isA<Function>());
    });

    test('PermissionManagerImpl has static dialog methods', () {
      // Verify that static dialog methods exist
      expect(PermissionManagerImpl.showPermanentlyDeniedDialog, isA<Function>());
      expect(PermissionManagerImpl.showRestrictedDialog, isA<Function>());
      expect(PermissionManagerImpl.showDeniedDialog, isA<Function>());
    });
  });
}

