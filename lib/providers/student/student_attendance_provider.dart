import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/config.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/student/absent_present_response.dart';
import 'package:flexischool/models/student/over_all_attendance_response.dart';
import 'package:flexischool/models/student/student_attendance_graph_response.dart';
import 'package:flexischool/models/teacher/get_event_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

final GetIt getIt = GetIt.instance;

class StudentAttendanceProvider extends ChangeNotifier {
  StudentAttendanceGraphResponse? studentAttendanceGraphResponse;
  AbsentPresentResponse? absentPresentResponse;
  OverAllAttendanceResponse? overAllAttendanceResponse;
  final loaderProvider = getIt<LoaderProvider>();
  final apiService = ApiService();
  int month = DateTime.now().month;
  var focusedDay = DateTime.now();
  GetEventResponse? getEventResponse;
  Map<DateTime, List<CalendarEvent>> allEvents = {};

  Future<void> fetchOverAllPercentageData() async {
    try {
      var data = {
        "CLASS_ID": Constants.studentClassId,
        "SECTION_ID": Constants.studentSectionId,
        "ADM_NO": WebService.studentLoginData!.table1!.first.aDMNO.toString(),
        "SESSION_ID": Constants.sessionId
      };
      final response = await apiService.post(url: Api.getOverallPercentageApi, data: data);
      if (response.statusCode == 200) {
        overAllAttendanceResponse = OverAllAttendanceResponse.fromJson(response.data);
        notifyListeners();
      } else {
        overAllAttendanceResponse = OverAllAttendanceResponse();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      overAllAttendanceResponse = OverAllAttendanceResponse();
      notifyListeners();
    }
  }

  Future<void> fetchAttendanceGraphData() async {
    try {
      loaderProvider.showLoader();
      var data = {
        "CLASS_ID": Constants.studentClassId,
        "SECTION_ID": Constants.studentSectionId,
        "ADM_NO": WebService.studentLoginData!.table1!.first.aDMNO.toString(),
        "SESSION_ID": Constants.sessionId
      };
      final response = await apiService.post(url: Api.studentAttendanceGraphApi, data: data);
      if (response.statusCode == 200) {
        studentAttendanceGraphResponse = StudentAttendanceGraphResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        studentAttendanceGraphResponse = StudentAttendanceGraphResponse();
        loaderProvider.hideLoader();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      studentAttendanceGraphResponse = StudentAttendanceGraphResponse();
      loaderProvider.hideLoader();
      notifyListeners();
    }
  }

  Future<void> fetchAbsentPresentCalenderData() async {
    try {
      loaderProvider.showLoader();
      var data = {
        "CLASS_ID": Constants.studentClassId,
        "ADM_NO": WebService.studentLoginData!.table1!.first.aDMNO.toString(),
        "SESSION_ID": Constants.sessionId,
        "MONTH": month
      };
      final response = await apiService.post(url: Api.absentPresentCalenderApi, data: data);
      if (response.statusCode == 200) {
        absentPresentResponse = AbsentPresentResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        absentPresentResponse = AbsentPresentResponse();
        loaderProvider.hideLoader();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      absentPresentResponse = AbsentPresentResponse();
      loaderProvider.hideLoader();
      notifyListeners();
    }
  }

  Future<void> getEventsDates() async {
    getEventResponse = null;
    allEvents.clear();
    notifyListeners();
    try {
      var data = {"MONTH": month, "CLASS_ID": Constants.studentClassId, "SESSION_ID": Constants.sessionId};
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

  void updateMonth(DateTime dateTime) {
    month = dateTime.month;
    focusedDay = dateTime;
    fetchAbsentPresentCalenderData();
    getEventsDates();
  }
}
