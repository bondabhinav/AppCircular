import 'package:flexischool/models/teacher/get_event_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/student/student_attendance_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/student/absent_present_response.dart';

class AbsentPresentStudentCalenderScreen extends StatefulWidget {
  final int month;

  const AbsentPresentStudentCalenderScreen({super.key, required this.month});

  @override
  State<AbsentPresentStudentCalenderScreen> createState() => _AbsentPresentStudentCalenderScreenState();
}

class _AbsentPresentStudentCalenderScreenState extends State<AbsentPresentStudentCalenderScreen> {
  late StudentAttendanceProvider studentAttendanceProvider;
  final loaderProvider = getIt<LoaderProvider>();

  int touchedIndex = -1;
  late int showingTooltip;

  @override
  void initState() {
    super.initState();
    studentAttendanceProvider = StudentAttendanceProvider();
    studentAttendanceProvider.month = widget.month;
    studentAttendanceProvider.focusedDay = DateTime(DateTime.now().year, widget.month, 1);
    studentAttendanceProvider.fetchAbsentPresentCalenderData();
    studentAttendanceProvider.getEventsDates();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => studentAttendanceProvider,
        builder: (context, child) {
          return Consumer<StudentAttendanceProvider>(builder: (context, model, _) {
            return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                    title: const Text('Attendance', style: TextStyle(color: Colors.white))),
                body: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                      child: TableCalendar(
                          availableGestures: AvailableGestures.horizontalSwipe,
                          focusedDay: model.focusedDay,
                          onDaySelected: (selectedDay, focusedDay) {
                            if (selectedDay.isAfter(DateTime.now())) {
                              return;
                            }
                          },
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                          onPageChanged: (dateTime) {
                            model.updateMonth(dateTime);
                          },
                          rowHeight: 60,
                          daysOfWeekHeight: 30,
                          daysOfWeekStyle: DaysOfWeekStyle(
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black54), color: Colors.black54),
                            weekdayStyle: const TextStyle(
                                fontFamily: "Montserrat Medium", color: Colors.white, fontSize: 14),
                            weekendStyle: const TextStyle(
                                fontFamily: "Montserrat Medium", color: Colors.white, fontSize: 14),
                          ),
                          calendarStyle: const CalendarStyle(
                              outsideDaysVisible: false,
                              tableBorder: TableBorder(
                                  horizontalInside: BorderSide(color: Colors.black),
                                  verticalInside: BorderSide(color: Colors.black)),
                              todayDecoration:
                                  BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                              selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),

                      calendarBuilders: CalendarBuilders(
                        defaultBuilder: (context, day, _) {
                          DateTime formattedDay = DateTime(day.year, day.month, day.day);

                          // Check if the day is Sunday
                          bool isSunday = day.weekday == DateTime.sunday;

                          // Check if the day has any events
                          if (model.allEvents.containsKey(formattedDay)) {
                            List<CalendarEvent> eventsForDay = model.allEvents[formattedDay]!;
                            Color backgroundColor;

                            // Check for any 'H' type event
                            if (eventsForDay.any((event) => event.type == 'H')) {
                              backgroundColor = const Color(0xFF41B3B3); // Use the color for 'H' type event
                            } else {
                              // Check for any 'A' type event
                              if (eventsForDay.any((event) => event.type == 'A')) {
                                backgroundColor = Colors.orange; // Use the color for 'A' type event
                              } else {
                                // Use a default color for other events
                                backgroundColor = Colors.grey;
                              }
                            }

                            // Return a container with the appropriate styling
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(color: backgroundColor),
                              child: buildDayContent(day, formattedDay, model, eventsForDay,isSunday),
                            );
                          } else {
                            // Handle days without events
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isSunday ? const Color(0xFF41B3B3) : Colors.grey,
                              ),
                              child: buildDayContent(day, formattedDay, model, [],isSunday),
                            );
                          }
                        },
                      ),



                          // calendarBuilders: CalendarBuilders(
                          //   defaultBuilder: (context, day, _) {
                          //     DateTime formattedDay = DateTime(day.year, day.month, day.day);
                          //     Color? backgroundColor = Colors.grey;
                          //     bool isMarked = model.absentPresentResponse?.lststud?.any((attendance) {
                          //           DateTime attendanceDate = DateTime.parse(attendance.aTTDATE!).toLocal();
                          //           DateTime selectedDateWithoutTime = DateTime(day.year, day.month, day.day);
                          //           return selectedDateWithoutTime.isAtSameMomentAs(attendanceDate);
                          //         }) ??
                          //         false;
                          //
                          //     var presentStatus = model.absentPresentResponse?.lststud?.firstWhere(
                          //       (attendance) {
                          //         DateTime attendanceDate = DateTime.parse(attendance.aTTDATE!).toLocal();
                          //         DateTime selectedDateWithoutTime = DateTime(day.year, day.month, day.day);
                          //         return selectedDateWithoutTime.isAtSameMomentAs(attendanceDate);
                          //       },
                          //       orElse: () => Lststud(
                          //           aTTDATE: '',
                          //           pRESENT: ''), // Return a default Lststud if no element is found
                          //     );
                          //
                          //     backgroundColor = presentStatus != null
                          //         ? getColorForAttendanceStatus(presentStatus.pRESENT ?? '')
                          //         : Colors.grey;
                          //     isMarked = presentStatus != null;
                          //     if (isMarked) {
                          //       return Container(
                          //         width: double.infinity,
                          //         decoration: BoxDecoration(color: backgroundColor),
                          //         child: Column(
                          //           children: [
                          //             const SizedBox(height: 5),
                          //             Text('${day.day}', style: const TextStyle(color: Colors.white)),
                          //             const SizedBox(height: 5),
                          //             Text(
                          //               model.allEvents.containsKey(formattedDay)
                          //                   ? model.allEvents[formattedDay]!
                          //                       .map((event) => event.eventName)
                          //                       .join(', ')
                          //                   : '',
                          //               textAlign: TextAlign.center,
                          //               overflow: TextOverflow.ellipsis,
                          //               maxLines: 2,
                          //               style: const TextStyle(color: Colors.white, fontSize: 10),
                          //             ),
                          //           ],
                          //         ),
                          //       );
                          //     }
                          //
                          //     if (model.allEvents.containsKey(formattedDay)) {
                          //       List<CalendarEvent> eventsForDay = model.allEvents[formattedDay]!;
                          //       bool isSunday = day.weekday == DateTime.sunday;
                          //
                          //       if (isSunday) {
                          //         backgroundColor = const Color(0xFF41B3B3);
                          //       } else {
                          //         // Check for any 'H' type event
                          //         if (eventsForDay.any((event) => event.type == 'H')) {
                          //           backgroundColor =
                          //               const Color(0xFF41B3B3); // Use the color for 'H' type event
                          //         } else {
                          //           // Check for any 'A' type event
                          //           if (eventsForDay.any((event) => event.type == 'A')) {
                          //             backgroundColor = Colors.orange; // Use the color for 'A' type event
                          //           }
                          //           // Add more cases as needed for other event types
                          //         }
                          //       }
                          //       return Container(
                          //         width: double.infinity,
                          //         decoration: BoxDecoration(color: backgroundColor),
                          //         child: Column(
                          //           children: [
                          //             const SizedBox(height: 5),
                          //             Text('${day.day}', style: const TextStyle(color: Colors.white)),
                          //             const SizedBox(height: 5),
                          //             Text(
                          //               eventsForDay.map((event) => event.eventName).join(', '),
                          //               textAlign: TextAlign.center,
                          //               overflow: TextOverflow.ellipsis,
                          //               maxLines: 2,
                          //               style: const TextStyle(color: Colors.white, fontSize: 10),
                          //             ),
                          //           ],
                          //         ),
                          //       );
                          //     }
                          //     return Container(
                          //       width: double.infinity,
                          //       decoration: BoxDecoration(color: backgroundColor),
                          //       child: Column(
                          //         children: [
                          //           const SizedBox(height: 5),
                          //           Text('${day.day}', style: const TextStyle(color: Colors.white)),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // )




                          // calendarBuilders: CalendarBuilders(defaultBuilder: (context, day, _) {
                          //   DateTime formattedDay = DateTime(day.year, day.month, day.day);
                          //   bool isPresent = model.absentPresentResponse?.lststud?.any((attendance) {
                          //         DateTime attendanceDate = DateTime.parse(attendance.aTTDATE!).toLocal();
                          //         DateTime selectedDateWithoutTime = DateTime(day.year, day.month, day.day);
                          //         return selectedDateWithoutTime.isAtSameMomentAs(attendanceDate) &&
                          //             attendance.pRESENT == 'P';
                          //       }) ??
                          //       false;
                          //   bool isAbsent = model.absentPresentResponse?.lststud?.any((attendance) {
                          //         DateTime attendanceDate = DateTime.parse(attendance.aTTDATE!).toLocal();
                          //         DateTime selectedDateWithoutTime = DateTime(day.year, day.month, day.day);
                          //         return selectedDateWithoutTime.isAtSameMomentAs(attendanceDate) &&
                          //             attendance.pRESENT == 'A';
                          //       }) ??
                          //       false;
                          //
                          //   if (isPresent) {
                          //     return Container(
                          //       width: double.infinity,
                          //       decoration: const BoxDecoration(color: Colors.green),
                          //       child: Column(
                          //         children: [
                          //           const SizedBox(height: 5),
                          //           Text('${day.day}', style: const TextStyle(color: Colors.white)),
                          //         ],
                          //       ),
                          //     );
                          //   } else if (isAbsent) {
                          //     return Container(
                          //       width: double.infinity,
                          //       decoration: const BoxDecoration(color: Colors.red),
                          //       child: Column(
                          //         children: [
                          //           const SizedBox(height: 5),
                          //           Text('${day.day}', style: const TextStyle(color: Colors.white)),
                          //         ],
                          //       ),
                          //     );
                          //   } else {
                          //     return Container(
                          //       width: double.infinity,
                          //       decoration: BoxDecoration(
                          //         color:
                          //             day.weekday == DateTime.sunday ? const Color(0xFF41B3B3) : Colors.grey,
                          //       ),
                          //       child: Column(
                          //         children: [
                          //           const SizedBox(height: 5),
                          //           Text('${day.day}', style: const TextStyle(color: Colors.white)),
                          //         ],
                          //       ),
                          //     );
                          //   }
                          // })

                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      colorWithTitle(Colors.orange, 'Activity'),
                      colorWithTitle(const Color(0xFF41B3B3), 'Holiday'),
                      colorWithTitle(Colors.grey, 'Non-Marked')
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      colorWithTitle(Colors.green, 'Marked'),
                      colorWithTitle(Colors.purple, 'Half-day'),
                      colorWithTitle(Colors.lightBlue, 'Leave'),
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      colorWithTitle(Colors.red[900]!, 'Absent'),
                    ]),
                  ],
                ));
          });
        });
  }

  Color? getColorForAttendanceStatus(String presentStatus) {
    switch (presentStatus) {
      case 'P':
        return Colors.green;
      case 'A':
        return Colors.red[900];
      case 'H':
        return Colors.purple;
      case 'L':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }

  Container buildMarkedContainer(DateTime day, DateTime formattedDay, StudentAttendanceProvider model) {
    var presentStatus = model.absentPresentResponse?.lststud?.firstWhere(
      (attendance) {
        DateTime attendanceDate = DateTime.parse(attendance.aTTDATE!).toLocal();
        DateTime selectedDateWithoutTime = DateTime(day.year, day.month, day.day);
        return selectedDateWithoutTime.isAtSameMomentAs(attendanceDate);
      },
    ).pRESENT;

    Color? backgroundColor = getColorForAttendanceStatus(presentStatus!);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: backgroundColor),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text('${day.day}', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 5),
          Text(
            model.allEvents.containsKey(formattedDay)
                ? model.allEvents[formattedDay]!.map((event) => event.eventName).join(', ')
                : '',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Container buildDefaultContainer(DateTime day) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: day.weekday == DateTime.sunday ? const Color(0xFF41B3B3) : Colors.grey,
      ),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text('${day.day}', style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Container buildEventContainer(DateTime day, List<CalendarEvent> eventsForDay, Color backgroundColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: backgroundColor),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text('${day.day}', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 5),
          Text(
            eventsForDay.map((event) => event.eventName).join(', '),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Color getColorForEvent(List<CalendarEvent> eventsForDay) {
    // Check for any 'H' type event
    if (eventsForDay.any((event) => event.type == 'H')) {
      return Colors.purple; // Use the color for 'H' type event
    } else {
      // Check for any 'A' type event
      if (eventsForDay.any((event) => event.type == 'A')) {
        return Colors.red; // Use the color for 'A' type event
      }
      // Add more cases as needed for other event types
    }

    // Default color if no marked event
    return Colors.grey;
  }

  colorWithTitle(Color color, String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Container(width: 28, height: 28, color: color),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
    );
  }

  buildDayContent(DateTime day, DateTime formattedDay, StudentAttendanceProvider model, List<CalendarEvent> eventsForDay, bool isSunday) {


    // Display all event names for the day
    String eventNames = eventsForDay.map((event) => event.eventName).join(', ');

    // Example: Check attendance status and update background color
    String attendanceStatus = getAttendanceStatusForDay(formattedDay, model);
    Color? backgroundColor;
    switch (attendanceStatus) {
      case 'A':
        backgroundColor =Colors.red[900];
        break;
      case 'L':
        backgroundColor = Colors.lightBlue;
        break;
      case 'H':
        backgroundColor = Colors.purple;
        break;
      case 'P':
        backgroundColor = Colors.green;
        break;
      default:
        backgroundColor = isSunday ? const Color(0xFF41B3B3):Colors.grey;
    }

    // Return the day content with attendance styling
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: backgroundColor),
      child: Column(
        children: [
          const SizedBox(height: 5),
          Text('${day.day}', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 5),
          Text(
            eventNames,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }

// Helper function to get attendance status for a specific day
  String getAttendanceStatusForDay(DateTime formattedDay, StudentAttendanceProvider model) {
    // Your existing code for checking attendance status here
    // ...
    // Example: Replace this with your logic to get attendance status for the day
    return model.absentPresentResponse?.lststud?.firstWhere(
          (attendance) {
        DateTime attendanceDate = DateTime.parse(attendance.aTTDATE!).toLocal();
        return formattedDay.isAtSameMomentAs(attendanceDate);
      },
      orElse: () => Lststud(aTTDATE: '', pRESENT: ''),
    ).pRESENT ?? '';
  }


}
