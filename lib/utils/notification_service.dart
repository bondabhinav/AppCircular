import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_filex/open_filex.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  static Future<void> initializeNotification() async {
    await NotificationService().initNotification();
  }
  
  // Initialize for file downloads only (not FCM)
  static Future<void> initializeForFileDownloads() async {
    await NotificationService()._initForFileDownloads();
  }

  Future<void> _initForFileDownloads() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) {
        if (notificationResponse != null && notificationResponse.payload != null) {
          _handleNotificationResponse(notificationResponse.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
    );
  }

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) {
        if (notificationResponse != null && notificationResponse.payload != null) {
          _handleNotificationResponse(notificationResponse.payload!);
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
    );
  }

  @pragma('vm:entry-point')
  static void backgroundNotificationHandler(NotificationResponse details) {
    if (details.payload != null) {
      _instance._handleNotificationResponse(details.payload!);
    }
  }

  void _handleNotificationResponse(String payload) {
    debugPrint('NotificationService received payload: $payload');
    
    // Only handle file paths, not FCM notification data
    if (payload.startsWith('/') || payload.contains('storage')) {
      final file = File(payload);
      if (file.existsSync()) {
        debugPrint('Opening file at path: ${file.path}');
        OpenFilex.open(file.path);
      } else {
        debugPrint('File does not exist at path: $payload');
      }
    } else {
      debugPrint('Non-file payload received, ignoring: $payload');
    }
  }

  static Future<void> showProgressNotification(int progress, String fileName) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      '1',
      'Download Progress',
      channelDescription: 'Shows download progress',
      importance: Importance.high,
      priority: Priority.high,
      showProgress: true,
      maxProgress: 100,
      progress: progress,
      onlyAlertOnce: true,
      styleInformation: BigTextStyleInformation('Downloading...',
          contentTitle: '$progress% complete', summaryText: fileName),
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _instance.flutterLocalNotificationsPlugin.show(
      1,
      'Downloading...',
      '$progress% complete',
      platformChannelSpecifics,
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? summary,
    Map<String, String>? payload,
    int? channelId,
    int? progress,
  }) async {
    // Initialize for file downloads if not already initialized
    await NotificationService.initializeForFileDownloads();
    String? filePath = payload?['path'];
    
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId?.toString() ?? '0',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showProgress: progress != null,
      progress: progress ?? 0,
      maxProgress: 100,
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _instance.flutterLocalNotificationsPlugin.show(
      channelId ?? 0,
      title,
      body,
      platformChannelSpecifics,
      payload: filePath,
    );
  }

  static Future<void> cancelProgressNotification() async {
    await _instance.flutterLocalNotificationsPlugin.cancel(1);
  }
}
