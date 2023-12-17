class EditAttendanceResponse {
  bool? success;
  dynamic errorCode;
  dynamic errorMessage;
  dynamic token;
  dynamic loginUserId;
  dynamic nUMBER;

  EditAttendanceResponse(
      {this.success,
        this.errorCode,
        this.errorMessage,
        this.token,
        this.loginUserId,
        this.nUMBER});

  EditAttendanceResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    errorCode = json['ErrorCode'];
    errorMessage = json['ErrorMessage'];
    token = json['Token'];
    loginUserId = json['LoginUserId'];
    nUMBER = json['NUMBER'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Success'] = success;
    data['ErrorCode'] = errorCode;
    data['ErrorMessage'] = errorMessage;
    data['Token'] = token;
    data['LoginUserId'] = loginUserId;
    data['NUMBER'] = nUMBER;
    return data;
  }
}
