class GetClassResponse {
  List<CLASSandSECTION>? cLASSandSECTION;

  GetClassResponse({this.cLASSandSECTION});

  GetClassResponse.fromJson(Map<String, dynamic> json) {
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

  CLASSandSECTION({this.classId, this.cLASSDESC});

  CLASSandSECTION.fromJson(Map<String, dynamic> json) {
    classId = json['class_id'];
    cLASSDESC = json['CLASS_DESC'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['class_id'] = classId;
    data['CLASS_DESC'] = cLASSDESC;
    return data;
  }
}
