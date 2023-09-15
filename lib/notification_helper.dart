import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexischool/common/auth_middleware.dart';
import 'package:flexischool/notification_count_handler.dart';
import 'package:flexischool/screens/assignment_detail_screen.dart';
import 'package:flexischool/screens/student/student_circular_detail_screen.dart';
import 'package:flexischool/screens/student/student_notification_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const notificationChannel = "FlexiApp";
const notificationChannelId = "com.example.flexi";
const notificationChannelDescription = "Notification channel description";

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message");
  debugPrint("onBackgroundMessage: ${message.data}");
  FlutterAppBadger.updateBadgeCount(int.parse(message.data['count'].toString()));
  PushNotificationsManager()._showNotification(message);
}

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => instance;

  static final PushNotificationsManager instance = PushNotificationsManager._();
  static const int _notificationId = 111;

  bool _initialized = false;
  bool _hasLaunched = false;

  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  String _fcmToken = "test";

  Future<void> init() async {
    if (!_initialized) {
      _createNotificationChannel();
      if (Platform.isIOS) {
        var hasPermission = await _requestIOSPermissions();
        if (hasPermission!) {
          await _fcmInitialization();
          _initialized = true;
        } else {
          debugPrint("You can provide permission by going into Settings later.");
        }
      } else {
        await _fcmInitialization();
        _initialized = true;
      }
      NotificationAppLaunchDetails? appLaunchDetails =
          (await _localNotifications.getNotificationAppLaunchDetails());

      var initializationSettings = _getPlatformSettings();
      await _localNotifications.initialize(initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) {
        clickHandle(notificationResponse!.payload!);
       // handleNotificationTap(notificationResponse!);
      });

      _hasLaunched = appLaunchDetails!.didNotificationLaunchApp;
      if (_hasLaunched) {
        if (appLaunchDetails.notificationResponse?.payload != null) {}
      }
    }
  }

  String get fcmToken => _fcmToken;

  static Future<dynamic> handleNotificationTap(NotificationResponse notificationResponse) async {
    debugPrint('_handleNotificationTap1 ==> ${notificationResponse.payload}');
    if (notificationResponse.payload != null) {
      clickHandle(notificationResponse.payload!);
    }
  }

  static clickHandle(String payload) {
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

    if (event['TYPE'].toString() == 'ASSIGNMENT') {
      Navigator.push(
          AuthMiddleware.navigatorKey.currentContext!,
          MaterialPageRoute(
              builder: (context) => AssignmentDetailScreen(
                  sessionId: int.parse(event['SESSION_ID'].toString()),
                  assignmentId: int.parse(event['APP_ASSIGNMENT_ID'].toString()))));
    } else if (event['TYPE'].toString() == 'CIRCULAR') {
      Navigator.push(
          AuthMiddleware.navigatorKey.currentContext!,
          MaterialPageRoute(
              builder: (context) => StudentCircularDetailScreen(
                  sessionId: int.parse(event['SESSION_ID'].toString()),
                  id: int.parse(event['APP_CIRCULAR_ID'].toString()))));
    } else if (event['TYPE'].toString() == 'ATTENDANCE') {
      Navigator.push(AuthMiddleware.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => const StudentNotificationScreen()));
    }
  }

  _getPlatformSettings() {
    var initializationSettingsAndroid = const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
        onDidReceiveLocalNotification: (id, title, body, payload) {});
    return InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  }

  void _createNotificationChannel() async {
    var androidNotificationChannel = const AndroidNotificationChannel(
      notificationChannelId,
      notificationChannel,
      showBadge: true,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
  }

  Future _fcmInitialization() async {
    try {
      _fcmToken = (await FirebaseMessaging.instance.getToken())!;
      debugPrint("firebase token :- $_fcmToken");
      if (Platform.isIOS) {
        FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(alert: true, sound: true, badge: true);
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((event) {
        _fcmToken = event;
        debugPrint("firebase token :- $_fcmToken");
      });
      FirebaseMessaging.onMessage.listen((event) {
        try {
          _showNotification(event);
          NotificationCountHandler.updateNotificationCount(int.parse(event.data['count'].toString()));
          FlutterAppBadger.updateBadgeCount(int.parse(event.data['count'].toString()));
        } on Exception {
          debugPrint(Exception('Some error').toString());
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((event) {
        clickHandle(event.data.toString());
      });
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _showNotification(RemoteMessage remoteMessage) async {
    debugPrint('payload-====> ${remoteMessage.data.toString()}');
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

    var bigTextStyleInformation = BigTextStyleInformation(
        event['TYPE'].toString() == 'ASSIGNMENT'
            ? 'Tap to open assignment'
            : event['TYPE'].toString() == 'CIRCULAR'.toString()
                ? 'Tap to open circular'
                :event['TYPE'].toString() == 'ATTENDANCE'? 'Your child is absent today':'Tap to open',
        contentTitle: event['TYPE'].toString() == 'ASSIGNMENT'
            ? 'Assignment'
            : event['TYPE'].toString() == 'CIRCULAR'
                ? 'Circular'
                : event['TYPE'].toString() == 'ATTENDANCE'?'Attendance':'New Notification');

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _notificationId.toString(),
      notificationChannel,
      playSound: true,
      icon: 'mipmap/ic_launcher',
      vibrationPattern: vibrationPattern,
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: bigTextStyleInformation,
      channelShowBadge: true,
      enableVibration: true,
    );
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
      badgeNumber: 0,
      presentBadge: true,
    );
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await _localNotifications.show(
        0,
        event['TYPE'].toString() == 'ASSIGNMENT'
            ? 'Assignment'
            : event['TYPE'].toString() == 'CIRCULAR'
                ? 'Circular'
                : 'Attendance',
        event['TYPE'].toString() == 'ASSIGNMENT'
            ? 'Tap to open assignment'
            : event['TYPE'].toString() == 'CIRCULAR'
                ? 'Tap to open circular'
                :event['TYPE'].toString() == 'ATTENDANCE'? 'Your child is absent today':'Tap to open',
        platformChannelSpecifics,
        payload: remoteMessage.data.toString());
  }

  Future<bool?> _requestIOSPermissions() async {
    var platformImplementation =
        _localNotifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    bool? permission = false;
    if (platformImplementation != null) {
      permission = (await platformImplementation.requestPermissions(alert: true, badge: true, sound: true));
    }
    return permission;
  }
}
