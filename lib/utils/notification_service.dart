import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex_plus/open_filex_plus.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _permissionsRequested = false;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static Future<void> initializeNotification() async {
    await initializeForFileDownloads();
  }

  static Future<void> initializeForFileDownloads({
    bool requestPermissions = false,
  }) async {
    await _instance._initForFileDownloads();
    if (requestPermissions) {
      await _instance._requestPermissions();
    }
  }

  Future<void> _initForFileDownloads() async {
    if (_isInitialized) {
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: false,
          requestBadgePermission: false,
          requestAlertPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
            final payload = notificationResponse.payload;
            if (payload != null && payload.isNotEmpty) {
              _handleNotificationResponse(payload);
            }
          },
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
    );

    _isInitialized = true;
    await _handleLaunchFromNotification();
  }

  Future<void> _handleLaunchFromNotification() async {
    final launchDetails = await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
    final response = launchDetails?.notificationResponse;
    final payload = response?.payload;

    if ((launchDetails?.didNotificationLaunchApp ?? false) &&
        payload != null &&
        payload.isNotEmpty) {
      scheduleMicrotask(() => _handleNotificationResponse(payload));
    }
  }

  Future<void> _requestPermissions() async {
    if (_permissionsRequested) {
      return;
    }

    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: false, sound: true);
    }

    _permissionsRequested = true;
  }

  @pragma('vm:entry-point')
  static void backgroundNotificationHandler(NotificationResponse details) {
    final payload = details.payload;
    if (payload != null && payload.isNotEmpty) {
      _instance._handleNotificationResponse(payload);
    }
  }

  void _handleNotificationResponse(String payload) {
    debugPrint('NotificationService received payload: $payload');

    if (!payload.startsWith('/') && !payload.contains('storage')) {
      debugPrint('Non-file payload received, ignoring: $payload');
      return;
    }

    final file = File(payload);
    if (!file.existsSync()) {
      debugPrint('File does not exist at path: $payload');
      return;
    }

    debugPrint('Opening file at path: ${file.path}');
    OpenFilex.open(file.path);
  }

  static Future<void> showDownloadProgress({
    required int id,
    required String fileName,
    required int progress,
  }) async {
    if (!Platform.isAndroid) {
      return;
    }

    await initializeForFileDownloads(requestPermissions: true);
    final safeProgress = progress.clamp(0, 100).toInt();

    final androidDetails = AndroidNotificationDetails(
      'download_progress',
      'Download Progress',
      channelDescription: 'Shows file download progress',
      importance: Importance.low,
      priority: Priority.low,
      showProgress: true,
      maxProgress: 100,
      progress: safeProgress,
      onlyAlertOnce: true,
      ongoing: safeProgress < 100,
      autoCancel: false,
    );

    await _instance.flutterLocalNotificationsPlugin.show(
      id: id,
      title: 'Downloading $fileName',
      body: 'Progress: $safeProgress%',
      notificationDetails: NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> showDownloadComplete({
    required int id,
    required String fileName,
    required String filePath,
    String? body,
  }) async {
    await initializeForFileDownloads(requestPermissions: true);

    final androidDetails = AndroidNotificationDetails(
      'download_complete',
      'Downloads',
      channelDescription: 'Completed file downloads',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
      presentBadge: false,
    );

    await _instance.flutterLocalNotificationsPlugin.show(
      id: id,
      title: '$fileName downloaded',
      body: body ?? 'Tap to open.',
      notificationDetails: NotificationDetails(
        android: Platform.isAndroid ? androidDetails : null,
        iOS: Platform.isIOS ? iosDetails : null,
      ),
      payload: filePath,
    );
  }

  static Future<void> showDownloadFailed({
    required int id,
    required String fileName,
    String? body,
  }) async {
    await initializeForFileDownloads(requestPermissions: true);

    final androidDetails = AndroidNotificationDetails(
      'download_failed',
      'Download Errors',
      channelDescription: 'Failed file downloads',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
      presentBadge: false,
    );

    await _instance.flutterLocalNotificationsPlugin.show(
      id: id,
      title: 'Download failed',
      body: body ?? fileName,
      notificationDetails: NotificationDetails(
        android: Platform.isAndroid ? androidDetails : null,
        iOS: Platform.isIOS ? iosDetails : null,
      ),
    );
  }

  static Future<void> showProgressNotification(
    int progress,
    String fileName,
  ) async {
    await showDownloadProgress(id: 1, fileName: fileName, progress: progress);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? summary,
    Map<String, String>? payload,
    int? channelId,
    int? progress,
  }) async {
    final filePath = payload?['path'];
    if (progress != null) {
      await showDownloadProgress(
        id: channelId ?? 1,
        fileName: title,
        progress: progress,
      );
      return;
    }

    if (filePath != null && filePath.isNotEmpty) {
      await showDownloadComplete(
        id: channelId ?? 2,
        fileName: title,
        filePath: filePath,
        body: body.isEmpty ? 'Tap to open.' : body,
      );
      return;
    }

    await initializeForFileDownloads(requestPermissions: true);

    final androidDetails = AndroidNotificationDetails(
      channelId?.toString() ?? 'default',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.high,
      priority: Priority.high,
      autoCancel: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
      presentBadge: false,
    );

    await _instance.flutterLocalNotificationsPlugin.show(
      id: channelId ?? 0,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: Platform.isAndroid ? androidDetails : null,
        iOS: Platform.isIOS ? iosDetails : null,
      ),
    );
  }

  static Future<void> cancelProgressNotification({int id = 1}) async {
    await initializeForFileDownloads();
    await _instance.flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
