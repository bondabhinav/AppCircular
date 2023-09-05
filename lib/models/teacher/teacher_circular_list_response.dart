class TeacherCircularListResponse {
  List<Classlist>? classlist;

  TeacherCircularListResponse({this.classlist});

  TeacherCircularListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Classlist'] != null) {
      classlist = <Classlist>[];
      json['Classlist'].forEach((v) {
        classlist!.add(new Classlist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.classlist != null) {
      data['Classlist'] = this.classlist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Classlist {
  int? aPPCIRCULARID;
  String? aPPCIRCULARDATE;
  String? aPPCIRCULARDESCRIPTION;
  String? aPPCIRCULARSUBJECT;
  dynamic fLAG;
  String? aCTIVE;
  List<LstCircularFile>? lstCircularFile;
  List<LstCircularSection>? lstCircularSection;
  String? cLASSDESC;

  Classlist(
      {this.aPPCIRCULARID,
        this.aPPCIRCULARDATE,
        this.aPPCIRCULARDESCRIPTION,
        this.aPPCIRCULARSUBJECT,
        this.fLAG,
        this.aCTIVE,
        this.lstCircularFile,
        this.lstCircularSection,
        this.cLASSDESC});

  Classlist.fromJson(Map<String, dynamic> json) {
    aPPCIRCULARID = json['APP_CIRCULAR_ID'];
    aPPCIRCULARDATE = json['APP_CIRCULAR_DATE'];
    aPPCIRCULARDESCRIPTION = json['APP_CIRCULAR_DESCRIPTION'];
    aPPCIRCULARSUBJECT = json['APP_CIRCULAR_SUBJECT'];
    fLAG = json['FLAG'];
    aCTIVE = json['ACTIVE'];
    if (json['lstCircularFile'] != null) {
      lstCircularFile = <LstCircularFile>[];
      json['lstCircularFile'].forEach((v) {
        lstCircularFile!.add(new LstCircularFile.fromJson(v));
      });
    }
    if (json['lstCircularSection'] != null) {
      lstCircularSection = <LstCircularSection>[];
      json['lstCircularSection'].forEach((v) {
        lstCircularSection!.add(new LstCircularSection.fromJson(v));
      });
    }
    cLASSDESC = json['CLASS_DESC'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['APP_CIRCULAR_ID'] = this.aPPCIRCULARID;
    data['APP_CIRCULAR_DATE'] = this.aPPCIRCULARDATE;
    data['APP_CIRCULAR_DESCRIPTION'] = this.aPPCIRCULARDESCRIPTION;
    data['APP_CIRCULAR_SUBJECT'] = this.aPPCIRCULARSUBJECT;
    data['FLAG'] = this.fLAG;
    data['ACTIVE'] = this.aCTIVE;
    if (this.lstCircularFile != null) {
      data['lstCircularFile'] =
          this.lstCircularFile!.map((v) => v.toJson()).toList();
    }
    if (this.lstCircularSection != null) {
      data['lstCircularSection'] =
          this.lstCircularSection!.map((v) => v.toJson()).toList();
    }
    data['CLASS_DESC'] = this.cLASSDESC;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FILE_NAME'] = this.fILENAME;
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SECTION_DESC'] = this.sECTIONDESC;
    return data;
  }
}
