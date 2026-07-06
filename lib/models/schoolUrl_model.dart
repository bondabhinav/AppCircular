/*
// Example Usage
Map<String, dynamic> map = jsonDecode(<myJSONString>);
var mySchoolUrlNode = SchoolUrl.fromJson(map);
*/

class SchoolUrl {
  SchoolUrl({
    required this.ID,
    required this.SCHOOLURL,
    required this.APIURL,
    required this.IMGLOGO,
    required this.APIIMAGE,
  });

  //int? iD;
  late final int ID;
  late final String SCHOOLURL;
  late final String APIURL;
  late final String IMGLOGO;
  late final String APIIMAGE;

  factory SchoolUrl.fromJson(Map<String, dynamic> json) {
    return SchoolUrl(
      ID: json['ID'] ?? 0,
      SCHOOLURL: json['SCHOOL_URL'] ?? '',
      APIURL: json['API_URL'] ?? '',
      IMGLOGO: json['IMG_LOGO'] ?? '',
      APIIMAGE: json['API_IMAGE'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['ID'] = ID;
    data['SCHOOL_URL'] = SCHOOLURL;
    data['API_URL'] = APIURL;
    data['IMG_LOGO'] = IMGLOGO;
    data['API_IMAGE'] = APIIMAGE;
    return data;
  }
}
