import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/teacher/attendance_provider.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AttendanceScreen extends StatefulWidget {
  final int employeeId;

  const AttendanceScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  AttendanceProvider? attendanceProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    attendanceProvider = AttendanceProvider();
    attendanceProvider?.fetchClassData(teacherId: widget.employeeId);
    attendanceProvider?.fetchSectionData(teacherId: widget.employeeId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => attendanceProvider,
        builder: (context, child) {
          return Consumer<AttendanceProvider>(builder: (context, model, _) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context)),
                centerTitle: true,
                title: const Text('Attendance'),
              ),
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          Row(
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

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: "Montserrat Regular",
                                    color: Colors.black,
                                  )),
                              InkWell(
                                onTap: () {
                                  model.selectDate(context: context);
                                },
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  height: 50,
                                  padding: const EdgeInsets.only(left: 10),
                                  margin: const EdgeInsets.only(top: 13, bottom: 10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10), border: Border.all()),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_month_outlined,
                                        color: Colors.black,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(model.date,
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: "Montserrat Regular",
                                            color: Colors.black,
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),




                          /// Custom calender









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

                          const SizedBox(height: 15),
                          model.studentResponse == null
                              ? const SizedBox()
                              : DataTable(
                                  decoration: BoxDecoration(
                                      border: Border.all(), borderRadius: BorderRadius.circular(8)),
                                  horizontalMargin: 3,
                                  border: const TableBorder(),
                                  columns: const [
                                    DataColumn(
                                        label: Padding(
                                      padding: EdgeInsets.only(left: 8.0),
                                      child: Text('Student Name',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Montserrat Regular",
                                            color: Colors.black,
                                          )),
                                    )),
                                    DataColumn(
                                        label: Text('Class',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ))),
                                    DataColumn(
                                        label: Text('Attendance',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ))),
                                  ],
                                  rows: List<DataRow>.generate(
                                    model.studentResponse!.aDMSTUDREGISTRATION!.length,
                                    (index) => DataRow(
                                      cells: [
                                        DataCell(Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                              model.studentResponse!.aDMSTUDREGISTRATION![index].fIRSTNAME ??
                                                  "",
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: "Montserrat Regular",
                                                color: Colors.black,
                                              )),
                                        )),
                                        DataCell(Text(
                                            "${model.studentResponse!.aDMSTUDREGISTRATION![index].cLASSDESC ?? ""}-${model.studentResponse!.aDMSTUDREGISTRATION![index].sECTIONDESC ?? ""}",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ))),
                                        DataCell(
                                          FittedBox(
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 8, right: 10),
                                              margin: const EdgeInsets.only(top: 8, bottom: 5),
                                              decoration: BoxDecoration(
                                                  border: Border.all(),
                                                  borderRadius: BorderRadius.circular(8)),
                                              child: DropdownButton<String>(
                                                value: model
                                                    .studentResponse!.aDMSTUDREGISTRATION![index].attendance,
                                                onChanged: (String? newValue) {
                                                  model.updateAttendanceStatus(newValue!,
                                                      model.studentResponse!.aDMSTUDREGISTRATION![index]);
                                                },
                                                items: <String>['Present', 'Absent', 'Half Day', 'Leave']
                                                    .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                    return DropdownMenuItem<String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  },
                                                ).toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 15),
                          if (model.studentResponse != null)
                            MaterialButton(
                                minWidth: double.infinity,
                                color: Colors.blueAccent,
                                height: 50,
                                onPressed: () {
                                  if (model.studentAttendanceList.isNotEmpty) {
                                    model.applyAttendance(teacherId: widget.employeeId).then((value) {
                                      if (value != null) {
                                        if (value.errorMessage == null) {
                                          ShowSnackBar.successToast(
                                              context: context,
                                              showMessage: 'Attendance marked successfully!');
                                          Navigator.pop(context);
                                        } else {
                                          ShowSnackBar.error(
                                              context: context, showMessage: value.errorMessage.toString());
                                        }
                                      } else {
                                        ShowSnackBar.error(
                                            context: context, showMessage: 'Something wents wrong');
                                      }
                                    });
                                  }
                                },
                                child: const Text('Submit',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: "Montserrat Regular",
                                      color: Colors.white,
                                    ))),
                          const SizedBox(height: 20)
                        ],
                      ),
                    ),
                  ),
                  if (loaderProvider.isLoading) const CustomLoader(),
                ],
              ),
            );
          });
        });
  }
}
