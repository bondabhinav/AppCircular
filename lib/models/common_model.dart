class CommonResponse {
  bool? success;

  CommonResponse({this.success});

  CommonResponse.fromJson(Map<String, dynamic> json) {
    success = json['Success'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Success'] = success;
    return data;
  }
}
