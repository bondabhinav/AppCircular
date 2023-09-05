class StudentCircularDocumentListResponse {
  List<CircularAttachment>? circularAttachment;

  StudentCircularDocumentListResponse({this.circularAttachment});

  StudentCircularDocumentListResponse.fromJson(Map<String, dynamic> json) {
    if (json['CircularAttachment'] != null) {
      circularAttachment = <CircularAttachment>[];
      json['CircularAttachment'].forEach((v) {
        circularAttachment!.add(CircularAttachment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (circularAttachment != null) {
      data['CircularAttachment'] = circularAttachment!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CircularAttachment {
  int? aPPCIRCULARINFODETID;
  int? aPPCIRCULARID;
  String? fILENAME;

  CircularAttachment({this.aPPCIRCULARINFODETID, this.aPPCIRCULARID, this.fILENAME});

  CircularAttachment.fromJson(Map<String, dynamic> json) {
    aPPCIRCULARINFODETID = json['APP_CIRCULAR_INFO_DET_ID'];
    aPPCIRCULARID = json['APP_CIRCULAR_ID'];
    fILENAME = json['FILE_NAME'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['APP_CIRCULAR_INFO_DET_ID'] = aPPCIRCULARINFODETID;
    data['APP_CIRCULAR_ID'] = aPPCIRCULARID;
    data['FILE_NAME'] = fILENAME;
    return data;
  }
}
