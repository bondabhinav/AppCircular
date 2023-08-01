import 'dart:convert';
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
        APIIMAGE: json['API_IMAGE'] ?? '');
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ID'] = ID;
    _data['SCHOOL_URL'] = SCHOOLURL;
    _data['API_URL'] = APIURL;
    _data['IMG_LOGO'] = IMGLOGO;
    _data['API_IMAGE'] = APIIMAGE;
    return _data;
  }
}
