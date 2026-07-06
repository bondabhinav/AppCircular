import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexischool/notification_count_handler.dart';
import 'package:flexischool/common/fcm_navigation_handler.dart';
import 'package:flexischool/common/fcm_pending_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import 'firebase_options.dart';

/// FCM Notification Behavior Across App States:
///
/// 1. FOREGROUND (App is open and active):
///    - Firebase SDK does NOT automatically show notifications
///    - We must manually create and show local notifications
///    - onMessage listener is triggered
///
/// 2. BACKGROUND (App is minimized but still in memory):
///    - Firebase SDK automatically shows notifications
///    - firebaseMessagingBackgroundHandler is triggered
///    - We should NOT create duplicate local notifications
///    - Only update badge count and process data
///
/// 3. TERMINATED/KILL STATE (App is completely closed):
///    - Firebase SDK automatically shows notifications
///    - firebaseMessagingBackgroundHandler is triggered
///    - We should NOT create duplicate local notifications
///    - getInitialMessage() captures the notification that launched the app
///
/// IMPORTANT: To prevent duplicate notifications in background/kill state,
/// the background handler should only process data and update badges,
/// but NOT show notifications.

const notificationChannel = "FlexiApp";
const notificationChannelId = "com.example.flexi";
const notificationChannelDescription = "Notification channel description";

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("=== FCM BACKGROUND MESSAGE RECEIVED ===");
  debugPrint("Message ID: ${message.messageId}");
  debugPrint("Message Type: ${message.messageType}");
  debugPrint("From: ${message.from}");
  debugPrint("Sent Time: ${message.sentTime}");
  debugPrint("TTL: ${message.ttl}");
  debugPrint("Data: ${message.data}");
  debugPrint("Notification Title: ${message.notification?.title}");
  debugPrint("Notification Body: ${message.notification?.body}");
  debugPrint("=== END BACKGROUND MESSAGE ===");

  // Only process if data is valid
  if (message.data.isNotEmpty && message.data.containsKey('count')) {
    try {
      // Only update badge count, don't show notification
      // Firebase SDK automatically shows the notification in kill/background state
      AppBadgePlus.updateBadge(int.parse(message.data['count'].toString()));
      // REMOVED: PushNotificationsManager()._showNotification(message);
      debugPrint("Badge updated to: ${message.data['count']}");
    } catch (e) {
      debugPrint("Error in background handler: $e");
    }
  } else {
    debugPrint("Skipping background message with invalid data");
  }
}

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => instance;

  static final PushNotificationsManager instance = PushNotificationsManager._();
  static const int _notificationId = 111;

  bool _initialized = false;
  bool _hasLaunched = false;

  static final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();
  String _fcmToken = "";

  Future<void> init() async {
    if (!_initialized) {
      _createNotificationChannel();
      if (Platform.isIOS) {
        var hasPermission = await _requestIOSPermissions();
        if (hasPermission!) {
          await _fcmInitialization();
          _initialized = true;
        } else {
          debugPrint(
            "You can provide permission by going into Settings later.",
          );
        }
      } else {
        // Request Android notification permissions
        await _requestAndroidPermissions();
        await _fcmInitialization();
        _initialized = true;
      }
      NotificationAppLaunchDetails? appLaunchDetails = (await localNotifications
          .getNotificationAppLaunchDetails());

      var initializationSettings = _getPlatformSettings();
      await localNotifications.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse? notificationResponse) {
              debugPrint("=== LOCAL NOTIFICATION RESPONSE ===");
              debugPrint("Notification ID: ${notificationResponse?.id}");
              debugPrint("Action ID: ${notificationResponse?.actionId}");
              debugPrint("Input: ${notificationResponse?.input}");
              debugPrint("Payload: ${notificationResponse?.payload}");
              debugPrint("=== END LOCAL NOTIFICATION RESPONSE ===");
              clickHandle(notificationResponse!.payload!);
              // handleNotificationTap(notificationResponse!);
            },
      );

      _hasLaunched = appLaunchDetails!.didNotificationLaunchApp;
      if (_hasLaunched) {
        if (appLaunchDetails.notificationResponse?.payload != null) {}
      }
    }
  }

  String get fcmToken => _fcmToken;

  static Future<dynamic> handleNotificationTap(
    NotificationResponse notificationResponse,
  ) async {
    debugPrint('_handleNotificationTap1 ==> ${notificationResponse.payload}');
    if (notificationResponse.payload != null) {
      clickHandle(notificationResponse.payload!);
    }
  }

  static void clickHandle(
    String payload, {
    bool fromBackgroundOrTerminate = false,
  }) {
    debugPrint("=== NOTIFICATION CLICK HANDLER ===");
    debugPrint("Payload: $payload");
    debugPrint("From Background/Terminate: $fromBackgroundOrTerminate");

    final encodedData = payload;
    // Split the payload into key-value pairs using commas and remove curly braces
    final keyValuePairs = encodedData.split(', ');
    // Create a map to store the parsed data
    final Map<String, dynamic> event = {};
    // Iterate through key-value pairs
    for (final pair in keyValuePairs) {
      // Split each pair into key and value
      final parts = pair.split(': ');

      // Ensure there are exactly 2 parts (key and value)
      if (parts.length == 2) {
        final key = parts[0].replaceAll('{', '').replaceAll('}', '');
        final value = parts[1].replaceAll('{', '').replaceAll('}', '');

        // Add the key-value pair to the map
        event[key] = value;
      }
    }

    debugPrint("Parsed Event Data: $event");

    // Use the new dynamic navigation handler
    FCMNavigationHandler.handleFCMNavigation(event);

    debugPrint("=== END NOTIFICATION CLICK HANDLER ===");
  }

  InitializationSettings _getPlatformSettings() {
    var initializationSettingsAndroid = const AndroidInitializationSettings(
      'mipmap/ic_launcher',
    );

    DarwinInitializationSettings initializationSettingsIOS =
        const DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          defaultPresentSound: true,
          defaultPresentBadge: true,
        );
    return InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
  }

  void _createNotificationChannel() async {
    var androidNotificationChannel = AndroidNotificationChannel(
      'high_importance_channel',
      notificationChannel,
      description: notificationChannelDescription,
      showBadge: true,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      ledColor: const Color.fromARGB(255, 255, 0, 0),
    );
    await localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future<void> _fcmInitialization() async {
    try {
      _fcmToken = (await FirebaseMessaging.instance.getToken())!;
      debugPrint("firebase token :- $_fcmToken");
      if (Platform.isIOS) {
        FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
          alert: true,
          sound: true,
          badge: true,
        );
      }

      // Handle notification that launched the app from kill state
      FirebaseMessaging.instance.getInitialMessage().then((
        RemoteMessage? message,
      ) {
        if (message != null && message.data.isNotEmpty) {
          debugPrint("=== FCM INITIAL MESSAGE (KILL STATE) ===");
          debugPrint("Message ID: ${message.messageId}");
          debugPrint("Data: ${message.data}");
          debugPrint("=== END INITIAL MESSAGE ===");

          // Store the FCM data directly (no need to parse string representation)
          final Map<String, dynamic> event = Map<String, dynamic>.from(
            message.data,
          );

          // Store for execution after app startup is complete
          FCMPendingNavigation.setPendingNavigation(event);
        } else {
          debugPrint("No initial message or empty data");
        }
      });

      FirebaseMessaging.instance.onTokenRefresh.listen((event) {
        _fcmToken = event;
        debugPrint("=== FCM TOKEN REFRESH ===");
        debugPrint("New Token: $_fcmToken");
        debugPrint("=== END TOKEN REFRESH ===");
      });

      FirebaseMessaging.onMessage.listen((event) async {
        debugPrint("=== FCM FOREGROUND MESSAGE RECEIVED ===");
        debugPrint("Message ID: ${event.messageId}");
        debugPrint("Message Type: ${event.messageType}");
        debugPrint("From: ${event.from}");
        debugPrint("Sent Time: ${event.sentTime}");
        debugPrint("TTL: ${event.ttl}");
        debugPrint("Data: ${event.data}");
        debugPrint("Notification Title: ${event.notification?.title}");
        debugPrint("Notification Body: ${event.notification?.body}");
        debugPrint(
          "Notification Android: ${event.notification?.android?.toMap()}",
        );
        debugPrint("Notification Apple: ${event.notification?.apple?.toMap()}");
        debugPrint("=== END FOREGROUND MESSAGE ===");

        try {
          // Only process notifications with valid data
          if (event.data.isNotEmpty && event.data.containsKey('count')) {
            // In foreground, we need to manually show the notification
            // because Firebase SDK doesn't automatically show notifications when app is in foreground
            _showNotification(event);
            NotificationCountHandler.updateNotificationCount(
              int.parse(event.data['count'].toString()),
            );
            AppBadgePlus.updateBadge(int.parse(event.data['count'].toString()));
          } else {
            debugPrint(
              "Skipping foreground notification with empty or invalid data",
            );
          }
        } catch (e) {
          debugPrint("Error handling foreground message: $e");
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        debugPrint("=== FCM MESSAGE OPENED APP ===");
        debugPrint("Message ID: ${event.messageId}");
        debugPrint("Message Type: ${event.messageType}");
        debugPrint("From: ${event.from}");
        debugPrint("Sent Time: ${event.sentTime}");
        debugPrint("TTL: ${event.ttl}");
        debugPrint("Data: ${event.data}");
        debugPrint("Notification Title: ${event.notification?.title}");
        debugPrint("Notification Body: ${event.notification?.body}");
        debugPrint("=== END MESSAGE OPENED APP ===");

        // Use dynamic navigation handler directly for background messages
        if (event.data.isNotEmpty) {
          FCMNavigationHandler.handleFCMNavigation(event.data);
        }
      });

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint("Error in FCM initialization: $e");
    }
  }

  Future<void> _showNotification(RemoteMessage remoteMessage) async {
    debugPrint("=== SHOWING LOCAL NOTIFICATION ===");
    debugPrint('Remote Message Data: ${remoteMessage.data.toString()}');

    // Check if data is valid
    if (remoteMessage.data.isEmpty) {
      debugPrint("Skipping notification with empty data");
      return;
    }

    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 200;
    vibrationPattern[2] = 200;
    vibrationPattern[3] = 200;

    final encodedData = remoteMessage.data.toString();
    final keyValuePairs = encodedData.split(', ');
    final Map<String, dynamic> event = {};
    for (final pair in keyValuePairs) {
      final parts = pair.split(': ');
      if (parts.length == 2) {
        final key = parts[0].replaceAll('{', '').replaceAll('}', '');
        final value = parts[1].replaceAll('{', '').replaceAll('}', '');
        event[key] = value;
      }
    }

    debugPrint("Parsed Notification Data: $event");

    var bigTextStyleInformation = BigTextStyleInformation(
      remoteMessage.notification?.body ?? 'Tap to open',
      contentTitle:
          remoteMessage.notification?.title ?? event['TYPE'].toString(),
    );

    await localNotifications.show(
      id: event.hashCode,
      title: remoteMessage.notification?.title ?? event['TYPE'].toString(),
      body: remoteMessage.notification?.body ?? 'Tap to open',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          notificationChannel,
          channelDescription: notificationChannelDescription,
          playSound: true,
          // Use default notification sound instead of custom sound
          // sound: const RawResourceAndroidNotificationSound('notification'),
          icon: 'mipmap/ic_launcher',
          vibrationPattern: vibrationPattern,
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: bigTextStyleInformation,
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          ongoing: false,
          autoCancel: true,
          showWhen: true,
          when: DateTime.now().millisecondsSinceEpoch,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          badgeNumber: int.tryParse(event['count']?.toString() ?? '0') ?? 0,
          presentBadge: true,
        ),
      ),
      payload: remoteMessage.data.toString(),
    );

    debugPrint("=== END SHOWING LOCAL NOTIFICATION ===");
  }

  Future<bool?> _requestIOSPermissions() async {
    var platformImplementation = localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    bool? permission = false;
    if (platformImplementation != null) {
      permission = (await platformImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      ));
    }
    return permission;
  }

  Future<void> _requestAndroidPermissions() async {
    // Request notification permission for Android 13+
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    // Don't automatically request system alert window permission
    // This will be handled by a separate method when user wants floating notifications

    // Request ignore battery optimization for better notification delivery
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  // Separate method to request overlay permission with user consent
  static Future<void> requestOverlayPermission() async {
    if (await Permission.systemAlertWindow.isDenied) {
      await Permission.systemAlertWindow.request();
    }
  }

  /// Debug method to check current app state and notification settings
  /// Call this when experiencing notification issues
  static Future<void> debugNotificationState() async {
    debugPrint("=== NOTIFICATION DEBUG INFO ===");

    // Check notification permissions
    final notificationStatus = await Permission.notification.status;
    debugPrint("Notification Permission: ${notificationStatus.name}");

    // Check if notifications are enabled
    final isEnabled = await Permission.notification.isGranted;
    debugPrint("Notifications Enabled: $isEnabled");

    // Check FCM token
    final token = await FirebaseMessaging.instance.getToken();
    debugPrint(
      "FCM Token: ${token != null ? 'Available (${token.substring(0, 20)}...)' : 'Not Available'}",
    );

    // Check notification settings
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    debugPrint("Authorization Status: ${settings.authorizationStatus.name}");
    debugPrint("Alert Setting: ${settings.alert.name}");
    debugPrint("Badge Setting: ${settings.badge.name}");
    debugPrint("Sound Setting: ${settings.sound.name}");

    // Platform specific checks
    if (Platform.isAndroid) {
      debugPrint("Platform: Android");
      final batteryOptimization =
          await Permission.ignoreBatteryOptimizations.status;
      debugPrint("Battery Optimization: ${batteryOptimization.name}");
    } else if (Platform.isIOS) {
      debugPrint("Platform: iOS");
    }

    debugPrint("=== END NOTIFICATION DEBUG INFO ===");
  }

  /// Test method to send a local notification
  /// Use this to verify local notifications are working correctly
  static Future<void> sendTestNotification() async {
    debugPrint("Sending test notification...");

    await localNotifications.show(
      id: _notificationId,
      title: "Test Notification",
      body:
          "This is a test notification to verify the system is working correctly",
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          notificationChannel,
          channelDescription: notificationChannelDescription,
          playSound: true,
          icon: 'mipmap/ic_launcher',
          vibrationPattern: Int64List(4),
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(
            "This is a test notification to verify the system is working correctly",
            contentTitle: "Test Notification",
          ),
          channelShowBadge: true,
          enableVibration: true,
          enableLights: true,
          ledColor: const Color.fromARGB(255, 255, 0, 0),
          ledOnMs: 1000,
          ledOffMs: 500,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.message,
          visibility: NotificationVisibility.public,
          ongoing: false,
          autoCancel: true,
          showWhen: true,
          when: DateTime.now().millisecondsSinceEpoch,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          badgeNumber: 1,
          presentBadge: true,
        ),
      ),
      payload: '{"type": "test", "count": "1"}',
    );

    debugPrint("Test notification sent");
  }
}
