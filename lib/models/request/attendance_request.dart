class AttendanceDataRequest {
  int sessionId;
  String attDate;
  String entryDate;
  String entryUserId;
  String lastUpdateDate;
  String updateUserId;
  int classId;
  int sectionId;
  List<AttendanceDetail> lstAttendanceDetail;

  AttendanceDataRequest({
    required this.sessionId,
    required this.attDate,
    required this.entryDate,
    required this.entryUserId,
    required this.lastUpdateDate,
    required this.updateUserId,
    required this.classId,
    required this.sectionId,
    required this.lstAttendanceDetail,
  });

  factory AttendanceDataRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceDataRequest(
      sessionId: json['SESSION_ID'],
      attDate: json['ATT_DATE'],
      entryDate: json['ENTRY_DATE'],
      entryUserId: json['ENTRY_USER_ID'],
      lastUpdateDate: json['LAST_UPDATE_DATE'],
      updateUserId: json['UPDATE_USER_ID'],
      classId: json['CLASS_ID'],
      sectionId: json['SECTION_ID'],
      lstAttendanceDetail: List<AttendanceDetail>.from(
        json['lstAttendanceDetail']
            .map((detail) => AttendanceDetail.fromJson(detail)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SESSION_ID': sessionId,
      'ATT_DATE': attDate,
      'ENTRY_DATE': entryDate,
      'ENTRY_USER_ID': entryUserId,
      'LAST_UPDATE_DATE': lastUpdateDate,
      'UPDATE_USER_ID': updateUserId,
      'CLASS_ID': classId,
      'SECTION_ID': sectionId,
      'lstAttendanceDetail': lstAttendanceDetail.map((detail) => detail.toJson()).toList(),
    };
  }
}

class AttendanceDetail {
  String present;
  int studentId;

  AttendanceDetail({
    required this.present,
    required this.studentId,
  });

  factory AttendanceDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceDetail(
      present: json['PRESENT'],
      studentId: json['STUDENT_ID'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PRESENT': present,
      'STUDENT_ID': studentId,
    };
  }
}
