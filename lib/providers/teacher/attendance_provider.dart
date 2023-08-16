import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/models/get_class_response.dart';
import 'package:flexischool/models/get_section_response.dart';
import 'package:flexischool/models/request/attendance_request.dart';
import 'package:flexischool/models/request/student_request.dart';
import 'package:flexischool/models/section_class_model.dart';
import 'package:flexischool/models/student_response.dart';
import 'package:flexischool/models/teacher/apply_attendance_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

final GetIt getIt = GetIt.instance;

class AttendanceProvider extends ChangeNotifier {
  final apiService = ApiService();
  GetClassResponse getClassResponse = GetClassResponse();
  GetSectionResponse? getSectionResponse;
  ApplyAttendanceResponse? applyAttendanceResponse;

  SectionClassResponse sectionClassResponse = SectionClassResponse();
  StudentResponse? studentResponse;
  List<String>? checkboxGroupValues;
  final loaderProvider = getIt<LoaderProvider>();

  String _date = Constants.currentDate;

  String get date => _date;

  int? _selectedClass;

  int? get selectedClass => _selectedClass;

  int? _selectedSection;

  int? get selectedSection => _selectedSection;

  String selectedClassName = '';
  String selectedSectionName = '';
  final List<int> _selectedSectionIds = [];

  List<int> get selectedSectionIds => _selectedSectionIds;

  List<Map<String, dynamic>> lstSectionCircular = [];
  List<Map<String, dynamic>> lstStudentCircular = [];

  final List<int> _studentIds = [];

  List<int> get studentIds => _studentIds;

  String? _fileName;

  String? get fileName => _fileName;

  bool _selectAll = false;

  bool get selectAll => _selectAll;

  List<AttendanceDetail> studentAttendanceList = [];

  void toggleSelectAll() {
    _selectAll = !_selectAll;
    if (_selectAll) {
      _studentIds.clear();
      for (var item in studentResponse!.aDMSTUDREGISTRATION!) {
        _studentIds.add(item.aDMSTUDENTID!);
        lstStudentCircular.add({"STUDENT_ID": item.aDMSTUDENTID!});
      }
    } else {
      _studentIds.clear();
      lstStudentCircular.clear();
    }
    notifyListeners();
  }

  // void updateSelectedSection(int sectionId, bool isChecked) {
  //   if (isChecked) {
  //     _selectedSectionIds.add(sectionId);
  //     lstSectionCircular.add({"SECTION_ID": sectionId});
  //   } else {
  //     _selectedSectionIds.remove(sectionId);
  //     lstSectionCircular.removeWhere((item) => item["SECTION_ID"] == sectionId);
  //   }
  //   if (selectedClass != null) {
  //     if (selectedSectionIds.isNotEmpty) {
  //       getStudentData();
  //     } else {
  //       studentResponse = null;
  //       studentResponse?.aDMSTUDREGISTRATION!.clear();
  //     }
  //   }
  //   notifyListeners();
  // }

  void updateSelectedClass(int? value) {
    _selectedClass = value;
    selectedClassName =
        getClassResponse.cLASSandSECTION!.firstWhere((element) => element.classId == value).cLASSDESC!;
    debugPrint('class id ===> $selectedClass');
    debugPrint('class name ===> $selectedClassName');
    if (selectedClass != null) {
      if (selectedSection != null) {
        getStudentData();
      }
    }
    notifyListeners();
  }

  void updateSelectedSection(int? value) {
    _selectedSection = value;
    selectedSectionName = getSectionResponse?.cLASSandSECTION!
            .firstWhere((element) => element.sECTIONID == value)
            .sECTIONDESC ??
        "";
    debugPrint('section id ===> $selectedSection');
    debugPrint('section name ===> $selectedSectionName');
    if (selectedClass != null) {
      if (selectedSection != null) {
        getStudentData();
      }
    }
    notifyListeners();
  }

  void updateStudentData(int studentId, bool isChecked) {
    if (_selectAll) {
      if (isChecked) {
        _studentIds.add(studentId);
        lstStudentCircular.add({"STUDENT_ID": studentId});
      } else {
        _studentIds.remove(studentId);
        lstSectionCircular.removeWhere((item) => item["STUDENT_ID"] == studentId);
        _selectAll = false;
      }
    } else {
      if (isChecked) {
        _studentIds.add(studentId);
        lstStudentCircular.add({"STUDENT_ID": studentId});
        if (_studentIds.length == studentResponse!.aDMSTUDREGISTRATION!.length) {
          _selectAll = true;
        }
      } else {
        lstSectionCircular.removeWhere((item) => item["STUDENT_ID"] == studentId);
        _studentIds.remove(studentId);
      }
    }

    notifyListeners();
  }

  Future<void> fetchClassData({required int teacherId}) async {
    try {
      loaderProvider.showLoader();
      var data = {"TEACHER_ID": teacherId, "SESSION_ID": Constants.sessionId};
      final response = await apiService.post(url: Api.getClassApi, data: data);
      if (response.statusCode == 200) {
        getClassResponse = GetClassResponse.fromJson(response.data);
        if(getClassResponse.cLASSandSECTION!.isNotEmpty){
          _selectedClass = getClassResponse.cLASSandSECTION!.first.classId;
          if(selectedSection != null){
            getStudentData();
          }
        }
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API');
    }
  }

  Future<void> fetchSectionData({required int teacherId}) async {
    try {
      loaderProvider.showLoader();
      var data = {"TEACHER_ID": teacherId, "SESSION_ID": Constants.sessionId};
      final response = await apiService.post(url: Api.getSectionApi, data: data);
      if (response.statusCode == 200) {
        getSectionResponse = GetSectionResponse.fromJson(response.data);
        if(getSectionResponse!.cLASSandSECTION!.isNotEmpty){
          _selectedSection = getSectionResponse!.cLASSandSECTION!.first.sECTIONID;
          if(selectedClass != null){
            getStudentData();
          }
        }
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API');
    }
  }

  Future<void> getStudentData() async {
    try {
      final requestPayload = StudentRequest(sESSIONID: Constants.sessionId.toString(), lstClass: [
        LstClass(cLASSID: selectedClass.toString()),
      ], lstSection: [
        LstSection(cURRENTSECTIONID: selectedSection.toString())
      ]
          // selectedSectionIds
          //     .map((sectionId) => LstSection(cURRENTSECTIONID: sectionId.toString()))
          //     .toList(),
          );
      final jsonPayload = requestPayload.toJson();
      loaderProvider.showLoader();
      final response = await apiService.post(url: Api.getStudentApi, data: jsonPayload);
      if (response.statusCode == 200) {
        studentResponse = StudentResponse.fromJson(response.data);
        if (studentResponse!.aDMSTUDREGISTRATION!.isNotEmpty) {
          _studentIds.clear();
          lstStudentCircular.clear();
          studentAttendanceList.clear();
          _selectAll = true;
          studentResponse!.aDMSTUDREGISTRATION!.map((item) {
            _studentIds.add(item.aDMSTUDENTID!);
            lstStudentCircular.add({"STUDENT_ID": item.aDMSTUDENTID!});
            studentAttendanceList.add(AttendanceDetail(studentId: item.aDMSTUDENTID!, present: 'P'));
          }).toList();
        }
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API');
    }
  }

  Future<ApplyAttendanceResponse?> applyAttendance({required int teacherId}) async {
    loaderProvider.showLoader();
    notifyListeners();
    try {
      final requestPayload = AttendanceDataRequest(
          classId: selectedClass!,
          attDate: date,
          entryDate: Constants.currentDate,
          sectionId: selectedSection!,
          lastUpdateDate: Constants.currentDate,
          entryUserId: teacherId.toString(),
          sessionId: Constants.sessionId,
          updateUserId: teacherId.toString(),
          lstAttendanceDetail: studentAttendanceList);
      final jsonPayload = requestPayload.toJson();
      final response = await apiService.post(url: Api.applyAttendanceApi, data: jsonPayload);
      if (response.statusCode == 200) {
        applyAttendanceResponse = null;
        applyAttendanceResponse = ApplyAttendanceResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        notifyListeners();
      }
    } catch (e) {
      loaderProvider.hideLoader();
      notifyListeners();
    }
    return applyAttendanceResponse;
  }

  Future<void> selectDate({required BuildContext context}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      // DateTime selectedStartDate = DateTime(
      //   pickedDate.year,
      //   pickedDate.month,
      //   pickedDate.day,
      // );
      // _date = DateTimeUtils.formatDate(selectedStartDate).toString();
      final DateFormat formatter = DateFormat('yyyy-MM-dd');
      _date = formatter.format(pickedDate);
      notifyListeners();
    }
  }

  void updateAttendanceStatus(String value, ADMSTUDREGISTRATION admstudregistration) {
    admstudregistration.attendance = value;

    AttendanceDetail? studentDetail = studentAttendanceList.firstWhere(
      (detail) => detail.studentId == admstudregistration.aDMSTUDENTID,
    );

    if (value == 'Present') {
      studentDetail.present = 'P';
    } else if (value == 'Absent') {
      studentDetail.present = 'A';
    } else if (value == 'Half Day') {
      studentDetail.present = 'H';
    }else if (value == 'Leave') {
      studentDetail.present = 'L';
    }

    studentAttendanceList.map((item) {
      debugPrint('new status of attendance ==> ${item.studentId}  *******  ${item.present}');
    }).toList();

    notifyListeners();
  }
}
