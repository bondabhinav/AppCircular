class AssignmentDetailResponse {
  List<LstAssignment>? lstAssignment;

  AssignmentDetailResponse({this.lstAssignment});

  AssignmentDetailResponse.fromJson(Map<String, dynamic> json) {
    if (json['lstAssignment'] != null) {
      lstAssignment = <LstAssignment>[];
      json['lstAssignment'].forEach((v) {
        lstAssignment!.add(LstAssignment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lstAssignment != null) {
      data['lstAssignment'] =
          lstAssignment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LstAssignment {
  int? aPPASSIGNMENTID;
  String? aSSIGNMENTDETAILS;
  String? aSSIGNMENTDATE;
  dynamic sUBJECTNAME;
  String? fLAG;
  String? aCTIVE;
  List<LstCircularFile>? lstCircularFile;
  dynamic lstCircularSection;
  dynamic cLASSDESC;

  LstAssignment(
      {this.aPPASSIGNMENTID,
        this.aSSIGNMENTDETAILS,
        this.aSSIGNMENTDATE,
        this.sUBJECTNAME,
        this.fLAG,
        this.aCTIVE,
        this.lstCircularFile,
        this.lstCircularSection,
        this.cLASSDESC});

  LstAssignment.fromJson(Map<String, dynamic> json) {
    aPPASSIGNMENTID = json['APP_ASSIGNMENT_ID'];
    aSSIGNMENTDETAILS = json['ASSIGNMENT_DETAILS'];
    aSSIGNMENTDATE = json['ASSIGNMENT_DATE'];
    sUBJECTNAME = json['SUBJECT_NAME'];
    fLAG = json['FLAG'];
    aCTIVE = json['ACTIVE'];
    if (json['lstCircularFile'] != null) {
      lstCircularFile = <LstCircularFile>[];
      json['lstCircularFile'].forEach((v) {
        lstCircularFile!.add(LstCircularFile.fromJson(v));
      });
    }
    lstCircularSection = json['lstCircularSection'];
    cLASSDESC = json['CLASS_DESC'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['APP_ASSIGNMENT_ID'] = aPPASSIGNMENTID;
    data['ASSIGNMENT_DETAILS'] = aSSIGNMENTDETAILS;
    data['ASSIGNMENT_DATE'] = aSSIGNMENTDATE;
    data['SUBJECT_NAME'] = sUBJECTNAME;
    data['FLAG'] = fLAG;
    data['ACTIVE'] = aCTIVE;
    if (lstCircularFile != null) {
      data['lstCircularFile'] =
          lstCircularFile!.map((v) => v.toJson()).toList();
    }
    data['lstCircularSection'] = lstCircularSection;
    data['CLASS_DESC'] = cLASSDESC;
    return data;
  }
}

class LstCircularFile {
  String? fILENAME;

  LstCircularFile({this.fILENAME});

  LstCircularFile.fromJson(Map<String, dynamic> json) {
    fILENAME = json['FILE_NAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FILE_NAME'] = fILENAME;
    return data;
  }
}
