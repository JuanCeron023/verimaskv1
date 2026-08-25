/// Permission states that can be returned by the permission manager.
enum PermissionState {
  /// Permission has been granted by the user.
  granted,

  /// Permission has been denied by the user.
  denied,

  /// Permission has been permanently denied by the user.
  /// The user must manually enable it in system settings.
  permanentlyDenied,

  /// Permission is restricted (e.g., due to parental controls).
  restricted,
}

/// Service for managing camera permissions using permission_handler.
abstract class PermissionManager {
  /// Checks the current state of the camera permission.
  Future<PermissionState> checkCameraPermission();

  /// Requests camera permission from the user.
  /// Returns the new permission state after the request.
  Future<PermissionState> requestCameraPermission();

  /// Ensures camera permission is granted.
  /// If not granted, requests permission or shows appropriate dialog.
  /// Returns true if permission is granted, false otherwise.
  Future<bool> ensureCameraPermission();

  /// Opens the app settings page where the user can manually enable permissions.
  Future<void> openAppSettings();
}
