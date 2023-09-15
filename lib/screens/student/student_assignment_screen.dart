import 'dart:async';

import 'package:flexischool/common/constants.dart';
import 'package:flexischool/models/student/student_assignment_model.dart';
import 'package:flexischool/providers/student/student_assignment_provider.dart';
import 'package:flexischool/screens/assignment_detail_screen.dart';
import 'package:flexischool/utils/date_formater.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class StudentAssignmentCalenderWithList extends StatefulWidget {
  final int employeeId;

  const StudentAssignmentCalenderWithList({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<StudentAssignmentCalenderWithList> createState() => _StudentAssignmentCalenderWithListState();
}

class _StudentAssignmentCalenderWithListState extends State<StudentAssignmentCalenderWithList> {
  StudentAssignmentProvider? studentAssignmentProvider;

  @override
  void initState() {
    studentAssignmentProvider = StudentAssignmentProvider();
    studentAssignmentProvider?.events = {};
    studentAssignmentProvider?.eventsStreamController =
        StreamController<Map<DateTime, List<dynamic>>>.broadcast();

    studentAssignmentProvider!.getAssignmentDates(
        year: DateTime.now().year.toString(),
        month: DateTime.now().month.toString(),
        dateTime: DateTime.now());
    studentAssignmentProvider!.fetchStudentAssignmentData();
    super.initState();
  }

  @override
  void dispose() {
    studentAssignmentProvider?.eventsStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('build method called again');
    return ChangeNotifierProvider(
        create: (_) => studentAssignmentProvider,
        builder: (context, child) {
          return Consumer<StudentAssignmentProvider>(builder: (context, model, _) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text(
                  'Assignment',
                  style: TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white),
              ),
              body: Column(
                children: [
                  StreamBuilder<Map<DateTime, List<dynamic>>>(
                      stream: model.eventsStreamController.stream,
                      initialData: model.events,
                      builder: (context, snapshot) {
                        final allEvents = snapshot.data ?? {};
                        return TableCalendar(
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          headerStyle: const HeaderStyle(formatButtonVisible: false),
                          onPageChanged: (dateTime) {
                            debugPrint('format change $dateTime');
                            model.getAssignmentDates(
                                year: dateTime.year.toString(),
                                month: dateTime.month.toString(),
                                dateTime: dateTime);
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              for (DateTime d in allEvents.keys) {
                                if (day.day == d.day && day.month == d.month && day.year == d.year) {
                                  return Container(
                                    margin: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Color(0xffc6c627),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              }
                              return null;
                            },
                          ),
                          focusedDay: model.focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(model.selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            if (!isSameDay(model.selectedDay, selectedDay)) {
                              model.updateDate(selectedDay, focusedDay);
                            }
                          },
                        );
                      }),
                  Expanded(
                    child: (model.studentAssignmentModel == null ||
                            model.studentAssignmentModel!.assignment == null)
                        ? const Center(child: CircularProgressIndicator())
                        : model.message != null
                            ? Center(
                                child: Text(
                                model.message ?? "",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ))
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: model.studentAssignmentModel!.assignment!.length > 5
                                    ? 5
                                    : model.studentAssignmentModel!.assignment!.length,
                                itemBuilder: (context, index) => listItem(model,
                                    circular: model.studentAssignmentModel!.assignment![index],
                                    documentOnTap: () {
                                  // if (model.studentAssignmentModel!.assignment![index]
                                  //     .lstCircularFile!.isNotEmpty) {
                                  //   showDialog(
                                  //     context: context,
                                  //     barrierDismissible: false,
                                  //     builder: (BuildContext context) {
                                  //       var data = model
                                  //           .studentAssignmentModel!.assignment![index];
                                  //       if (data.fLAG == "N") {
                                  //         model.updateCircularFlag(
                                  //             data.aPPCIRCULARID.toString());
                                  //       }
                                  //       return AlertDialog(
                                  //         title: const Text('Document'),
                                  //         content: SizedBox(
                                  //           width: double.maxFinite,
                                  //           child: LayoutBuilder(builder: (BuildContext context,
                                  //               BoxConstraints constraints) {
                                  //             return ListView.builder(
                                  //                 shrinkWrap: true,
                                  //                 itemBuilder: (context, index) => ListTile(
                                  //                   contentPadding: const EdgeInsets.all(0),
                                  //                   title: Text(data.lstCircularFile![index]
                                  //                       .fILENAME ??
                                  //                       ""),
                                  //                   trailing: IconButton(
                                  //                       onPressed: () {
                                  //                         model
                                  //                             .requestWritePermission(
                                  //                             context)
                                  //                             .then((_) {
                                  //                           model.downloadFile(
                                  //                               context,
                                  //                               data.lstCircularFile![index]
                                  //                                   .fILENAME ??
                                  //                                   "");
                                  //                         });
                                  //                       },
                                  //                       icon: const Icon(Icons.download)),
                                  //                 ),
                                  //                 itemCount: data.lstCircularFile!.length);
                                  //           }),
                                  //         ),
                                  //         actions: [
                                  //           TextButton(
                                  //             onPressed: () {
                                  //               Navigator.of(context).pop();
                                  //             },
                                  //             child: const Text('Close'),
                                  //           ),
                                  //         ],
                                  //       );
                                  //     },
                                  //   );
                                  // }
                                }, showMoreOnTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AssignmentDetailScreen(
                                            sessionId: Constants.sessionId,
                                              assignmentId: model.studentAssignmentModel!.assignment![index]
                                                  .aPPASSIGNMENTID!)));

                                  // showScrollableTextDialog(
                                  //     model: model,
                                  //     complete: () {
                                  //       if (model.studentAssignmentModel!.assignment![index]
                                  //           .fLAG ==
                                  //           "N") {
                                  //         model.updateFlagStatus(model
                                  //             .studentAssignmentModel!.assignment![index]);
                                  //       }
                                  //     },
                                  //     context: context,
                                  //     data:
                                  //     model.studentAssignmentModel!.assignment![index]);
                                }),
                                separatorBuilder: (BuildContext context, int index) {
                                  return const Divider(
                                    height: 1.5,
                                    thickness: 1,
                                  );
                                },
                              ),
                  ),
                ],
              ),
            );
          });
        });
  }

  Widget listItem(StudentAssignmentProvider model,
      {required Assignment circular, void Function()? documentOnTap, void Function()? showMoreOnTap}) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(8),
      decoration:
          BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  //   padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 10),
                  //   decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(10)),
                  child: Text(circular.sUBJECT_NAME ?? "",
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat Regular",
                        color: Colors.black,
                      )),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Submission date:",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Montserrat Regular",
                        color: Colors.black,
                      )),
                  Text(DateTimeUtils.formatNextDateTime(circular.eNDDATE ?? ""),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Montserrat Regular",
                        color: Colors.orange,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),

          Text(model.getContentAsHTML(circular.aSSIGNMENTDETAILS ?? ""),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                fontFamily: "Montserrat Regular",
                color: Colors.black,
              )),
          // SizedBox(
          //   height: 60,
          //   child: Html(
          //     shrinkWrap: true,
          //     data: model.getContentAsHTML(circular.aSSIGNMENTDETAILS ?? ""),
          //   ),
          // ),
          const SizedBox(height: 5),
          Row(
            children: [
              // if (circular.lstCircularFile!.isNotEmpty)
              //   InkWell(
              //       onTap: documentOnTap,
              //       child: CircleAvatar(
              //           backgroundColor:
              //           circular.fLAG == 'N' ? Colors.deepPurple : Colors.blue.withOpacity(0.8),
              //           child: Icon(
              //             Icons.cloud_download,
              //             color: Colors.white,
              //           ))),
              const Spacer(),
              MaterialButton(
                onPressed: showMoreOnTap,
                color: Colors.blue,
                child: const Text("View more",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Montserrat Regular",
                      color: Colors.white,
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
