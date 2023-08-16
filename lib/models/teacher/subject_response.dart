class SubjectResponse {
  List<Subject>? subject;

  SubjectResponse({this.subject});

  SubjectResponse.fromJson(Map<String, dynamic> json) {
    if (json['Subject'] != null) {
      subject = <Subject>[];
      json['Subject'].forEach((v) {
        subject!.add(Subject.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (subject != null) {
      data['Subject'] = subject!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subject {
  String? subjectName;
  int? subjectId;

  Subject({this.subjectName, this.subjectId});

  Subject.fromJson(Map<String, dynamic> json) {
    subjectName = json['subject_name'];
    subjectId = json['subject_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subject_name'] = subjectName;
    data['subject_id'] = subjectId;
    return data;
  }
}
