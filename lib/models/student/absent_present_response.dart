class AbsentPresentResponse {
  List<Lststud>? lststud;

  AbsentPresentResponse({this.lststud});

  AbsentPresentResponse.fromJson(Map<String, dynamic> json) {
    if (json['lststud'] != null) {
      lststud = <Lststud>[];
      json['lststud'].forEach((v) {
        lststud!.add(Lststud.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lststud != null) {
      data['lststud'] = lststud!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lststud {
  String? aTTDATE;
  String? pRESENT;

  Lststud({this.aTTDATE, this.pRESENT});

  Lststud.fromJson(Map<String, dynamic> json) {
    aTTDATE = json['ATT_DATE'];
    pRESENT = json['PRESENT'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ATT_DATE'] = aTTDATE;
    data['PRESENT'] = pRESENT;
    return data;
  }
}
