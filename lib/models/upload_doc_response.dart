class UploadDocResponse {
  String? fileNAME;

  UploadDocResponse({this.fileNAME});

  UploadDocResponse.fromJson(Map<String, dynamic> json) {
    fileNAME = json['File_NAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['File_NAME'] = fileNAME;
    return data;
  }
}
