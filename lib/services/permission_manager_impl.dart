import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'permission_manager.dart';
import '../l10n/app_localizations.dart';

/// Implementation of [PermissionManager] using permission_handler package.
class PermissionManagerImpl implements PermissionManager {
  /// Checks the current state of the camera permission.
  @override
  Future<PermissionState> checkCameraPermission() async {
    final status = await ph.Permission.camera.status;

    if (status.isGranted) {
      return PermissionState.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionState.permanentlyDenied;
    } else if (status.isRestricted) {
      return PermissionState.restricted;
    } else {
      return PermissionState.denied;
    }
  }

  /// Requests camera permission from the user.
  @override
  Future<PermissionState> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();

    if (status.isGranted) {
      return PermissionState.granted;
    } else if (status.isPermanentlyDenied) {
      return PermissionState.permanentlyDenied;
    } else if (status.isRestricted) {
      return PermissionState.restricted;
    } else {
      return PermissionState.denied;
    }
  }

  /// Opens the app settings page.
  @override
  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  /// Ensures camera permission is granted.
  @override
  Future<bool> ensureCameraPermission() async {
    final currentStatus = await checkCameraPermission();

    switch (currentStatus) {
      case PermissionState.granted:
        return true;

      case PermissionState.denied:
        // Request permission
        final newStatus = await requestCameraPermission();
        return newStatus == PermissionState.granted;

      case PermissionState.permanentlyDenied:
        // Permission is permanently denied, cannot request again
        return false;

      case PermissionState.restricted:
        // Permission is restricted (parental controls, etc.)
        return false;
    }
  }

  /// Shows a dialog when permission is permanently denied.
  /// This method should be called from the UI layer when needed.
  static Future<void> showPermanentlyDeniedDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.cameraPermissionRequired),
          content: Text(l10n.cameraPermissionPermanentlyDenied),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.buttonCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(l10n.cameraPermissionSettings),
              onPressed: () async {
                Navigator.of(context).pop();
                await ph.openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog when permission is restricted.
  /// This method should be called from the UI layer when needed.
  static Future<void> showRestrictedDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.cameraPermissionRequired),
          content: Text(l10n.cameraPermissionRestricted),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.buttonDone),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a dialog when permission is denied.
  /// This method should be called from the UI layer when needed.
  static Future<void> showDeniedDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.cameraPermissionRequired),
          content: Text(l10n.cameraPermissionDenied),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.buttonCancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(l10n.buttonRetry),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
