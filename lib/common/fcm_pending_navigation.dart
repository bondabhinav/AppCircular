import 'package:flutter/foundation.dart';
import 'package:flexischool/common/fcm_navigation_handler.dart';

class FCMPendingNavigation {
  static final FCMPendingNavigation _instance =
      FCMPendingNavigation._internal();

  factory FCMPendingNavigation() {
    return _instance;
  }

  FCMPendingNavigation._internal();

  Map<String, dynamic>? _pendingNavigationData;
  bool _appStartupComplete = false;

  /// Store FCM navigation data for later execution
  static void setPendingNavigation(Map<String, dynamic> fcmData) {
    debugPrint("=== STORING PENDING FCM NAVIGATION ===");
    debugPrint("FCM Data: $fcmData");
    _instance._pendingNavigationData = fcmData;
    debugPrint("=== END STORING PENDING NAVIGATION ===");

    // If app startup is already complete, execute immediately
    if (_instance._appStartupComplete) {
      _instance._executePendingNavigation();
    }
  }

  /// Mark app startup as complete and execute any pending navigation
  static void markAppStartupComplete() {
    debugPrint("=== APP STARTUP COMPLETE ===");
    _instance._appStartupComplete = true;

    // Execute any pending navigation
    _instance._executePendingNavigation();
  }

  /// Execute pending navigation if available
  void _executePendingNavigation() {
    if (_pendingNavigationData != null) {
      debugPrint("=== EXECUTING PENDING FCM NAVIGATION ===");
      debugPrint("Pending Data: $_pendingNavigationData");

      final data = _pendingNavigationData!;
      _pendingNavigationData = null; // Clear after use

      // Add delay to ensure UI is ready
      Future.delayed(const Duration(milliseconds: 1000), () {
        FCMNavigationHandler.handleFCMNavigation(data);
      });

      debugPrint("=== END EXECUTING PENDING NAVIGATION ===");
    } else {
      debugPrint("No pending FCM navigation to execute");
    }
  }

  /// Check if there's pending navigation
  static bool hasPendingNavigation() {
    return _instance._pendingNavigationData != null;
  }

  /// Clear pending navigation without executing
  static void clearPendingNavigation() {
    debugPrint("Clearing pending FCM navigation");
    _instance._pendingNavigationData = null;
  }

  /// Get pending navigation data (for debugging)
  static Map<String, dynamic>? getPendingNavigationData() {
    return _instance._pendingNavigationData;
  }
}
