class SessionListResponse {
  List<Table1>? table1;

  SessionListResponse({this.table1});

  SessionListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Table1'] != null) {
      table1 = <Table1>[];
      json['Table1'].forEach((v) {
        table1!.add(Table1.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (table1 != null) {
      data['Table1'] = table1!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Table1 {
  int? sESSIONID;
  String? aCTIVE;
  String? sTARTDATE;
  String? eNDDATE;

  Table1({this.sESSIONID, this.aCTIVE, this.sTARTDATE, this.eNDDATE});

  Table1.fromJson(Map<String, dynamic> json) {
    sESSIONID = json['SESSION_ID'];
    aCTIVE = json['ACTIVE'];
    sTARTDATE = json['START_DATE'];
    eNDDATE = json['END_DATE'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['SESSION_ID'] = sESSIONID;
    data['ACTIVE'] = aCTIVE;
    data['START_DATE'] = sTARTDATE;
    data['END_DATE'] = eNDDATE;
    return data;
  }
}
