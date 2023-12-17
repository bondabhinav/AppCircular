class OverAllAttendanceResponse {
  dynamic attendance;

  OverAllAttendanceResponse({this.attendance});

  OverAllAttendanceResponse.fromJson(Map<String, dynamic> json) {
    attendance = json['Attendance%'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Attendance%'] = attendance;
    return data;
  }
}
