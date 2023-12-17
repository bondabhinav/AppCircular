import 'dart:async';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/models/student/over_all_attendance_response.dart';
import 'package:flexischool/models/teacher/get_event_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

final GetIt getIt = GetIt.instance;

class AcademicProvider extends ChangeNotifier {
  final apiService = ApiService();
  String _date = Constants.currentDate;
  GetEventResponse? getEventResponse;
  Map<DateTime, List<CalendarEvent>> allEvents = {};
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final loaderProvider = getIt<LoaderProvider>();
  DateTime get selectedDay => _selectedDay;

  DateTime get focusedDay => _focusedDay;

  Future<void> getEventsDates() async {
    loaderProvider.showLoader();
    _focusedDay = tempDateTime;
    getEventResponse = null;
    allEvents.clear();
    notifyListeners();
    try {
      var data = {
        "MONTH": tempDateTime.month.toString(),
        "CLASS_ID": Constants.studentClassId,
        "SESSION_ID": Constants.sessionId
      };
      final response = await apiService.post(url: Api.getEventApi, data: data);
      if (response.statusCode == 200) {
        getEventResponse = GetEventResponse.fromJson(response.data);
        List<CalendarEvent> events = getEventResponse!.calendarDate;
        allEvents = _groupEventsByDate(events);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
      }
    } catch (e) {
      loaderProvider.hideLoader();
      debugPrint('Failed to connect to the API ${e.toString()}');
    }
    notifyListeners();
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
    notifyListeners();
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

  DateTime tempDateTime = DateTime.now();

  void updateMonth(DateTime dateTime) {
    tempDateTime = dateTime;
  }
}
