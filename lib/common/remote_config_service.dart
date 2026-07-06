import 'dart:async';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  StreamSubscription? _configListener;
  Timer? _fallbackTimer;

  /// Initialize and start listening for app_update flag changes.
  Future<void> initialize() async {
    try {
      // Set minimum fetch interval
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 5),
          minimumFetchInterval: const Duration(minutes: 1),
        ),
      );

      // Set default values
      await _remoteConfig.setDefaults({'app_update': false});

      // Fetch and activate config
      await _remoteConfig.fetchAndActivate();

      // Start listening for config changes
      _startListening();

      // Start fallback timer (check every 30 seconds)
      _startFallbackTimer();

      // Check immediately
      _checkAppUpdate();
    } catch (e) {
      // Silent fail
    }
  }

  /// Start listening for remote config changes
  void _startListening() {
    try {
      _configListener = _remoteConfig.onConfigUpdated.listen((event) {
        _checkAppUpdate();
      });
    } catch (e) {
      // Silent fail
    }
  }

  /// Start fallback timer to check periodically
  void _startFallbackTimer() {
    _fallbackTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkAppUpdate();
    });
  }

  /// Check if the remote app_update flag is enabled.
  void _checkAppUpdate() {
    try {
      final appUpdateEnabled = _remoteConfig.getBool('app_update');

      if (appUpdateEnabled) {
        debugPrint('Remote Config app_update is enabled; app remains open.');
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Stop listening
  void stop() {
    _configListener?.cancel();
    _fallbackTimer?.cancel();
    _configListener = null;
    _fallbackTimer = null;
  }

  /// Force refresh config (for testing)
  Future<void> forceRefresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
      _checkAppUpdate();
    } catch (e) {
      // Silent fail
    }
  }
}
