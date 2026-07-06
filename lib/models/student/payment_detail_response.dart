class PaymentDetailResponse {
  List<dynamic>? fEETYPE;
  List<dynamic>? dataTable1;
  List<dynamic>? dataTable2;
  List<PaymentDetailItem>? table1;

  PaymentDetailResponse({
    this.fEETYPE,
    this.dataTable1,
    this.dataTable2,
    this.table1,
  });

  PaymentDetailResponse.fromJson(Map<String, dynamic> json) {
    fEETYPE = json['FEE_TYPE'];
    dataTable1 = json['DataTable1'];
    dataTable2 = json['DataTable2'];
    if (json['Table1'] != null) {
      table1 = <PaymentDetailItem>[];
      json['Table1'].forEach((v) {
        table1!.add(PaymentDetailItem.fromJson(v));
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

class PaymentDetailItem {
  String? dATE;
  String? fEETYPEDESC;
  int? pAID;
  int? rECIPTNO;

  PaymentDetailItem({this.dATE, this.fEETYPEDESC, this.pAID, this.rECIPTNO});

  PaymentDetailItem.fromJson(Map<String, dynamic> json) {
    dATE = json['DATE'];
    fEETYPEDESC = json['FEE_TYPE_DESC'];
    pAID = json['PAID'];
    rECIPTNO = json['RECIPTNO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['DATE'] = dATE;
    data['FEE_TYPE_DESC'] = fEETYPEDESC;
    data['PAID'] = pAID;
    data['RECIPTNO'] = rECIPTNO;
    return data;
  }
}
