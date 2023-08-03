class ApplyAttendanceResponse {
  dynamic lstMobNo;
  dynamic getAttendanceStud;
  dynamic lstworking;
  bool success;
  int errorCode;
  dynamic errorMessage;
  bool token;
  bool loginUserId;
  int number;
  dynamic userName;
  dynamic password;
  dynamic message;

  ApplyAttendanceResponse({
    this.lstMobNo,
    this.getAttendanceStud,
    this.lstworking,
    required this.success,
    required this.errorCode,
    this.errorMessage,
    required this.token,
    required this.loginUserId,
    required this.number,
    this.userName,
    this.password,
    this.message,
  });

  factory ApplyAttendanceResponse.fromJson(Map<String, dynamic> json) {
    return ApplyAttendanceResponse(
      lstMobNo: json['lstMobNo'],
      getAttendanceStud: json['getAttendanceStud'],
      lstworking: json['lstworking'],
      success: json['Success'] ?? false,
      errorCode: json['ErrorCode'] ?? 0,
      errorMessage: json['ErrorMessage'],
      token: json['Token'] ?? false,
      loginUserId: json['LoginUserId'] ?? false,
      number: json['NUMBER'] ?? 0,
      userName: json['USER_NAME'],
      password: json['PASSWORD'],
      message: json['Message'],
    );
  }
}
