class NotificationCountResponse {
  List<NotificationCount>? notificationCount;

  NotificationCountResponse({this.notificationCount});

  NotificationCountResponse.fromJson(Map<String, dynamic> json) {
    if (json['NotificationCount'] != null) {
      notificationCount = <NotificationCount>[];
      json['NotificationCount'].forEach((v) {
        notificationCount!.add(NotificationCount.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notificationCount != null) {
      data['NotificationCount'] = notificationCount!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationCount {
  int? nOTIFICATIONCOUNT;

  NotificationCount({this.nOTIFICATIONCOUNT});

  NotificationCount.fromJson(Map<String, dynamic> json) {
    nOTIFICATIONCOUNT = json['NOTIFICATION_COUNT'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NOTIFICATION_COUNT'] = nOTIFICATIONCOUNT;
    return data;
  }
}
