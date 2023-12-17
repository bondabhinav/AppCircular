class MarkedAttendanceResponse {
  List<GetAttendanceStud>? getAttendanceStud;

  MarkedAttendanceResponse({this.getAttendanceStud});

  MarkedAttendanceResponse.fromJson(Map<String, dynamic> json) {
    if (json['getAttendanceStud'] != null) {
      getAttendanceStud = <GetAttendanceStud>[];
      json['getAttendanceStud'].forEach((v) {
        getAttendanceStud!.add(GetAttendanceStud.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (getAttendanceStud != null) {
      data['getAttendanceStud'] = getAttendanceStud!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GetAttendanceStud {
  String? aTTDATE;

  GetAttendanceStud({this.aTTDATE});

  GetAttendanceStud.fromJson(Map<String, dynamic> json) {
    aTTDATE = json['ATT_DATE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ATT_DATE'] = aTTDATE;
    return data;
  }
}
