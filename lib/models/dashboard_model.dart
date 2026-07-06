class DashboardResponse {
  final String MENUNAME;
  final String? REMARKS;
  final int SRLNO;
  final String IMAGE;

  DashboardResponse({
    required this.MENUNAME,
    this.REMARKS,
    required this.SRLNO,
    required this.IMAGE,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      MENUNAME: json['MENU_NAME']?.toString() ?? '',
      REMARKS: json['REMARKS']?.toString(),
      SRLNO: json['SRL_NO'] is int
          ? json['SRL_NO']
          : int.tryParse(json['SRL_NO']?.toString() ?? '0') ?? 0,
      IMAGE: json['IMAGE']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'MENU_NAME': MENUNAME,
      'REMARKS': REMARKS,
      'SRL_NO': SRLNO,
      'IMAGE': IMAGE,
    };
  }
}
