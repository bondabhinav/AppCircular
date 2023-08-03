class StudentCircularListResponse {
  List<Classlist>? classlist;

  StudentCircularListResponse({this.classlist});

  StudentCircularListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Classlist'] != null) {
      classlist = <Classlist>[];
      json['Classlist'].forEach((v) {
        classlist!.add(Classlist.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (classlist != null) {
      data['Classlist'] = classlist!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Classlist {
  int? aPPCIRCULARID;
  String? aPPCIRCULARDATE;
  String? aPPCIRCULARDESCRIPTION;
  String? aPPCIRCULARSUBJECT;
  String? fLAG;
  List<LstCircularFile>? lstCircularFile;

  Classlist(
      {this.aPPCIRCULARID,
        this.aPPCIRCULARDATE,
        this.aPPCIRCULARDESCRIPTION,
        this.aPPCIRCULARSUBJECT,
        this.fLAG,
        this.lstCircularFile});

  Classlist.fromJson(Map<String, dynamic> json) {
    aPPCIRCULARID = json['APP_CIRCULAR_ID'];
    aPPCIRCULARDATE = json['APP_CIRCULAR_DATE'];
    aPPCIRCULARDESCRIPTION = json['APP_CIRCULAR_DESCRIPTION'];
    aPPCIRCULARSUBJECT = json['APP_CIRCULAR_SUBJECT'];
    fLAG = json['FLAG'];
    if (json['lstCircularFile'] != null) {
      lstCircularFile = <LstCircularFile>[];
      json['lstCircularFile'].forEach((v) {
        lstCircularFile!.add(LstCircularFile.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['APP_CIRCULAR_ID'] = aPPCIRCULARID;
    data['APP_CIRCULAR_DATE'] = aPPCIRCULARDATE;
    data['APP_CIRCULAR_DESCRIPTION'] = aPPCIRCULARDESCRIPTION;
    data['APP_CIRCULAR_SUBJECT'] = aPPCIRCULARSUBJECT;
    data['FLAG'] = fLAG;
    if (lstCircularFile != null) {
      data['lstCircularFile'] =
          lstCircularFile!.map((v) => v.toJson()).toList();
    }
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
