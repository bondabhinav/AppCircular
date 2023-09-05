class SectionClassResponse {
  List<CLASSandSECTION>? cLASSandSECTION;

  SectionClassResponse({this.cLASSandSECTION});

  SectionClassResponse.fromJson(Map<String, dynamic> json) {
    if (json['CLASSandSECTION'] != null) {
      cLASSandSECTION = <CLASSandSECTION>[];
      json['CLASSandSECTION'].forEach((v) {
        cLASSandSECTION!.add(CLASSandSECTION.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cLASSandSECTION != null) {
      data['CLASSandSECTION'] =
          cLASSandSECTION!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CLASSandSECTION {
  int? classId;
  String? cLASSDESC;
  int? sECTIONID;
  String? sECTIONDESC;
  String? iSCLASSTEACHER;

  CLASSandSECTION(
      {this.classId,
      this.cLASSDESC,
      this.sECTIONID,
      this.sECTIONDESC,
      this.iSCLASSTEACHER});

  CLASSandSECTION.fromJson(Map<String, dynamic> json) {
    classId = json['class_id'];
    cLASSDESC = json['CLASS_DESC'];
    sECTIONID = json['SECTION_ID'];
    sECTIONDESC = json['SECTION_DESC'];
    iSCLASSTEACHER = json['IS_CLASST_EACHER'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class_id'] = classId;
    data['CLASS_DESC'] = cLASSDESC;
    data['SECTION_ID'] = sECTIONID;
    data['SECTION_DESC'] = sECTIONDESC;
    data['IS_CLASST_EACHER'] = iSCLASSTEACHER;
    return data;
  }
}
