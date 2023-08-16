class StudentAssignmentModel {
  List<Assignment>? assignment;

  StudentAssignmentModel({this.assignment});

  StudentAssignmentModel.fromJson(Map<String, dynamic> json) {
    if (json['Assignment'] != null) {
      assignment = <Assignment>[];
      json['Assignment'].forEach((v) {
        assignment!.add(Assignment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (assignment != null) {
      data['Assignment'] = assignment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Assignment {
  int? aPPASSIGNMENTID;
  String? eNDDATE;
  String? aSSIGNMENTDETAILS;
  String? sUBJECT_NAME;

  Assignment({this.aPPASSIGNMENTID, this.eNDDATE, this.aSSIGNMENTDETAILS,this.sUBJECT_NAME});

  Assignment.fromJson(Map<String, dynamic> json) {
    aPPASSIGNMENTID = json['APP_ASSIGNMENT_ID'];
    eNDDATE = json['END_DATE'];
    aSSIGNMENTDETAILS = json['ASSIGNMENT_DETAILS'];
    sUBJECT_NAME = json['SUBJECT_NAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['APP_ASSIGNMENT_ID'] = aPPASSIGNMENTID;
    data['END_DATE'] = eNDDATE;
    data['ASSIGNMENT_DETAILS'] = aSSIGNMENTDETAILS;
    data['SUBJECT_NAME'] = sUBJECT_NAME;
    return data;
  }
}
