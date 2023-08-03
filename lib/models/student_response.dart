class StudentResponse {
  List<ADMSTUDREGISTRATION>? aDMSTUDREGISTRATION;

  StudentResponse({this.aDMSTUDREGISTRATION});

  StudentResponse.fromJson(Map<String, dynamic> json) {
    if (json['ADM_STUD_REGISTRATION'] != null) {
      aDMSTUDREGISTRATION = <ADMSTUDREGISTRATION>[];
      json['ADM_STUD_REGISTRATION'].forEach((v) {
        aDMSTUDREGISTRATION!.add(ADMSTUDREGISTRATION.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (aDMSTUDREGISTRATION != null) {
      data['ADM_STUD_REGISTRATION'] =
          aDMSTUDREGISTRATION!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ADMSTUDREGISTRATION {
  String? aDMDATE;
  String? fIRSTNAME;
  String? aDMNO;
  int? aDMSTUDENTID;
  String? cLASSDESC;
  String? sECTIONDESC;
  String? fATHER;
  String? mOBILENO;
  int? cURRENTCLASSID;
  String attendance = 'Present';

  ADMSTUDREGISTRATION(
      {this.aDMDATE,
      this.fIRSTNAME,
      this.aDMNO,
      this.aDMSTUDENTID,
      this.cLASSDESC,
      this.sECTIONDESC,
      this.fATHER,
        this.attendance = 'Present',
      this.mOBILENO,
      this.cURRENTCLASSID});

  ADMSTUDREGISTRATION.fromJson(Map<String, dynamic> json) {
    aDMDATE = json['ADM_DATE'];
    fIRSTNAME = json['FIRST_NAME'];
    aDMNO = json['ADM_NO'];
    aDMSTUDENTID = json['ADM_STUDENT_ID'];
    cLASSDESC = json['CLASS_DESC'];
    sECTIONDESC = json['SECTION_DESC'];
    fATHER = json['FATHER'];
    mOBILENO = json['MOBILE_NO'];
    cURRENTCLASSID = json['CURRENT_CLASS_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ADM_DATE'] = aDMDATE;
    data['FIRST_NAME'] = fIRSTNAME;
    data['ADM_NO'] = aDMNO;
    data['ADM_STUDENT_ID'] = aDMSTUDENTID;
    data['CLASS_DESC'] = cLASSDESC;
    data['SECTION_DESC'] = sECTIONDESC;
    data['FATHER'] = fATHER;
    data['MOBILE_NO'] = mOBILENO;
    data['CURRENT_CLASS_ID'] = cURRENTCLASSID;
    return data;
  }
}
