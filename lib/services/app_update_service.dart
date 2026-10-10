import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

import 'local_store.dart';

/// Production-safe Google Play in-app update handling.
///
/// Uses Google's native Play in-app update flow on Android. Updates are only
/// checked when the app is running from Google Play (or a supported Play test
/// track). Sideloaded/debug builds simply fail closed.
class AppUpdateService {
  AppUpdateService._();

  static StreamSubscription<InstallStatus>? _installSubscription;
  static bool _checkInProgress = false;
  static bool _updateFlowActive = false;

  /// Checks for an update at most once every 12 hours during normal startup.
  /// Set [force] to true for a manual Settings check.
  static Future<void> checkForUpdate({bool force = false}) async {
    if (!Platform.isAndroid || kIsWeb || _checkInProgress || _updateFlowActive) {
      return;
    }

    if (!force) {
      final last = await LocalStore.lastUpdateCheck();
      if (last != null && DateTime.now().difference(last) < const Duration(hours: 12)) {
        return;
      }
    }

    _checkInProgress = true;
    try {
      await LocalStore.setLastUpdateCheck(DateTime.now());

      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      // If Google Play says the update is already downloaded, install it.
      if (info.installStatus == InstallStatus.downloaded) {
        await InAppUpdate.completeFlexibleUpdate();
        return;
      }

      _updateFlowActive = true;

      // Normal app releases use a flexible update: Play shows its native
      // update consent UI, downloads in the background, then we complete the
      // install automatically once Play reports DOWNLOADED.
      if (info.flexibleUpdateAllowed) {
        _listenForFlexibleCompletion();
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result != AppUpdateResult.success) {
          _stopListening();
          _updateFlowActive = false;
        }
        return;
      }

      // Fallback for cases where Play only permits an immediate update.
      if (info.immediateUpdateAllowed) {
        await InAppUpdate.performImmediateUpdate();
        _updateFlowActive = false;
        return;
      }

      _updateFlowActive = false;
    } catch (_) {
      // Update checks must never block or crash the finance app. Play can
      // legitimately return API_NOT_AVAILABLE for sideloaded/debug builds.
      _stopListening();
      _updateFlowActive = false;
    } finally {
      _checkInProgress = false;
    }
  }

  static void _listenForFlexibleCompletion() {
    _stopListening();
    _installSubscription = InAppUpdate.installUpdateListener.listen((status) async {
      if (status == InstallStatus.downloaded) {
        try {
          await InAppUpdate.completeFlexibleUpdate();
        } catch (_) {
          // Keep the app usable if Play cannot complete the installation yet.
        } finally {
          _stopListening();
          _updateFlowActive = false;
        }
      } else if (status == InstallStatus.failed || status == InstallStatus.canceled) {
        _stopListening();
        _updateFlowActive = false;
      }
    });
  }

  static void _stopListening() {
    _installSubscription?.cancel();
    _installSubscription = null;
  }

  static Future<void> dispose() async {
    await _installSubscription?.cancel();
    _installSubscription = null;
  }
}
