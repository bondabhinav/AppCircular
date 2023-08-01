class Dashboard {
  Dashboard({
    required this.MENUNAME,
    required this.REMARKS,
    required this.SRLNO,
    required this.IMAGE,
  });

  late final String MENUNAME;
  late final String? REMARKS;
  late final int SRLNO;
  late final String? IMAGE;

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
        MENUNAME: json['MENU_NAME'] ?? '',
        REMARKS: json['REMARKS'] ?? '',
        SRLNO: json['SRL_NO'] ?? 0,
        IMAGE: json['IMAGE'] ?? '');
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['MENU_NAME'] = MENUNAME;
    _data['REMARKS'] = REMARKS;
    _data['SRL_NO'] = SRLNO;
    _data['IMAGE'] = IMAGE;
    return _data;
  }
}
