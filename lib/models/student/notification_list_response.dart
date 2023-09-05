class NotificationListResponse {
  List<NotificationData>? notification;

  NotificationListResponse({this.notification});

  NotificationListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Notification'] != null) {
      notification = <NotificationData>[];
      json['Notification'].forEach((v) {
        notification!.add(NotificationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (notification != null) {
      data['Notification'] = notification!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationData {
  int? nOTIFICATIONID;
  String? nOTIFICATIONTYPE;
  String? aSSIGNMENTDETAILS;
  String? aSSIGNMENTDATE;
  String? nOTIFICATIONFLAG;
  int? aPPASSIGNMENTID;
  String? aPPCIRCULARDESCRIPTION;
  String? aPPCIRCULARDATE;
  int? aPPCIRCULARID;

  NotificationData(
      {this.nOTIFICATIONID,
      this.nOTIFICATIONTYPE,
      this.aSSIGNMENTDETAILS,
      this.aSSIGNMENTDATE,
      this.nOTIFICATIONFLAG,
      this.aPPASSIGNMENTID,
      this.aPPCIRCULARDESCRIPTION,
      this.aPPCIRCULARDATE,
      this.aPPCIRCULARID});

  NotificationData.fromJson(Map<String, dynamic> json) {
    nOTIFICATIONID = json['NOTIFICATION_ID'];
    nOTIFICATIONTYPE = json['NOTIFICATION_TYPE'];
    aSSIGNMENTDETAILS = json['ASSIGNMENT_DETAILS'];
    aSSIGNMENTDATE = json['ASSIGNMENT_DATE'];
    nOTIFICATIONFLAG = json['NOTIFICATION_FLAG'];
    aPPASSIGNMENTID = json['APP_ASSIGNMENT_ID'];
    aPPCIRCULARDESCRIPTION = json['APP_CIRCULAR_DESCRIPTION'];
    aPPCIRCULARDATE = json['APP_CIRCULAR_DATE'];
    aPPCIRCULARID = json['APP_CIRCULAR_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['NOTIFICATION_ID'] = nOTIFICATIONID;
    data['NOTIFICATION_TYPE'] = nOTIFICATIONTYPE;
    data['ASSIGNMENT_DETAILS'] = aSSIGNMENTDETAILS;
    data['ASSIGNMENT_DATE'] = aSSIGNMENTDATE;
    data['NOTIFICATION_FLAG'] = nOTIFICATIONFLAG;
    data['APP_ASSIGNMENT_ID'] = aPPASSIGNMENTID;
    data['APP_CIRCULAR_DESCRIPTION'] = aPPCIRCULARDESCRIPTION;
    data['APP_CIRCULAR_DATE'] = aPPCIRCULARDATE;
    data['APP_CIRCULAR_ID'] = aPPCIRCULARID;
    return data;
  }
}
