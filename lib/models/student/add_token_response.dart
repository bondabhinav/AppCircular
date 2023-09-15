class AddTokenResponse {
  bool? success;
  int? errorCode;
  bool? token;
  bool? loginUserId;
  int? nUMBER;

  AddTokenResponse(
      {this.success,
        this.errorCode,
        this.token,
        this.loginUserId,
        this.nUMBER});

  AddTokenResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
    errorCode = json['ErrorCode'];
    token = json['Token'];
    loginUserId = json['LoginUserId'];
    nUMBER = json['NUMBER'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Success'] = success;
    data['ErrorCode'] = errorCode;
    data['Token'] = token;
    data['LoginUserId'] = loginUserId;
    data['NUMBER'] = nUMBER;
    return data;
  }
}
