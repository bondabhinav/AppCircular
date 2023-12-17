import 'dart:async';

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
import 'package:flexischool/models/teacher/edit_attendance_response.dart';
import 'package:flexischool/models/teacher/get_event_response.dart';
import 'package:flexischool/models/teacher/get_marked_student_response.dart';
import 'package:flexischool/models/teacher/marked_attendance_response.dart';
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
  EditAttendanceResponse? editAttendanceResponse;
  SectionClassResponse sectionClassResponse = SectionClassResponse();
  StudentResponse? studentResponse;
  GetMarkedStudentResponse? getMarkedStudentResponse;
  List<String>? checkboxGroupValues;
  final loaderProvider = getIt<LoaderProvider>();
  late List<Map<String, dynamic>> submittedMarkedList;
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
  List<StudentListModel> lstStudentCircular = [];

  final List<int> _studentIds = [];

  List<int> get studentIds => _studentIds;

  String? _fileName;

  String? get fileName => _fileName;

  bool _selectAll = false;

  bool get selectAll => _selectAll;

  List<AttendanceDetail> studentAttendanceList = [];
  Map<DateTime, List<CalendarEvent>> allEvents = {};
  MarkedAttendanceResponse? markedAttendanceResponse;
  GetEventResponse? getEventResponse;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  DateTime get selectedDay => _selectedDay;

  DateTime get focusedDay => _focusedDay;

  void toggleSelectAll() {
    _selectAll = !_selectAll;
    if (_selectAll) {
      _studentIds.clear();
      for (var item in studentResponse!.aDMSTUDREGISTRATION!) {
        _studentIds.add(item.aDMSTUDENTID!);
        //  lstStudentCircular.add({"STUDENT_ID": item.aDMSTUDENTID!});
        lstStudentCircular
            .add(StudentListModel(STUDENT_ID: item.aDMSTUDENTID.toString(), ADM_NO: item.aDMNO.toString()));
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
        getEventsDates();
        getMarkedAttendance();
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
        getEventsDates();
        getMarkedAttendance();
      }
    }
    notifyListeners();
  }

  void updateStudentData(int studentId, bool isChecked) {
    if (_selectAll) {
      if (isChecked) {
        _studentIds.add(studentId);
        //    lstStudentCircular.add({"STUDENT_ID": studentId});

        studentResponse!.aDMSTUDREGISTRATION!.where((element) {
          if (element.aDMSTUDENTID == studentId) {
            lstStudentCircular.add(StudentListModel(STUDENT_ID: studentId.toString(), ADM_NO: element.aDMNO));
          }
          return false;
        }).toList();
      } else {
        _studentIds.remove(studentId);
        lstSectionCircular.removeWhere((item) => item["STUDENT_ID"] == studentId);
        _selectAll = false;
      }
    } else {
      if (isChecked) {
        _studentIds.add(studentId);
        studentResponse!.aDMSTUDREGISTRATION!.where((element) {
          if (element.aDMSTUDENTID == studentId) {
            lstStudentCircular.add(StudentListModel(STUDENT_ID: studentId.toString(), ADM_NO: element.aDMNO));
          }
          return false;
        }).toList();
        //   lstStudentCircular.add({"STUDENT_ID": studentId});
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
        if (getClassResponse.cLASSandSECTION!.isNotEmpty) {
          _selectedClass = getClassResponse.cLASSandSECTION!.first.classId;
          if (selectedSection != null) {
            getEventsDates();
            getMarkedAttendance();
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
        if (getSectionResponse!.cLASSandSECTION!.isNotEmpty) {
          _selectedSection = getSectionResponse!.cLASSandSECTION!.first.sECTIONID;
          if (selectedClass != null) {
            getEventsDates();
            getMarkedAttendance();
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

  Future<StudentResponse?> getStudentData() async {
    try {
      studentResponse = null;
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
            //  lstStudentCircular.add({"STUDENT_ID": item.aDMSTUDENTID!});
            lstStudentCircular
                .add(StudentListModel(STUDENT_ID: item.aDMSTUDENTID!.toString(), ADM_NO: item.aDMNO));
            studentAttendanceList
                .add(AttendanceDetail(studentId: item.aDMSTUDENTID!, present: 'P', adm_id: item.aDMNO!));
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
    return studentResponse;
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
    } else if (value == 'Leave') {
      studentDetail.present = 'L';
    }

    studentAttendanceList.map((item) {
      debugPrint('new status of attendance ==> ${item.studentId}  *******  ${item.present}');
    }).toList();

    notifyListeners();
  }

  void updateMarkedAttendanceStatus(String value, Lststud lststud) {
    debugPrint('value - $value');
    lststud.pRESENT = returnShortValueOfAttendance(value);
    submittedMarkedList
            .firstWhere((item) => item['STUD_ATTENDANCE_DET_ID'] == lststud.sTUDATTENDANCEDETID)['PRESENT'] =
        returnShortValueOfAttendance(value);
    submittedMarkedList.map((item) {
      debugPrint(
          'final submited marked attendance ==> ${item['STUD_ATTENDANCE_DET_ID']}  *******  ${item['PRESENT']}');
    }).toList();
    notifyListeners();
  }

  returnShortValueOfAttendance(String value) {
    if (value == 'Present') {
      return 'P';
    } else if (value == 'Absent') {
      return 'A';
    } else if (value == 'Half Day') {
      return 'H';
    } else if (value == 'Leave') {
      return 'L';
    }
  }

  returnFullValueOfAttendance(String value) {
    if (value == 'P') {
      return 'Present';
    } else if (value == 'A') {
      return 'Absent';
    } else if (value == 'H') {
      return 'Half Day';
    } else if (value == 'L') {
      return 'Leave';
    }
  }

  Future<void> getEventsDates() async {
    _focusedDay = tempDateTime;
    getEventResponse = null;
    allEvents.clear();
    notifyListeners();
    try {
      var data = {"MONTH": tempDateTime.month.toString(), "CLASS_ID": selectedClass, "SESSION_ID": Constants.sessionId};
      final response = await apiService.post(url: Api.getEventApi, data: data);
      if (response.statusCode == 200) {
        getEventResponse = GetEventResponse.fromJson(response.data);
        List<CalendarEvent> events = getEventResponse!.calendarDate;
        allEvents = _groupEventsByDate(events);
        notifyListeners();
      } else {}
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
    }
  }

  void updateDate(DateTime selectedDay, DateTime focusedDay) {
    _selectedDay = selectedDay;
    _focusedDay = focusedDay;
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    _date = formatter.format(selectedDay);
    notifyListeners();
  }

  Map<DateTime, List<CalendarEvent>> _groupEventsByDate(List<CalendarEvent> events) {
    Map<DateTime, List<CalendarEvent>> groupedEvents = {};

    for (var event in events) {
      DateTime eventDate = DateTime(event.startDate.year, event.startDate.month, event.startDate.day);
      String formattedDate = DateFormat('yyyy-MM-dd').format(eventDate);

      if (groupedEvents.containsKey(formattedDate)) {
        groupedEvents[formattedDate]!.add(event);
      } else {
        groupedEvents[eventDate] = [event];
      }
    }

    return groupedEvents;
  }

  Color getColorForEventType(String eventType) {
    switch (eventType) {
      case 'H':
        return const Color(0xFF41B3B3);
      case 'A':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> getMarkedAttendance() async {
    try {
      var data = {
        "MONTH": tempDateTime.month.toString(),
        "CLASS_ID": selectedClass,
        "SECTION_ID": selectedSection,
        "SESSION_ID": Constants.sessionId
      };
      final response = await apiService.post(url: Api.markedAttendanceApi, data: data);
      if (response.statusCode == 200) {
        markedAttendanceResponse = MarkedAttendanceResponse.fromJson(response.data);
        notifyListeners();
      } else {}
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
    }
  }

  void disposeAndNavigateToDashboard(BuildContext context) {
    // Dispose of any resources or clear data
    getClassResponse = GetClassResponse();
    getSectionResponse = null;
    applyAttendanceResponse = null;
    sectionClassResponse = SectionClassResponse();
    studentResponse = null;
    checkboxGroupValues = null;
    _selectedClass = null;
    _selectedSection = null;
    selectedClassName = '';
    selectedSectionName = '';
    _selectedSectionIds.clear();
    lstSectionCircular.clear();
    lstStudentCircular.clear();
    _studentIds.clear();
    _fileName = null;
    _selectAll = false;
    studentAttendanceList.clear();
    allEvents.clear();
    markedAttendanceResponse = null;
    getEventResponse = null;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _date = Constants.currentDate;

    if (context.mounted) {
      notifyListeners();
    }

  }

  Future<GetMarkedStudentResponse?> getMarkedStudentAttendanceData() async {
    try {
      final data = {
        "SESSION_ID": Constants.sessionId,
        "CURRENT_CLASS_ID": selectedClass,
        "CURRENT_SECTION_ID": selectedSection,
        "ISSUE_DATE": date
      };
      loaderProvider.showLoader();
      final response = await apiService.post(url: Api.getStudentMarkedAttendanceApi, data: data);
      if (response.statusCode == 200) {
        getMarkedStudentResponse = GetMarkedStudentResponse.fromJson(response.data);
        if (getMarkedStudentResponse!.lststud!.isNotEmpty) {
          submittedMarkedList = getMarkedStudentResponse!.lststud!
              .map((attendanceData) => {
                    "STUD_ATTENDANCE_DET_ID": attendanceData.sTUDATTENDANCEDETID,
                    "PRESENT": attendanceData.pRESENT
                  })
              .toList();
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
    return getMarkedStudentResponse;
  }

  Future<EditAttendanceResponse?> applyMarkedAttendance() async {
    loaderProvider.showLoader();
    notifyListeners();
    try {
      final response = await apiService
          .post(url: Api.editAttendanceApi, data: {"lstAttendanceDetail": submittedMarkedList});
      if (response.statusCode == 200) {
        editAttendanceResponse = null;
        editAttendanceResponse = EditAttendanceResponse.fromJson(response.data);
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
    return editAttendanceResponse;
  }
  DateTime tempDateTime = DateTime.now();

  void updateMonth(DateTime dateTime) {
    tempDateTime = dateTime;
  }
}

class StudentListModel {
  String? STUDENT_ID;
  String? ADM_NO;

  StudentListModel({this.ADM_NO, this.STUDENT_ID});

  StudentListModel.fromJson(Map<String, dynamic> json) {
    STUDENT_ID = json['STUDENT_ID'];
    ADM_NO = json['ADM_NO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ADM_NO'] = ADM_NO;
    data['STUDENT_ID'] = STUDENT_ID;
    return data;
  }
}
