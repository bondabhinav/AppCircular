import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
// Firebase Storage is optional - only needed if using Firebase Storage instead of direct URLs
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class OtaUpdateService {
  static final OtaUpdateService _instance = OtaUpdateService._internal();
  factory OtaUpdateService() => _instance;
  OtaUpdateService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  StreamSubscription<OtaEvent>? _otaSubscription;
  bool _isUpdating = false;
  BuildContext? _progressDialogContext;

  /// Check for updates and download/install if available
  /// Returns true if update is available and started, false otherwise
  Future<bool> checkAndUpdate({
    BuildContext? context,
    bool showProgress = true,
    Function(double)? onProgress,
    Function(String)? onError,
  }) async {
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('OTA Update: [START] checkAndUpdate() called');
    debugPrint('OTA Update: Context provided: ${context != null}');
    debugPrint('OTA Update: Show progress: $showProgress');

    if (_isUpdating) {
      debugPrint('OTA Update: [SKIP] Update already in progress');
      debugPrint('═══════════════════════════════════════════════════════════');
      return false;
    }

    try {
      debugPrint('OTA Update: [STEP 1] Getting current app version...');
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuildNumber = packageInfo.buildNumber;

      debugPrint('OTA Update: [STEP 1] ✓ Current version: $currentVersion');
      debugPrint(
        'OTA Update: [STEP 1] ✓ Current build number: $currentBuildNumber',
      );

      debugPrint('OTA Update: [STEP 2] Fetching Firebase Remote Config...');
      // Fetch remote config to get update info
      await _remoteConfig.fetchAndActivate();
      debugPrint('OTA Update: [STEP 2] ✓ Remote Config fetched and activated');

      debugPrint('OTA Update: [STEP 3] Reading Remote Config parameters...');
      // Get update configuration from Remote Config
      // Try to read from JSON object first (ota_update_config), then fallback to individual parameters
      String? updateEnabledStr;
      String? latestVersion;
      String? latestBuildNumber;
      String? apkUrl;
      String? apkPath;
      String? useFirebaseStorageStr;
      String? forceUpdateStr;
      String? updateMessage;

      // Try to read from JSON object (ota_update_config)
      final configJson = _remoteConfig.getString('ota_update_config');
      if (configJson.isNotEmpty) {
        debugPrint(
          'OTA Update: [STEP 3] Found ota_update_config JSON, parsing...',
        );
        try {
          final config = jsonDecode(configJson) as Map<String, dynamic>;
          debugPrint('OTA Update: [STEP 3] ✓ Successfully parsed JSON config');

          updateEnabledStr = config['ota_update_enabled']?.toString();
          latestVersion = config['ota_latest_version']?.toString();
          latestBuildNumber = config['ota_latest_build_number']?.toString();
          apkUrl = config['ota_apk_url']?.toString();
          apkPath = config['ota_apk_path']?.toString();
          useFirebaseStorageStr = config['ota_use_firebase_storage']
              ?.toString();
          forceUpdateStr = config['ota_force_update']?.toString();
          updateMessage = config['ota_update_message']?.toString();

          debugPrint('OTA Update: [STEP 3] Values extracted from JSON:');
        } catch (e) {
          debugPrint('OTA Update: [STEP 3] ✗ Error parsing JSON: $e');
          debugPrint(
            'OTA Update: [STEP 3] Falling back to individual parameters...',
          );
          // Fall through to individual parameter reading
        }
      }

      // Fallback to individual parameters if JSON not found or parsing failed
      if (updateEnabledStr == null) {
        debugPrint('OTA Update: [STEP 3] Reading individual parameters...');
        updateEnabledStr = _remoteConfig
            .getBool('ota_update_enabled')
            .toString();
        latestVersion = _remoteConfig.getString('ota_latest_version');
        latestBuildNumber = _remoteConfig.getString('ota_latest_build_number');
        apkUrl = _remoteConfig.getString('ota_apk_url');
        apkPath = _remoteConfig.getString('ota_apk_path');
        useFirebaseStorageStr = _remoteConfig
            .getBool('ota_use_firebase_storage')
            .toString();
        forceUpdateStr = _remoteConfig.getBool('ota_force_update').toString();
        updateMessage = _remoteConfig.getString('ota_update_message');
      }

      // Parse values
      final updateEnabled =
          updateEnabledStr == 'true' || updateEnabledStr == '1';
      final useFirebaseStorage =
          useFirebaseStorageStr == 'true' || useFirebaseStorageStr == '1';
      final forceUpdate = forceUpdateStr == 'true' || forceUpdateStr == '1';

      debugPrint('OTA Update: [STEP 3] Remote Config values:');
      debugPrint('OTA Update:   - ota_update_enabled: $updateEnabled');
      debugPrint(
        'OTA Update:   - ota_latest_version: "${latestVersion ?? ""}"',
      );
      debugPrint(
        'OTA Update:   - ota_latest_build_number: "${latestBuildNumber ?? ""}"',
      );
      debugPrint(
        'OTA Update:   - ota_apk_url: "${apkUrl != null && apkUrl.isNotEmpty ? (apkUrl.length > 50 ? "${apkUrl.substring(0, 50)}..." : apkUrl) : "EMPTY"}"',
      );
      debugPrint('OTA Update:   - ota_apk_path: "${apkPath ?? "EMPTY"}"');
      debugPrint(
        'OTA Update:   - ota_use_firebase_storage: $useFirebaseStorage',
      );
      debugPrint('OTA Update:   - ota_force_update: $forceUpdate');
      debugPrint(
        'OTA Update:   - ota_update_message: "${updateMessage ?? "EMPTY"}"',
      );

      if (!updateEnabled) {
        debugPrint('OTA Update: [STOP] Updates are disabled in Remote Config');
        debugPrint(
          '═══════════════════════════════════════════════════════════',
        );
        return false;
      }

      debugPrint('OTA Update: [STEP 4] Comparing versions...');
      // Compare versions
      final shouldUpdate = _shouldUpdate(
        currentVersion: currentVersion,
        currentBuild: currentBuildNumber,
        latestVersion: latestVersion ?? '',
        latestBuild: latestBuildNumber ?? '',
      );

      debugPrint(
        'OTA Update: [STEP 4] Version comparison result: $shouldUpdate',
      );
      if (!shouldUpdate) {
        debugPrint('OTA Update: [STOP] App is up to date (no update needed)');
        debugPrint(
          '═══════════════════════════════════════════════════════════',
        );
        return false;
      }
      debugPrint('OTA Update: [STEP 4] ✓ Update needed!');

      debugPrint('OTA Update: [STEP 5] Showing update dialog...');
      // Show update dialog if context is provided
      if (context != null && context.mounted) {
        debugPrint('OTA Update: [STEP 5] Context is available and mounted');
        final shouldProceed = await _showUpdateDialog(
          context: context,
          currentVersion: currentVersion,
          latestVersion: latestVersion ?? '',
          message: (updateMessage != null && updateMessage.isNotEmpty)
              ? updateMessage
              : 'A new version is available. Would you like to update now?',
          forceUpdate: forceUpdate,
        );

        debugPrint(
          'OTA Update: [STEP 5] User response: $shouldProceed (forceUpdate: $forceUpdate)',
        );
        if (!shouldProceed && !forceUpdate) {
          debugPrint('OTA Update: [STOP] User cancelled update');
          debugPrint(
            '═══════════════════════════════════════════════════════════',
          );
          return false;
        }
        debugPrint('OTA Update: [STEP 5] ✓ User approved update');
      } else {
        debugPrint('OTA Update: [STEP 5] No context provided, skipping dialog');
      }

      debugPrint('OTA Update: [STEP 6] Getting download URL...');
      // Get download URL
      String? downloadUrl;

      // Check if apkUrl is a direct URL (starts with http/https)
      if (apkUrl != null &&
          apkUrl.isNotEmpty &&
          (apkUrl.startsWith('http://') || apkUrl.startsWith('https://'))) {
        // Use direct URL (GitHub Releases, custom server, etc.)
        downloadUrl = apkUrl;
        debugPrint('OTA Update: [STEP 6] ✓ Using direct URL (GitHub/Server)');
        debugPrint('OTA Update: [STEP 6] Download URL: $downloadUrl');
      } else if (useFirebaseStorage && apkPath != null && apkPath.isNotEmpty) {
        // Use Firebase Storage (if configured)
        debugPrint('OTA Update: [STEP 6] Using Firebase Storage...');
        try {
          downloadUrl = await _getDownloadUrlFromFirebase(apkPath);
          if (downloadUrl == null || downloadUrl.isEmpty) {
            debugPrint(
              'OTA Update: [STEP 6] ✗ Failed to get download URL from Firebase Storage',
            );
            onError?.call('Failed to get download URL from Firebase Storage');
            debugPrint(
              '═══════════════════════════════════════════════════════════',
            );
            return false;
          }
          debugPrint(
            'OTA Update: [STEP 6] ✓ Got Firebase Storage URL: $downloadUrl',
          );
        } catch (e) {
          debugPrint('OTA Update: [STEP 6] ✗ Firebase Storage error: $e');
          onError?.call(
            'Firebase Storage not available. Please use direct URL instead.',
          );
          debugPrint(
            '═══════════════════════════════════════════════════════════',
          );
          return false;
        }
      } else {
        debugPrint('OTA Update: [STEP 6] ✗ No APK URL configured');
        debugPrint('OTA Update: [STEP 6] apkUrl: ${apkUrl ?? "null"}');
        debugPrint(
          'OTA Update: [STEP 6] apkUrl empty: ${apkUrl == null || apkUrl.isEmpty}',
        );
        debugPrint(
          'OTA Update: [STEP 6] useFirebaseStorage: $useFirebaseStorage',
        );
        debugPrint('OTA Update: [STEP 6] apkPath: ${apkPath ?? "null"}');
        debugPrint(
          'OTA Update: [STEP 6] apkPath empty: ${apkPath == null || apkPath.isEmpty}',
        );
        debugPrint(
          'OTA Update: [STEP 6] Provide ota_apk_url with full URL (e.g., GitHub Releases URL)',
        );
        onError?.call('APK URL not configured');
        debugPrint(
          '═══════════════════════════════════════════════════════════',
        );
        return false;
      }

      debugPrint('OTA Update: [STEP 7] Starting OTA update process...');
      debugPrint('OTA Update: [STEP 7] Download URL: $downloadUrl');

      // Show progress dialog if context is available
      if (showProgress && context != null && context.mounted) {
        _showProgressDialog(context);
      }

      // Start OTA update
      _isUpdating = true;
      debugPrint('OTA Update: [STEP 7] _isUpdating set to true');
      await _startOtaUpdate(
        url: downloadUrl,
        onProgress: (progress) {
          if (showProgress &&
              _progressDialogContext != null &&
              _progressDialogContext!.mounted) {
            _updateProgressDialog(_progressDialogContext!, progress);
            debugPrint(
              'OTA Update: [PROGRESS] ${(progress * 100).toStringAsFixed(1)}%',
            );
          }
          onProgress?.call(progress);
        },
        onError: (error) {
          _isUpdating = false;
          debugPrint('OTA Update: [ERROR] $error');
          debugPrint('OTA Update: [ERROR] _isUpdating set to false');
          _dismissProgressDialog();
          onError?.call(error);
          if (context != null && context.mounted) {
            _showErrorDialog(context, error);
          }
          debugPrint(
            '═══════════════════════════════════════════════════════════',
          );
        },
        onSuccess: () {
          _isUpdating = false;
          debugPrint(
            'OTA Update: [SUCCESS] Installation completed successfully',
          );
          debugPrint('OTA Update: [SUCCESS] _isUpdating set to false');
          _dismissProgressDialog();
          if (context != null && context.mounted) {
            _showSuccessDialog(context);
          }
          debugPrint(
            '═══════════════════════════════════════════════════════════',
          );
        },
      );

      debugPrint('OTA Update: [STEP 7] ✓ OTA update process started');
      debugPrint('OTA Update: [END] Returning true (update started)');
      debugPrint('═══════════════════════════════════════════════════════════');
      return true;
    } catch (e, stackTrace) {
      _isUpdating = false;
      debugPrint('OTA Update: [EXCEPTION] Error occurred: $e');
      debugPrint('OTA Update: [EXCEPTION] Stack trace: $stackTrace');
      debugPrint('OTA Update: [EXCEPTION] _isUpdating set to false');
      onError?.call(e.toString());
      if (context != null && context.mounted) {
        _showErrorDialog(context, e.toString());
      }
      debugPrint('═══════════════════════════════════════════════════════════');
      return false;
    }
  }

  /// Get download URL from Firebase Storage (optional, only if using Firebase Storage)
  Future<String?> _getDownloadUrlFromFirebase(String path) async {
    debugPrint('OTA Update: [FIREBASE_STORAGE] Getting download URL...');
    debugPrint('OTA Update: [FIREBASE_STORAGE] Path: $path');
    try {
      final firebaseStorage = FirebaseStorage.instance;
      debugPrint(
        'OTA Update: [FIREBASE_STORAGE] Firebase Storage instance obtained',
      );
      final ref = firebaseStorage.ref(path);
      debugPrint(
        'OTA Update: [FIREBASE_STORAGE] Reference created for path: $path',
      );
      final url = await ref.getDownloadURL();
      debugPrint(
        'OTA Update: [FIREBASE_STORAGE] ✓ Download URL obtained: $url',
      );
      return url;
    } catch (e, stackTrace) {
      debugPrint(
        'OTA Update: [FIREBASE_STORAGE] ✗ Error getting download URL: $e',
      );
      debugPrint('OTA Update: [FIREBASE_STORAGE] ✗ Stack trace: $stackTrace');
      debugPrint(
        'OTA Update: [FIREBASE_STORAGE] Make sure Firebase Storage is enabled in Firebase Console',
      );
      return null;
    }
  }

  /// Compare versions to determine if update is needed
  bool _shouldUpdate({
    required String currentVersion,
    required String currentBuild,
    required String latestVersion,
    required String latestBuild,
  }) {
    debugPrint('OTA Update: [VERSION_CHECK] Comparing versions...');
    debugPrint(
      'OTA Update: [VERSION_CHECK] Current: $currentVersion (build: $currentBuild)',
    );
    debugPrint(
      'OTA Update: [VERSION_CHECK] Latest: $latestVersion (build: $latestBuild)',
    );

    // First check build number (more reliable)
    final currentBuildNum = int.tryParse(currentBuild) ?? 0;
    final latestBuildNum = int.tryParse(latestBuild) ?? 0;

    debugPrint(
      'OTA Update: [VERSION_CHECK] Current build number (parsed): $currentBuildNum',
    );
    debugPrint(
      'OTA Update: [VERSION_CHECK] Latest build number (parsed): $latestBuildNum',
    );

    if (latestBuildNum > currentBuildNum) {
      debugPrint(
        'OTA Update: [VERSION_CHECK] ✓ Update needed (build number: $latestBuildNum > $currentBuildNum)',
      );
      return true;
    }
    debugPrint(
      'OTA Update: [VERSION_CHECK] Build numbers same or lower, checking version strings...',
    );

    // If build numbers are same, check version strings
    final currentParts = currentVersion
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();
    final latestParts = latestVersion
        .split('.')
        .map((e) => int.tryParse(e) ?? 0)
        .toList();

    debugPrint(
      'OTA Update: [VERSION_CHECK] Current version parts: $currentParts',
    );
    debugPrint(
      'OTA Update: [VERSION_CHECK] Latest version parts: $latestParts',
    );

    // Pad to same length
    while (currentParts.length < latestParts.length) {
      currentParts.add(0);
    }
    while (latestParts.length < currentParts.length) {
      latestParts.add(0);
    }

    debugPrint(
      'OTA Update: [VERSION_CHECK] Padded current parts: $currentParts',
    );
    debugPrint('OTA Update: [VERSION_CHECK] Padded latest parts: $latestParts');

    for (int i = 0; i < currentParts.length; i++) {
      debugPrint(
        'OTA Update: [VERSION_CHECK] Comparing part $i: current=${currentParts[i]} vs latest=${latestParts[i]}',
      );
      if (latestParts[i] > currentParts[i]) {
        debugPrint(
          'OTA Update: [VERSION_CHECK] ✓ Update needed (version part $i: ${latestParts[i]} > ${currentParts[i]})',
        );
        return true;
      } else if (latestParts[i] < currentParts[i]) {
        debugPrint(
          'OTA Update: [VERSION_CHECK] ✗ No update (version part $i: ${latestParts[i]} < ${currentParts[i]})',
        );
        return false;
      }
    }

    debugPrint(
      'OTA Update: [VERSION_CHECK] ✗ No update needed (versions are equal)',
    );
    return false;
  }

  /// Start OTA update process
  Future<void> _startOtaUpdate({
    required String url,
    Function(double)? onProgress,
    Function(String)? onError,
    Function()? onSuccess,
  }) async {
    debugPrint('OTA Update: [START_OTA] _startOtaUpdate() called');
    debugPrint('OTA Update: [START_OTA] URL: $url');
    try {
      // Request install permission if needed
      if (Platform.isAndroid) {
        debugPrint('OTA Update: [START_OTA] Requesting install permission...');
        final status = await Permission.requestInstallPackages.request();
        debugPrint(
          'OTA Update: [START_OTA] Install permission status: $status',
        );
        if (!status.isGranted) {
          debugPrint('OTA Update: [START_OTA] ✗ Install permission denied');
          onError?.call(
            'Install permission denied. Please enable "Install unknown apps" in settings.',
          );
          return;
        }
        debugPrint('OTA Update: [START_OTA] ✓ Install permission granted');
      } else {
        debugPrint(
          'OTA Update: [START_OTA] Not Android platform, skipping permission request',
        );
      }

      debugPrint('OTA Update: [START_OTA] Starting OtaUpdate().execute()...');
      // Listen to OTA events
      _otaSubscription = OtaUpdate()
          .execute(url, destinationFilename: 'app-update.apk')
          .listen(
            (OtaEvent event) {
              debugPrint(
                'OTA Update: [OTA_EVENT] Received event: ${event.status}',
              );
              debugPrint('OTA Update: [OTA_EVENT] Event value: ${event.value}');
              switch (event.status) {
                case OtaStatus.DOWNLOADING:
                  debugPrint('OTA Update: [OTA_EVENT] Status: DOWNLOADING');
                  // Progress value is 0-100, convert to 0-1 for callback
                  double progress = 0.0;
                  if (event.value != null) {
                    if (event.value is num) {
                      progress = (event.value as num).toDouble() / 100.0;
                    } else {
                      final parsed = double.tryParse(event.value.toString());
                      if (parsed != null) {
                        progress = parsed > 1.0 ? parsed / 100.0 : parsed;
                      }
                    }
                  }
                  onProgress?.call(progress);
                  debugPrint(
                    'OTA Update: Downloading: ${(progress * 100).toStringAsFixed(1)}%',
                  );
                  break;

                case OtaStatus.INSTALLING:
                  debugPrint('OTA Update: [OTA_EVENT] Status: INSTALLING');
                  debugPrint('OTA Update: [OTA_EVENT] Installation started...');
                  break;

                case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
                  debugPrint(
                    'OTA Update: [OTA_EVENT] ✗ ERROR: PERMISSION_NOT_GRANTED_ERROR',
                  );
                  onError?.call('Install permission not granted');
                  break;

                case OtaStatus.INTERNAL_ERROR:
                  debugPrint('OTA Update: [OTA_EVENT] ✗ ERROR: INTERNAL_ERROR');
                  onError?.call('Internal error occurred');
                  break;

                case OtaStatus.ALREADY_RUNNING_ERROR:
                  debugPrint(
                    'OTA Update: [OTA_EVENT] ✗ ERROR: ALREADY_RUNNING_ERROR',
                  );
                  onError?.call('Update already in progress');
                  break;

                case OtaStatus.DOWNLOAD_ERROR:
                  debugPrint('OTA Update: [OTA_EVENT] ✗ ERROR: DOWNLOAD_ERROR');
                  onError?.call('Download failed');
                  break;

                case OtaStatus.CHECKSUM_ERROR:
                  debugPrint('OTA Update: [OTA_EVENT] ✗ ERROR: CHECKSUM_ERROR');
                  onError?.call('Checksum verification failed');
                  break;

                case OtaStatus.INSTALLATION_ERROR:
                  debugPrint(
                    'OTA Update: [OTA_EVENT] ✗ ERROR: INSTALLATION_ERROR',
                  );
                  onError?.call('Installation failed');
                  break;

                case OtaStatus.INSTALLATION_DONE:
                  debugPrint(
                    'OTA Update: [OTA_EVENT] ✓ SUCCESS: INSTALLATION_DONE',
                  );
                  debugPrint(
                    'OTA Update: [OTA_EVENT] Installation completed successfully',
                  );
                  onSuccess?.call();
                  break;

                default:
                  debugPrint(
                    'OTA Update: [OTA_EVENT] Unknown status: ${event.status}',
                  );
              }
            },
            onError: (error) {
              debugPrint('OTA Update: [OTA_EVENT] ✗ Stream error: $error');
              onError?.call(error.toString());
            },
          );
      debugPrint(
        'OTA Update: [START_OTA] ✓ OTA event stream subscription created',
      );
    } catch (e, stackTrace) {
      debugPrint('OTA Update: [START_OTA] ✗ Exception in _startOtaUpdate: $e');
      debugPrint('OTA Update: [START_OTA] ✗ Stack trace: $stackTrace');
      onError?.call(e.toString());
    }
  }

  /// Show update dialog
  Future<bool> _showUpdateDialog({
    required BuildContext context,
    required String currentVersion,
    required String latestVersion,
    required String message,
    required bool forceUpdate,
  }) async {
    debugPrint('OTA Update: [DIALOG] Showing update dialog...');
    debugPrint('OTA Update: [DIALOG] Current version: $currentVersion');
    debugPrint('OTA Update: [DIALOG] Latest version: $latestVersion');
    debugPrint('OTA Update: [DIALOG] Force update: $forceUpdate');
    debugPrint('OTA Update: [DIALOG] Message: $message');
    return await showDialog<bool>(
          context: context,
          barrierDismissible: !forceUpdate,
          builder: (context) => AlertDialog(
            title: const Text('Update Available'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message),
                const SizedBox(height: 16),
                Text('Current Version: $currentVersion'),
                Text('Latest Version: $latestVersion'),
                if (forceUpdate) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'This update is required to continue using the app.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Update Now'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Show progress dialog using root navigator to persist across navigation
  void _showProgressDialog(BuildContext context) {
    debugPrint('OTA Update: [PROGRESS_DIALOG] Showing progress dialog');
    _progressDialogContext = context;

    // Use rootNavigator: true to show dialog that persists across navigation
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // This makes dialog persist across navigation
      builder: (context) => PopScope(
        canPop: false, // Prevent dismissing during download
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Downloading update...'),
              const SizedBox(height: 10),
              Text('0%', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }

  /// Update progress dialog
  void _updateProgressDialog(BuildContext context, double progress) {
    if (!context.mounted) return;

    // Close current dialog and show updated one using root navigator
    Navigator.of(context, rootNavigator: true).pop();

    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true, // This makes dialog persist across navigation
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(value: progress),
              const SizedBox(height: 20),
              const Text('Downloading update...'),
              const SizedBox(height: 10),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dismiss progress dialog
  void _dismissProgressDialog() {
    if (_progressDialogContext != null && _progressDialogContext!.mounted) {
      debugPrint('OTA Update: [PROGRESS_DIALOG] Dismissing progress dialog');
      try {
        final navigator = Navigator.of(
          _progressDialogContext!,
          rootNavigator: true,
        );
        if (navigator.canPop()) {
          navigator.pop();
          debugPrint('OTA Update: [PROGRESS_DIALOG] ✓ Dialog dismissed');
        } else {
          debugPrint('OTA Update: [PROGRESS_DIALOG] No dialog to dismiss');
        }
      } catch (e) {
        debugPrint('OTA Update: [PROGRESS_DIALOG] Error dismissing: $e');
      }
      _progressDialogContext = null;
    } else {
      debugPrint(
        'OTA Update: [PROGRESS_DIALOG] Context not available for dismissal',
      );
    }
  }

  /// Show success dialog
  void _showSuccessDialog(BuildContext context) {
    debugPrint('OTA Update: [SUCCESS_DIALOG] Showing success dialog');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Downloaded'),
        content: const Text(
          'The update has been downloaded successfully. The installation will begin shortly.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(BuildContext context, String error) {
    debugPrint('OTA Update: [ERROR_DIALOG] Showing error dialog');
    debugPrint('OTA Update: [ERROR_DIALOG] Error message: $error');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Failed'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Cancel ongoing update
  void cancelUpdate() {
    debugPrint('OTA Update: [CANCEL] Cancelling update...');
    _otaSubscription?.cancel();
    _otaSubscription = null;
    _isUpdating = false;
    debugPrint('OTA Update: [CANCEL] ✓ Update cancelled');
  }

  /// Dispose resources
  void dispose() {
    debugPrint('OTA Update: [DISPOSE] Disposing OTA update service...');
    _dismissProgressDialog();
    cancelUpdate();
    debugPrint('OTA Update: [DISPOSE] ✓ Service disposed');
  }
}
