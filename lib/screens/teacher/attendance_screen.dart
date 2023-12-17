import 'package:flexischool/models/teacher/get_event_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/teacher/attendance_provider.dart';
import 'package:flexischool/screens/teacher/student_list_for_attendance_screen.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AttendanceScreen extends StatefulWidget {
  final int employeeId;

  const AttendanceScreen({super.key, required this.employeeId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  AttendanceProvider? attendanceProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    attendanceProvider?.fetchClassData(teacherId: widget.employeeId);
    attendanceProvider?.fetchSectionData(teacherId: widget.employeeId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(builder: (context, model, _) {
      return WillPopScope(
        onWillPop: () {
          model.disposeAndNavigateToDashboard(context);
          Navigator.pop(context);
          return Future.value(true);
        },
        child: Stack(
          children: [
            Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      model.disposeAndNavigateToDashboard(context);
                      Navigator.pop(context);
                    }),
                centerTitle: true,
                title: const Text('Attendance', style: TextStyle(color: Colors.white)),
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            model.getClassResponse.cLASSandSECTION == null
                                ? const SizedBox.shrink()
                                : Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Class*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            )),
                                        const SizedBox(height: 5),
                                        Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(), borderRadius: BorderRadius.circular(8)),
                                          child: DropdownButton(
                                            padding: const EdgeInsets.only(left: 10),
                                            value: model.selectedClass,
                                            underline: const SizedBox(),
                                            isExpanded: true,
                                            hint: const Text('Select a class'),
                                            items: model.getClassResponse.cLASSandSECTION
                                                ?.map((item) => DropdownMenuItem(
                                                      value: item.classId,
                                                      child: Text(item.cLASSDESC ?? ""),
                                                    ))
                                                .toList(),
                                            onChanged: (int? value) {
                                              if (value != null) {
                                                model.updateSelectedClass(value);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(width: 5),
                            (model.getSectionResponse == null ||
                                    model.getSectionResponse!.cLASSandSECTION!.isEmpty)
                                ? const SizedBox.shrink()
                                : Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text('Section*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            )),
                                        const SizedBox(height: 5),
                                        Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              border: Border.all(), borderRadius: BorderRadius.circular(8)),
                                          child: DropdownButton(
                                            padding: const EdgeInsets.only(left: 10),
                                            value: model.selectedSection,
                                            underline: const SizedBox(),
                                            isExpanded: true,
                                            hint: const Text('Select a class'),
                                            items: model.getSectionResponse?.cLASSandSECTION
                                                ?.map((item) => DropdownMenuItem(
                                                      value: item.sECTIONID,
                                                      child: Text(item.sECTIONDESC ?? ""),
                                                    ))
                                                .toList(),
                                            onChanged: (int? value) {
                                              if (value != null) {
                                                model.updateSelectedSection(value);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 15),
                      //   child: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const Text('Date',
                      //           style: TextStyle(
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.normal,
                      //             fontFamily: "Montserrat Regular",
                      //             color: Colors.black,
                      //           )),
                      //       InkWell(
                      //         onTap: () {
                      //           model.selectDate(context: context);
                      //         },
                      //         child: Container(
                      //           alignment: Alignment.centerLeft,
                      //           height: 50,
                      //           padding: const EdgeInsets.only(left: 10),
                      //           margin: const EdgeInsets.only(top: 13, bottom: 10),
                      //           decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(10), border: Border.all()),
                      //           child: Row(
                      //             children: [
                      //               const Icon(
                      //                 Icons.calendar_month_outlined,
                      //                 color: Colors.black,
                      //               ),
                      //               const SizedBox(width: 5),
                      //               Text(model.date,
                      //                   textAlign: TextAlign.left,
                      //                   style: const TextStyle(
                      //                     fontSize: 14,
                      //                     fontWeight: FontWeight.w600,
                      //                     fontFamily: "Montserrat Regular",
                      //                     color: Colors.black,
                      //                   )),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      const SizedBox(height: 10),

                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black), // Adjust the color as needed
                        ),
                        child: TableCalendar(
                            availableGestures: AvailableGestures.horizontalSwipe,
                            focusedDay: model.focusedDay,
                            // enabledDayPredicate: (DateTime day) {
                            //   return day.isBefore(DateTime.now());
                            // },
                            // selectedDayPredicate: (day) {
                            //   return isSameDay(model.selectedDay, day);
                            // },
                            onDaySelected: (selectedDay, focusedDay) {
                              if (selectedDay.isAfter(DateTime.now())) {
                                // Do nothing or show a message indicating that the date is in the future
                                return;
                              }

                              // Check if the day is Sunday
                              bool isSunday = selectedDay.weekday == DateTime.sunday;

                              // Check if the day is marked with attendance
                              bool isMarked =
                                  model.markedAttendanceResponse?.getAttendanceStud?.any((attendance) {
                                        DateTime attendanceDate =
                                            DateTime.parse(attendance.aTTDATE!).toLocal();
                                        DateTime selectedDateWithoutTime =
                                            DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

                                        return selectedDateWithoutTime.isAtSameMomentAs(attendanceDate);
                                      }) ??
                                      false;

                              // Check if the day has events of type 'H'
                              DateTime formattedDay =
                                  DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                              bool hasEventTypeH = false;

                              if (model.allEvents.containsKey(formattedDay)) {
                                List<CalendarEvent> eventsForDay = model.allEvents[formattedDay]!;
                                String eventType = eventsForDay.isNotEmpty ? eventsForDay[0].type : '';
                                // Check if eventType is 'H'
                                hasEventTypeH = eventType == 'H';
                              }

                              if (hasEventTypeH || isSunday) {
                              } else if (isMarked) {
                                model.updateDate(selectedDay, focusedDay);
                                model.getMarkedStudentAttendanceData().then((value) {
                                  if (value!.lststud!.isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => StudentListForAttendanceScreen(
                                                teacherId: widget.employeeId, isMarked: true))).then((value) {
                                      if (value != null) {
                                        debugPrint(
                                            'yes value is true ${model.tempDateTime.month.toString()}');
                                        model.getEventsDates();
                                        model.getMarkedAttendance();
                                      }
                                    });
                                  }
                                });
                              } else {
                                model.updateDate(selectedDay, focusedDay);
                                model.getStudentData().then((value) {
                                  if (value!.aDMSTUDREGISTRATION!.isNotEmpty) {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => StudentListForAttendanceScreen(
                                                teacherId: widget.employeeId,
                                                isMarked: false))).then((value) {
                                      if (value != null) {
                                        debugPrint(
                                            'yes value is true 2 ${model.tempDateTime.month.toString()}');
                                        model.getEventsDates();
                                        model.getMarkedAttendance();
                                      }
                                    });
                                  }
                                });
                              }
                            },
                            firstDay: DateTime.utc(2010, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                            onPageChanged: (dateTime) {
                              model.updateMonth(dateTime);
                              model.getEventsDates();
                              model.getMarkedAttendance();
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
                                selectedDecoration:
                                    BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, _) {
                                DateTime formattedDay = DateTime(day.year, day.month, day.day);
                                bool isMarked =
                                    model.markedAttendanceResponse?.getAttendanceStud?.any((attendance) {
                                          DateTime attendanceDate =
                                              DateTime.parse(attendance.aTTDATE!).toLocal();
                                          DateTime selectedDateWithoutTime =
                                              DateTime(day.year, day.month, day.day);
                                          return selectedDateWithoutTime.isAtSameMomentAs(attendanceDate);
                                        }) ??
                                        false;

                                if (isMarked) {
                                  return Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(color: Colors.green),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        Text('${day.day}', style: const TextStyle(color: Colors.white)),
                                        const SizedBox(height: 5),
                                        Text(
                                          model.allEvents.containsKey(formattedDay)
                                              ? model.allEvents[formattedDay]!
                                                  .map((event) => event.eventName)
                                                  .join(', ')
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
                                      // Add more cases as needed for other event types
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
                                      color: day.weekday == DateTime.sunday
                                          ? const Color(0xFF41B3B3)
                                          : Colors.grey),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 5),
                                      Text('${day.day}', style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                );
                              },
                            )

                            // calendarBuilders: CalendarBuilders(defaultBuilder: (context, day, _) {
                            //   DateTime formattedDay = DateTime(day.year, day.month, day.day);
                            //   bool isMarked =
                            //       model.markedAttendanceResponse?.getAttendanceStud?.any((attendance) {
                            //             DateTime attendanceDate =
                            //                 DateTime.parse(attendance.aTTDATE!).toLocal();
                            //             DateTime selectedDateWithoutTime =
                            //                 DateTime(day.year, day.month, day.day);
                            //
                            //             return selectedDateWithoutTime.isAtSameMomentAs(attendanceDate);
                            //           }) ??
                            //           false;
                            //
                            //   if (isMarked) {
                            //     return Container(
                            //       width: double.infinity,
                            //       decoration: const BoxDecoration(color: Colors.green),
                            //       child: Column(children: [
                            //         const SizedBox(height: 5),
                            //         Text('${day.day}', style: const TextStyle(color: Colors.white))
                            //       ]),
                            //     );
                            //   }
                            //
                            //   if (model.allEvents.containsKey(formattedDay)) {
                            //     List<CalendarEvent> eventsForDay = model.allEvents[formattedDay]!;
                            //     String eventType = eventsForDay.isNotEmpty ? eventsForDay[0].type : '';
                            //     Color backgroundColor = model.getColorForEventType(eventType);
                            //     bool isSunday = day.weekday == DateTime.sunday;
                            //
                            //     if (isSunday) {
                            //       backgroundColor = const Color(0xFF41B3B3);
                            //     }
                            //     return Container(
                            //         width: double.infinity,
                            //         decoration: BoxDecoration(color: backgroundColor),
                            //         child: Column(children: [
                            //           const SizedBox(height: 5),
                            //           Text('${day.day}', style: const TextStyle(color: Colors.white)),
                            //           const SizedBox(height: 5),
                            //           Text(eventsForDay.map((event) => event.eventName).join(', '),
                            //               textAlign: TextAlign.center,
                            //               overflow: TextOverflow.ellipsis,
                            //               maxLines: 2,
                            //               style: const TextStyle(color: Colors.white, fontSize: 10))
                            //         ]));
                            //   }
                            //   return Container(
                            //       width: double.infinity,
                            //       decoration: BoxDecoration(
                            //           color: day.weekday == DateTime.sunday
                            //               ? const Color(0xFF41B3B3)
                            //               : Colors.grey),
                            //       child: Column(children: [
                            //         const SizedBox(height: 5),
                            //         Text('${day.day}', style: const TextStyle(color: Colors.white))
                            //       ]));
                            // })

                            ),
                      ),
                      const SizedBox(height: 10),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                        colorWithTitle(Colors.orange, 'Activity'),
                        colorWithTitle(const Color(0xFF41B3B3), 'Holiday'),
                        colorWithTitle(Colors.grey, 'Non-Marked')
                      ]),

                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                          // colorWithTitle(Colors.green, 'Weekly Off'),
                          colorWithTitle(Colors.green, 'Marked')
                        ]),
                      ),

                      // (model.getSectionResponse == null ||
                      //         model.getSectionResponse!.cLASSandSECTION!.isEmpty)
                      //     ? const SizedBox.shrink()
                      //     : Column(
                      //         crossAxisAlignment: CrossAxisAlignment.start,
                      //         children: [
                      //           const SizedBox(height: 15),
                      //           const Text('Section',
                      //               style: TextStyle(
                      //                 fontSize: 14,
                      //                 fontWeight: FontWeight.normal,
                      //                 fontFamily: "Montserrat Regular",
                      //                 color: Colors.black,
                      //               )),
                      //           const SizedBox(height: 5),
                      //           Container(
                      //             decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(5.0),
                      //               border: Border.all(),
                      //             ),
                      //             child: LayoutBuilder(builder: (context, constraints) {
                      //               return ConstrainedBox(
                      //                 constraints: const BoxConstraints(
                      //                   minHeight: 0,
                      //                   maxHeight: 200,
                      //                 ).normalize(),
                      //                 child: SingleChildScrollView(
                      //                   child: Column(
                      //                     children:
                      //                         model.getSectionResponse!.cLASSandSECTION!.map((item) {
                      //                       final sectionId = item.sECTIONID;
                      //                       final sectionDesc = item.sECTIONDESC;
                      //                       return CheckboxListTile(
                      //                         title: Text(sectionDesc ?? ""),
                      //                         value: model.selectedSectionIds.contains(sectionId),
                      //                         onChanged: (bool? isChecked) {
                      //                           model.updateSelectedSection(
                      //                               sectionId!, isChecked ?? false);
                      //                         },
                      //                       );
                      //                     }).toList(),
                      //                   ),
                      //                 ),
                      //               );
                      //             }),
                      //           ),
                      //         ],
                      //       ),

                      // const SizedBox(height: 15),
                      // model.studentResponse == null
                      //     ? const SizedBox()
                      //     : DataTable(
                      //         decoration: BoxDecoration(
                      //             border: Border.all(), borderRadius: BorderRadius.circular(8)),
                      //         horizontalMargin: 3,
                      //         border: const TableBorder(),
                      //         columns: const [
                      //           DataColumn(
                      //               label: Padding(
                      //             padding: EdgeInsets.only(left: 8.0),
                      //             child: Text('Student Name',
                      //                 style: TextStyle(
                      //                   fontSize: 13,
                      //                   fontWeight: FontWeight.bold,
                      //                   fontFamily: "Montserrat Regular",
                      //                   color: Colors.black,
                      //                 )),
                      //           )),
                      //           DataColumn(
                      //               label: Text('Class',
                      //                   style: TextStyle(
                      //                     fontSize: 13,
                      //                     fontWeight: FontWeight.bold,
                      //                     fontFamily: "Montserrat Regular",
                      //                     color: Colors.black,
                      //                   ))),
                      //           DataColumn(
                      //               label: Text('Attendance',
                      //                   style: TextStyle(
                      //                     fontSize: 13,
                      //                     fontWeight: FontWeight.bold,
                      //                     fontFamily: "Montserrat Regular",
                      //                     color: Colors.black,
                      //                   ))),
                      //         ],
                      //         rows: List<DataRow>.generate(
                      //           model.studentResponse!.aDMSTUDREGISTRATION!.length,
                      //           (index) => DataRow(
                      //             cells: [
                      //               DataCell(Padding(
                      //                 padding: const EdgeInsets.only(left: 8.0),
                      //                 child: Text(
                      //                     model.studentResponse!.aDMSTUDREGISTRATION![index].fIRSTNAME ??
                      //                         "",
                      //                     style: const TextStyle(
                      //                       fontSize: 10,
                      //                       fontWeight: FontWeight.normal,
                      //                       fontFamily: "Montserrat Regular",
                      //                       color: Colors.black,
                      //                     )),
                      //               )),
                      //               DataCell(Text(
                      //                   "${model.studentResponse!.aDMSTUDREGISTRATION![index].cLASSDESC ?? ""}-${model.studentResponse!.aDMSTUDREGISTRATION![index].sECTIONDESC ?? ""}",
                      //                   style: const TextStyle(
                      //                     fontSize: 10,
                      //                     fontWeight: FontWeight.normal,
                      //                     fontFamily: "Montserrat Regular",
                      //                     color: Colors.black,
                      //                   ))),
                      //               DataCell(
                      //                 FittedBox(
                      //                   child: Container(
                      //                     padding: const EdgeInsets.only(left: 8, right: 10),
                      //                     margin: const EdgeInsets.only(top: 8, bottom: 5),
                      //                     decoration: BoxDecoration(
                      //                         border: Border.all(),
                      //                         borderRadius: BorderRadius.circular(8)),
                      //                     child: DropdownButton<String>(
                      //                       value: model
                      //                           .studentResponse!.aDMSTUDREGISTRATION![index].attendance,
                      //                       onChanged: (String? newValue) {
                      //                         model.updateAttendanceStatus(newValue!,
                      //                             model.studentResponse!.aDMSTUDREGISTRATION![index]);
                      //                       },
                      //                       items: <String>['Present', 'Absent', 'Half Day', 'Leave']
                      //                           .map<DropdownMenuItem<String>>(
                      //                         (String value) {
                      //                           return DropdownMenuItem<String>(
                      //                             value: value,
                      //                             child: Text(value),
                      //                           );
                      //                         },
                      //                       ).toList(),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      // const SizedBox(height: 15),
                      // if (model.studentResponse != null)
                      //   MaterialButton(
                      //       minWidth: double.infinity,
                      //       color: Colors.blueAccent,
                      //       height: 50,
                      //       onPressed: () {
                      //         if (model.studentAttendanceList.isNotEmpty) {
                      //           model.applyAttendance(teacherId: widget.employeeId).then((value) {
                      //             if (value != null) {
                      //               if (value.errorMessage == null) {
                      //                 ShowSnackBar.successToast(
                      //                     context: context,
                      //                     showMessage: 'Attendance marked successfully!');
                      //                 Navigator.pop(context);
                      //               } else {
                      //                 ShowSnackBar.error(
                      //                     context: context, showMessage: value.errorMessage.toString());
                      //               }
                      //             } else {
                      //               ShowSnackBar.error(
                      //                   context: context, showMessage: 'Something wents wrong');
                      //             }
                      //           });
                      //         }
                      //       },
                      //       child: const Text('Submit',
                      //           style: TextStyle(
                      //             fontSize: 16,
                      //             fontWeight: FontWeight.normal,
                      //             fontFamily: "Montserrat Regular",
                      //             color: Colors.white,
                      //           ))),
                      // const SizedBox(height: 20)
                    ],
                  ),
                ),
              ),
            ),
            if (loaderProvider.isLoading) const Center(child: CustomLoader())
          ],
        ),
      );
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

class EventData {
  final String eventName;
  final DateTime eventDate;
  final Color eventColor;

  EventData(this.eventName, this.eventDate, this.eventColor);
}
