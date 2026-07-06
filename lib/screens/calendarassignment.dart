import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarAssignment extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  const CalendarAssignment({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Assignment Date')),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
        onDaySelected: (date, _) {
          onDateSelected(date);
          //Navigator.pop(context); // Navigate back to the previous screen
          print('calnder');
          Navigator.pushReplacementNamed(context, '/notificationAssignment');
        },
      ),
    );
  }
}
