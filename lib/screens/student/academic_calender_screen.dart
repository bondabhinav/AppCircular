import 'package:flexischool/models/teacher/get_event_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/student/academic_provider.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AcademicCalenderScreen extends StatefulWidget {
  const AcademicCalenderScreen({super.key});

  @override
  State<AcademicCalenderScreen> createState() => _AcademicCalenderScreenState();
}

class _AcademicCalenderScreenState extends State<AcademicCalenderScreen> {
  late AcademicProvider academicProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    academicProvider = AcademicProvider();
    academicProvider.getEventsDates();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => academicProvider,
        builder: (context, child) {
          return Consumer<AcademicProvider>(builder: (context, model, _) {
            return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                    title: const Text('Academic', style: TextStyle(color: Colors.white))),
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
                            model.getEventsDates();
                          },
                          rowHeight: 60,
                          daysOfWeekHeight: 30,
                          daysOfWeekStyle: DaysOfWeekStyle(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54), color: Colors.black54),
                              weekdayStyle: const TextStyle(
                                  fontFamily: "Montserrat Medium", color: Colors.white, fontSize: 14),
                              weekendStyle: const TextStyle(
                                  fontFamily: "Montserrat Medium", color: Colors.white, fontSize: 14)),
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
                              if (model.allEvents.containsKey(formattedDay)) {
                                List<CalendarEvent> eventsForDay = model.allEvents[formattedDay]!;
                                Color backgroundColor = Colors.grey;
                                bool isSunday = day.weekday == DateTime.sunday;
                                if (isSunday) {
                                  backgroundColor = const Color(0xFF41B3B3);
                                } else {
                                  // Check for any 'H' type event
                                  if (eventsForDay.any((event) => event.type == 'H')) {
                                    backgroundColor =
                                        const Color(0xFF41B3B3); // Use the color for 'H' type event
                                  } else {
                                    // Check for any 'A' type event
                                    if (eventsForDay.any((event) => event.type == 'A')) {
                                      backgroundColor = Colors.orange; // Use the color for 'A' type event
                                    }
                                  }
                                }
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
                              return Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      day.weekday == DateTime.sunday ? const Color(0xFF41B3B3) : Colors.grey,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 5),
                                    Text('${day.day}', style: const TextStyle(color: Colors.white)),
                                  ],
                                ),
                              );
                            },
                          )),
                    ),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                      colorWithTitle(Colors.orange, 'Activity'),
                      colorWithTitle(const Color(0xFF41B3B3), 'Holiday')
                    ]),
                  ],
                ));
          });
        });
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
}
