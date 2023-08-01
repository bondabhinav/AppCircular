import 'dart:convert';

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

  factory  User.fromJson(Map<String, dynamic> json){
    return User(
    USERNAME : json['USER_NAME'] ?? '',
    USERKID : json['USER_KID'] ?? 0,
    EMPLOYEEID : json['EMPLOYEE_ID'] ?? 0,
    EMPLOYEECODE : json['EMPLOYEE_CODE'] ?? 0,
    DEPARTMENTNAME : json['DEPARTMENT_NAME'] ?? '',
    DESIGNATIONDESC : json['DESIGNATION_DESC'] ?? '',
    PHOTO : json['PHOTO'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['USER_NAME'] = USERNAME;
    _data['USER_KID'] = USERKID;
    _data['EMPLOYEE_ID'] = EMPLOYEEID;
    _data['EMPLOYEE_CODE'] = EMPLOYEECODE;
    _data['DEPARTMENT_NAME'] = DEPARTMENTNAME;
    _data['DESIGNATION_DESC'] = DESIGNATIONDESC;
    _data['PHOTO'] = PHOTO;
    return _data;
  }
}