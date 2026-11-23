import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:keeauth/l10n/app_localizations.dart';

/// Outcome of the camera permission flow.
enum CameraPermissionResult {
  /// Permission is granted — the caller may open the scanner.
  granted,

  /// The user declined the in-app rationale or the system dialog.
  denied,

  /// The user has permanently denied the permission; only system settings can
  /// grant it again.
  permanentlyDenied,

  /// The rationale dialog was dismissed without an explicit choice.
  dismissed,
}

/// Shows an in-app explanation of *why* the camera is needed, then requests the
/// system permission.
///
/// Compliance requirement (《APP用户权益保护测评规范 第4部分：权限索取行为》4.1):
/// the purpose must be explained to the user at the moment the permission is
/// requested — before the system permission dialog appears.
Future<CameraPermissionResult> ensureCameraPermission(
  BuildContext context,
) async {
  final l10n = AppLocalizations.of(context);

  var status = await Permission.camera.status;
  if (status.isGranted) return CameraPermissionResult.granted;
  if (status.isPermanentlyDenied) {
    return CameraPermissionResult.permanentlyDenied;
  }

  if (!context.mounted) return CameraPermissionResult.dismissed;

  final proceed = await showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => AlertDialog(
          icon: const Icon(Icons.photo_camera_outlined),
          title: Text(l10n?.cameraPermissionTitle ?? 'Camera Usage'),
          content: Text(
            l10n?.cameraPermissionRationale ??
                'KeeAuth needs the camera to scan QR codes when adding authenticator accounts. '
                    'Camera frames are processed only on your device and are never uploaded, '
                    'stored, or shared with any third party.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n?.cameraPermissionCancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(l10n?.cameraPermissionAllow ?? 'Continue'),
            ),
          ],
        ),
  );

  if (proceed != true) return CameraPermissionResult.dismissed;

  status = await Permission.camera.request();
  if (status.isGranted) return CameraPermissionResult.granted;
  if (status.isPermanentlyDenied) {
    return CameraPermissionResult.permanentlyDenied;
  }
  return CameraPermissionResult.denied;
}

/// Tells the user why the scanner cannot open and, for a permanent denial,
/// offers a shortcut to the system settings page.
Future<void> showCameraPermissionDenied(
  BuildContext context,
  CameraPermissionResult result,
) async {
  if (!context.mounted) return;
  final l10n = AppLocalizations.of(context);

  if (result == CameraPermissionResult.permanentlyDenied) {
    final openSettings = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: Text(l10n?.cameraPermissionTitle ?? 'Camera Usage'),
            content: Text(
              l10n?.cameraPermissionPermanentlyDenied ??
                  'Camera permission has been denied. Please enable it in system '
                      'settings and try again.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n?.cameraPermissionCancel ?? 'Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(l10n?.openSystemSettings ?? 'Open Settings'),
              ),
            ],
          ),
    );
    if (openSettings == true) {
      await openAppSettings();
    }
    return;
  }

  if (result == CameraPermissionResult.denied) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.cameraPermissionDenied ??
              'Camera permission was not granted, so QR code scanning is unavailable.',
        ),
      ),
    );
  }
}
