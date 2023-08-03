class SessionListResponse {
  List<Table1>? table1;

  SessionListResponse({this.table1});

  SessionListResponse.fromJson(Map<String, dynamic> json) {
    if (json['Table1'] != null) {
      table1 = <Table1>[];
      json['Table1'].forEach((v) {
        table1!.add(new Table1.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.table1 != null) {
      data['Table1'] = this.table1!.map((v) => v.toJson()).toList();
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SESSION_ID'] = this.sESSIONID;
    data['ACTIVE'] = this.aCTIVE;
    data['START_DATE'] = this.sTARTDATE;
    data['END_DATE'] = this.eNDDATE;
    return data;
  }
}
