class GetSectionResponse {
  List<CLASSandSECTION>? cLASSandSECTION;

  GetSectionResponse({this.cLASSandSECTION});

  GetSectionResponse.fromJson(Map<String, dynamic> json) {
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
  int? sECTIONID;
  String? sECTIONDESC;
  String? iSCLASSTEACHER;

  CLASSandSECTION({this.sECTIONID, this.sECTIONDESC, this.iSCLASSTEACHER});

  CLASSandSECTION.fromJson(Map<String, dynamic> json) {
    sECTIONID = json['SECTION_ID'];
    sECTIONDESC = json['SECTION_DESC'];
    iSCLASSTEACHER = json['IS_CLASST_EACHER'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SECTION_ID'] = sECTIONID;
    data['SECTION_DESC'] = sECTIONDESC;
    data['IS_CLASST_EACHER'] = iSCLASSTEACHER;
    return data;
  }
}
