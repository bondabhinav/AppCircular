class StudentLoginResponse {
  List<Table1>? table1;

  StudentLoginResponse({this.table1});

  StudentLoginResponse.fromJson(Map<String, dynamic> json) {
    if (json['Table1'] != null) {
      table1 = <Table1>[];
      json['Table1'].forEach((v) {
        table1!.add(new Table1.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.table1 != null) {
      data['Table1'] = this.table1!.map((v) => v.toJson()).toList();
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

  Table1(
      {this.aDMSTUDENTID,
        this.fROMSESSION,
        this.tOSESSION,
        this.sESSIONID,
        this.cITYNAME,
        this.aDMNO,
        this.cLASSDESC,
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ADM_STUDENT_ID'] = this.aDMSTUDENTID;
    data['FROMSESSION'] = this.fROMSESSION;
    data['TOSESSION'] = this.tOSESSION;
    data['SESSION_ID'] = this.sESSIONID;
    data['CITY_NAME'] = this.cITYNAME;
    data['ADM_NO'] = this.aDMNO;
    data['CLASS_DESC'] = this.cLASSDESC;
    data['SECTION_DESC'] = this.sECTIONDESC;
    return data;
  }
}
