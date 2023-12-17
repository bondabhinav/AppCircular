class GetMarkedStudentResponse {
  List<Lststud>? lststud;

  GetMarkedStudentResponse({this.lststud});

  GetMarkedStudentResponse.fromJson(Map<String, dynamic> json) {
    if (json['lststud'] != null) {
      lststud = <Lststud>[];
      json['lststud'].forEach((v) {
        lststud!.add(Lststud.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lststud != null) {
      data['lststud'] = lststud!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lststud {
  String? sTUDNAME;
  String? pRESENT;
  String? cLASSDESC;
  String? sECTIONDESC;
  int? sTUDATTENDANCEDETID;

  Lststud(
      {this.sTUDNAME,
        this.pRESENT,
        this.cLASSDESC,
        this.sECTIONDESC,
        this.sTUDATTENDANCEDETID});

  Lststud.fromJson(Map<String, dynamic> json) {
    sTUDNAME = json['STUDNAME'];
    pRESENT = json['PRESENT'];
    cLASSDESC = json['CLASS_DESC'];
    sECTIONDESC = json['SECTION_DESC'];
    sTUDATTENDANCEDETID = json['STUD_ATTENDANCE_DET_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['STUDNAME'] = sTUDNAME;
    data['PRESENT'] = pRESENT;
    data['CLASS_DESC'] = cLASSDESC;
    data['SECTION_DESC'] = sECTIONDESC;
    data['STUD_ATTENDANCE_DET_ID'] = sTUDATTENDANCEDETID;
    return data;
  }
}
