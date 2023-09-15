class DateOfAssignmentResponse {
  List<DATEFORASSIGNMENT>? dATEFORASSIGNMENT;

  DateOfAssignmentResponse({this.dATEFORASSIGNMENT});

  DateOfAssignmentResponse.fromJson(Map<String, dynamic> json) {
    if (json['DATE_FOR_ASSIGNMENT'] != null) {
      dATEFORASSIGNMENT = <DATEFORASSIGNMENT>[];
      json['DATE_FOR_ASSIGNMENT'].forEach((v) {
        dATEFORASSIGNMENT!.add(DATEFORASSIGNMENT.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (dATEFORASSIGNMENT != null) {
      data['DATE_FOR_ASSIGNMENT'] = dATEFORASSIGNMENT!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DATEFORASSIGNMENT {
  String? eNDDATE;

  DATEFORASSIGNMENT({this.eNDDATE});

  DATEFORASSIGNMENT.fromJson(Map<String, dynamic> json) {
    eNDDATE = json['END_DATE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['END_DATE'] = eNDDATE;
    return data;
  }
}
