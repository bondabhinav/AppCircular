class PaidFeeResponse {
  List<dynamic>? fEETYPE;
  List<dynamic>? dataTable1;
  List<dynamic>? dataTable2;
  List<PaidFeeItem>? table1;

  PaidFeeResponse({this.fEETYPE, this.dataTable1, this.dataTable2, this.table1});

  PaidFeeResponse.fromJson(Map<String, dynamic> json) {
    fEETYPE = json['FEE_TYPE'];
    dataTable1 = json['DataTable1'];
    dataTable2 = json['DataTable2'];
    if (json['Table1'] != null) {
      table1 = <PaidFeeItem>[];
      json['Table1'].forEach((v) {
        table1!.add(PaidFeeItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FEE_TYPE'] = fEETYPE;
    data['DataTable1'] = dataTable1;
    data['DataTable2'] = dataTable2;
    if (table1 != null) {
      data['Table1'] = table1!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaidFeeItem {
  String? dATE;
  int? pAID;
  int? rECIPTNO;

  PaidFeeItem({this.dATE, this.pAID, this.rECIPTNO});

  PaidFeeItem.fromJson(Map<String, dynamic> json) {
    dATE = json['DATE'];
    pAID = json['PAID'];
    rECIPTNO = json['RECIPTNO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DATE'] = dATE;
    data['PAID'] = pAID;
    data['RECIPTNO'] = rECIPTNO;
    return data;
  }
}

class UnpaidFeeResponse {
  List<dynamic>? fEETYPE;
  List<dynamic>? dataTable1;
  List<dynamic>? dataTable2;
  List<UnpaidFeeItem>? table1;

  UnpaidFeeResponse({this.fEETYPE, this.dataTable1, this.dataTable2, this.table1});

  UnpaidFeeResponse.fromJson(Map<String, dynamic> json) {
    fEETYPE = json['FEE_TYPE'];
    dataTable1 = json['DataTable1'];
    dataTable2 = json['DataTable2'];
    if (json['Table1'] != null) {
      table1 = <UnpaidFeeItem>[];
      json['Table1'].forEach((v) {
        table1!.add(UnpaidFeeItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FEE_TYPE'] = fEETYPE;
    data['DataTable1'] = dataTable1;
    data['DataTable2'] = dataTable2;
    if (table1 != null) {
      data['Table1'] = table1!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UnpaidFeeItem {
  String? fEEDUEDATE;
  String? fORMONTH;
  String? fEETYPEDESC;
  int? uNPAID;

  UnpaidFeeItem({this.fEEDUEDATE, this.fORMONTH, this.fEETYPEDESC, this.uNPAID});

  UnpaidFeeItem.fromJson(Map<String, dynamic> json) {
    fEEDUEDATE = json['FEE_DUE_DATE'];
    fORMONTH = json['FOR_MONTH'];
    fEETYPEDESC = json['FEE_TYPE_DESC'];
    uNPAID = json['UNPAID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['FEE_DUE_DATE'] = fEEDUEDATE;
    data['FOR_MONTH'] = fORMONTH;
    data['FEE_TYPE_DESC'] = fEETYPEDESC;
    data['UNPAID'] = uNPAID;
    return data;
  }
} 