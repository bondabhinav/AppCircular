class StudentLoginResponse {
  List<Table1>? table1;

  StudentLoginResponse({this.table1});

  StudentLoginResponse.fromJson(Map<String, dynamic> json) {
    if (json['Table1'] != null) {
      table1 = <Table1>[];
      json['Table1'].forEach((v) {
        table1!.add(Table1.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (table1 != null) {
      data['Table1'] = table1!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Table1 {
  int? aDMSTUDENTID;
  int? fROMSESSION;
  int? tOSESSION;
  int? sESSIONID;
  String? cITYNAME;
  String? aDMNO;
  String? cLASSDESC;
  String? sECTIONDESC;
  String? sTUDPHOTO;

  Table1(
      {this.aDMSTUDENTID,
        this.fROMSESSION,
        this.tOSESSION,
        this.sESSIONID,
        this.cITYNAME,
        this.aDMNO,
        this.cLASSDESC,
        this.sTUDPHOTO,
        this.sECTIONDESC});

  Table1.fromJson(Map<String, dynamic> json) {
    aDMSTUDENTID = json['ADM_STUDENT_ID'];
    fROMSESSION = json['FROMSESSION'];
    tOSESSION = json['TOSESSION'];
    sESSIONID = json['SESSION_ID'];
    cITYNAME = json['CITY_NAME'];
    aDMNO = json['ADM_NO'];
    cLASSDESC = json['CLASS_DESC'];
    sECTIONDESC = json['SECTION_DESC'];
    sTUDPHOTO = json['STUD_PHOTO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ADM_STUDENT_ID'] = aDMSTUDENTID;
    data['FROMSESSION'] = fROMSESSION;
    data['TOSESSION'] = tOSESSION;
    data['SESSION_ID'] = sESSIONID;
    data['CITY_NAME'] = cITYNAME;
    data['ADM_NO'] = aDMNO;
    data['CLASS_DESC'] = cLASSDESC;
    data['SECTION_DESC'] = sECTIONDESC;
    data['STUD_PHOTO'] = sTUDPHOTO;
    return data;
  }
}
