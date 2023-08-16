class TeacherAssignmentListModel {
  List<LstAssignment>? lstAssignment;

  TeacherAssignmentListModel({this.lstAssignment});

  TeacherAssignmentListModel.fromJson(Map<String, dynamic> json) {
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
  String? sUBJECTNAME;
  dynamic fLAG;
  String? aCTIVE;
  List<LstCircularFile>? lstCircularFile;
  List<LstCircularSection>? lstCircularSection;
  String? cLASSDESC;
  String? eNDDATE;
  String? sTARTDATE;

  LstAssignment(
      {this.aPPASSIGNMENTID,
        this.aSSIGNMENTDETAILS,
        this.aSSIGNMENTDATE,
        this.sUBJECTNAME,
        this.fLAG,
        this.aCTIVE,
        this.lstCircularFile,
        this.lstCircularSection,
        this.cLASSDESC,
        this.eNDDATE,
        this.sTARTDATE});

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
    if (json['lstCircularSection'] != null) {
      lstCircularSection = <LstCircularSection>[];
      json['lstCircularSection'].forEach((v) {
        lstCircularSection!.add(LstCircularSection.fromJson(v));
      });
    }
    cLASSDESC = json['CLASS_DESC'];
    eNDDATE = json['END_DATE'];
    sTARTDATE = json['START_DATE'];
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
    if (lstCircularSection != null) {
      data['lstCircularSection'] =
          lstCircularSection!.map((v) => v.toJson()).toList();
    }
    data['CLASS_DESC'] = cLASSDESC;
    data['END_DATE'] = eNDDATE;
    data['START_DATE'] = sTARTDATE;
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

class LstCircularSection {
  String? sECTIONDESC;

  LstCircularSection({this.sECTIONDESC});

  LstCircularSection.fromJson(Map<String, dynamic> json) {
    sECTIONDESC = json['SECTION_DESC'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SECTION_DESC'] = sECTIONDESC;
    return data;
  }
}
