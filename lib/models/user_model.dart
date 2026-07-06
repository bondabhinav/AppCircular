class User {
  User({
    required this.USERNAME,
    required this.USERKID,
    required this.EMPLOYEEID,
    required this.EMPLOYEECODE,
    required this.DEPARTMENTNAME,
    required this.DESIGNATIONDESC,
    required this.PHOTO,
  });
  late final String USERNAME;
  late final int USERKID;
  late final int EMPLOYEEID;
  late final int? EMPLOYEECODE;
  late final String DEPARTMENTNAME;
  late final String DESIGNATIONDESC;
  late final String PHOTO;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      USERNAME: json['USER_NAME'] ?? '',
      USERKID: json['USER_KID'] ?? 0,
      EMPLOYEEID: json['EMPLOYEE_ID'] ?? 0,
      EMPLOYEECODE: json['EMPLOYEE_CODE'] ?? 0,
      DEPARTMENTNAME: json['DEPARTMENT_NAME'] ?? '',
      DESIGNATIONDESC: json['DESIGNATION_DESC'] ?? '',
      PHOTO: json['PHOTO'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['USER_NAME'] = USERNAME;
    data['USER_KID'] = USERKID;
    data['EMPLOYEE_ID'] = EMPLOYEEID;
    data['EMPLOYEE_CODE'] = EMPLOYEECODE;
    data['DEPARTMENT_NAME'] = DEPARTMENTNAME;
    data['DESIGNATION_DESC'] = DESIGNATIONDESC;
    data['PHOTO'] = PHOTO;
    return data;
  }
}
