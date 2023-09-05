class StudentRequest {
  String? sESSIONID;
  List<LstClass>? lstClass;
  List<LstSection>? lstSection;

  StudentRequest({this.sESSIONID, this.lstClass, this.lstSection});

  StudentRequest.fromJson(Map<String, dynamic> json) {
    sESSIONID = json['SESSION_ID'];
    if (json['lstClass'] != null) {
      lstClass = <LstClass>[];
      json['lstClass'].forEach((v) {
        lstClass!.add(LstClass.fromJson(v));
      });
    }
    if (json['lstSection'] != null) {
      lstSection = <LstSection>[];
      json['lstSection'].forEach((v) {
        lstSection!.add(LstSection.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SESSION_ID'] = sESSIONID;
    if (lstClass != null) {
      data['lstClass'] = lstClass!.map((v) => v.toJson()).toList();
    }
    if (lstSection != null) {
      data['lstSection'] = lstSection!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LstClass {
  String? cLASSID;

  LstClass({this.cLASSID});

  LstClass.fromJson(Map<String, dynamic> json) {
    cLASSID = json['CLASS_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CLASS_ID'] = cLASSID;
    return data;
  }
}

class LstSection {
  String? cURRENTSECTIONID;

  LstSection({this.cURRENTSECTIONID});

  LstSection.fromJson(Map<String, dynamic> json) {
    cURRENTSECTIONID = json['CURRENT_SECTION_ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CURRENT_SECTION_ID'] = cURRENTSECTIONID;
    return data;
  }
}
