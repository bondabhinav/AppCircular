import 'dart:async';

class NotificationCountHandler {
  static StreamController<int> notificationCount = StreamController<int>.broadcast();

  static void updateNotificationCount(int value) {
    notificationCount.add(value);
  }

  static void dispose() {
    notificationCount.close();
  }
}
