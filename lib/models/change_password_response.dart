class CheckOldPasswordResponse {
  List<Table1>? table1;

  CheckOldPasswordResponse({this.table1});

  CheckOldPasswordResponse.fromJson(Map<String, dynamic> json) {
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
  String? sTUDPASSWORD;
  String? uSER_PASSWORD;

  Table1({this.sTUDPASSWORD,this.uSER_PASSWORD});

  Table1.fromJson(Map<String, dynamic> json) {
    sTUDPASSWORD = json['STUD_PASSWORD'];
    uSER_PASSWORD = json['USER_PASSWORD'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['STUD_PASSWORD'] = sTUDPASSWORD;
    data['USER_PASSWORD'] = uSER_PASSWORD;
    return data;
  }
}
