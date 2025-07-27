import 'dart:async';
import 'dart:io';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  StreamSubscription? _configListener;
  Timer? _fallbackTimer;

  /// Initialize and start listening for app_update flag changes
  Future<void> initialize() async {
    try {
      // Set minimum fetch interval
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 1),
      ));

      // Set default values
      await _remoteConfig.setDefaults({
        'app_update': false,
      });

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

  /// Check if app should be killed
  void _checkAppUpdate() {
    try {
      final shouldKill = _remoteConfig.getBool('app_update');
      
      if (shouldKill) {
        _killApp();
      }
    } catch (e) {
      // Silent fail
    }
  }

  /// Kill the app
  void _killApp() {
    try {
      // Stop all timers and listeners
      _configListener?.cancel();
      _fallbackTimer?.cancel();
      
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else {
        exit(0);
      }
    } catch (e) {
      exit(0); // Force exit
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