class TeacherSessionResponse {
  List<SessionDD>? sessionDD;

  TeacherSessionResponse({this.sessionDD});

  TeacherSessionResponse.fromJson(Map<String, dynamic> json) {
    if (json['SessionDD'] != null) {
      sessionDD = <SessionDD>[];
      json['SessionDD'].forEach((v) {
        sessionDD!.add(SessionDD.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (sessionDD != null) {
      data['SessionDD'] = sessionDD!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SessionDD {
  int? sESSIONID;
  String? sTARTDATE;
  String? eNDDATE;
  String? aCTIVE;
  int? sCHOOLID;
  String? sCHOOLNAME;

  SessionDD(
      {this.sESSIONID,
        this.sTARTDATE,
        this.eNDDATE,
        this.aCTIVE,
        this.sCHOOLID,
        this.sCHOOLNAME});

  SessionDD.fromJson(Map<String, dynamic> json) {
    sESSIONID = json['SESSION_ID'];
    sTARTDATE = json['START_DATE'];
    eNDDATE = json['END_DATE'];
    aCTIVE = json['ACTIVE'];
    sCHOOLID = json['SCHOOL_ID'];
    sCHOOLNAME = json['SCHOOL_NAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SESSION_ID'] = sESSIONID;
    data['START_DATE'] = sTARTDATE;
    data['END_DATE'] = eNDDATE;
    data['ACTIVE'] = aCTIVE;
    data['SCHOOL_ID'] = sCHOOLID;
    data['SCHOOL_NAME'] = sCHOOLNAME;
    return data;
  }
}
