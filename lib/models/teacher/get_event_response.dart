class CalendarEvent {
  String eventName;
  DateTime startDate;
  String type;

  CalendarEvent({
    required this.eventName,
    required this.startDate,
    required this.type,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      eventName: json['EVENT_NAME'],
      startDate: DateTime.parse(json['START_DATE'].toString().split(' ').first),
      type: json['TYPE'],
    );
  }
}

class GetEventResponse {
  List<CalendarEvent> calendarDate;

  GetEventResponse({required this.calendarDate});

  factory GetEventResponse.fromJson(Map<String, dynamic> json) {
    List<CalendarEvent> events = List<CalendarEvent>.from((json['Calendar_date'] as List).map((event) {
      return CalendarEvent.fromJson(event);
    }));

    return GetEventResponse(calendarDate: events);
  }
}
