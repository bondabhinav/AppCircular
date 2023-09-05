import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'high_importance_channel_group',
          channelGroupName: 'Group 1',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
          (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
    final payload = receivedAction.payload ?? {};
      OpenFile.open(payload['path']);
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
    final int? progress,
    final channelId
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: channelId,
        channelKey: 'high_importance_channel',
        title: title,
        body: 'Tap to open the downloaded file.',
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
        progress: progress,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
        repeats: false,
        interval: interval,
        timeZone:
        await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      )
          : null,
    );
  }

  static cancelProgressNotification() async {
    await AwesomeNotifications().cancel(1);
  }
}


// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:open_file/open_file.dart';
//
// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   factory NotificationService() {
//     return _instance;
//   }
//
//   NotificationService._internal();
//
//   Future<void> initNotification() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('notification_icon');
//
//     DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
//         requestSoundPermission: true,
//         requestBadgePermission: true,
//         requestAlertPermission: true,
//         onDidReceiveLocalNotification: (id, title, body, payload) {});
//
//     InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );
//
//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) {
//         if (notificationResponse != null) {
//           _handleNotificationResponse(notificationResponse.payload!);
//         }
//       },
//       onDidReceiveBackgroundNotificationResponse: (NotificationResponse? notificationResponse) {
//         if (notificationResponse != null) {
//           _handleNotificationResponse(notificationResponse.payload!);
//         }
//       },
//     );
//   }
//
//   void _handleNotificationResponse(String payload) {
//     OpenFile.open(payload);
//   }
//
//   void showProgressNotification(int progress, String fileName) async {
//     AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       '1',
//       'Channel name',
//       importance: Importance.high,
//       priority: Priority.high,
//       showProgress: true,
//       maxProgress: 100,
//       progress: progress,
//       onlyAlertOnce: true,
//       styleInformation: BigTextStyleInformation('Downloading...',
//           contentTitle: '$progress% complete', summaryText: fileName),
//     );
//
//     NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await flutterLocalNotificationsPlugin.show(
//       1,
//       'Downloading...',
//       '$progress% complete',
//       platformChannelSpecifics,
//     );
//   }
//
//   Future<void> showNotification(String filePath, String fileName) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       '0',
//       'Channel name',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//
//     await flutterLocalNotificationsPlugin.show(
//       0,
//       fileName,
//       'Tap to open the downloaded file.',
//       platformChannelSpecifics,
//       payload: filePath,
//     );
//   }
//
//   void cancelProgressNotification() {
//     flutterLocalNotificationsPlugin.cancel(1);
//   }
// }
