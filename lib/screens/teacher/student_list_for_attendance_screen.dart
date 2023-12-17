import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/teacher/attendance_provider.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentListForAttendanceScreen extends StatefulWidget {
  final int teacherId;
  final bool isMarked;

  const StudentListForAttendanceScreen({super.key, required this.teacherId, required this.isMarked});

  @override
  State<StudentListForAttendanceScreen> createState() => _StudentListForAttendanceScreenState();
}

class _StudentListForAttendanceScreenState extends State<StudentListForAttendanceScreen> {
  AttendanceProvider? attendanceProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(builder: (context, model, _) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: MaterialButton(
                minWidth: double.infinity,
                color: Colors.blueAccent,
                height: 50,
                onPressed: () {
                  if (widget.isMarked) {
                    if (model.submittedMarkedList.isNotEmpty) {
                      model.applyMarkedAttendance().then((value) {
                        if (value != null) {
                          if (value.success ?? false) {
                            model.submittedMarkedList.clear();
                            ShowSnackBar.successToast(
                                context: context, showMessage: 'Attendance marked successfully!');
                          //  model.disposeAndNavigateToDashboard(context);
                            Navigator.pop(context,true);
                          } else {
                            ShowSnackBar.error(context: context, showMessage: value.errorMessage.toString());
                          }
                        } else {
                          ShowSnackBar.error(context: context, showMessage: 'Something wents wrong');
                        }
                      });
                    }
                  } else {
                    if (model.studentAttendanceList.isNotEmpty) {
                      model.applyAttendance(teacherId: widget.teacherId).then((value) {
                        if (value != null) {
                          if (value.errorMessage == null) {
                            ShowSnackBar.successToast(
                                context: context, showMessage: 'Attendance marked successfully!');
                        //    model.disposeAndNavigateToDashboard(context);
                            Navigator.pop(context,true);
                          } else {
                            ShowSnackBar.error(context: context, showMessage: value.errorMessage.toString());
                          }
                        } else {
                          ShowSnackBar.error(context: context, showMessage: 'Something wents wrong');
                        }
                      });
                    }
                  }
                },
                child: const Text('Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Montserrat Regular",
                      color: Colors.white,
                    ))),
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context,true)),
              centerTitle: true,
              title: const Text('Attendance', style: TextStyle(color: Colors.white)),
            ),
            body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 50, top: 5, left: 5, right: 5),
                  child: widget.isMarked
                      ? markedStudentDatatable(model)
                      : model.studentResponse == null
                          ? const SizedBox()
                          : unmarkedStudentDataTable(model)),
            ),
          ),
          if (loaderProvider.isLoading) const Center(child: CustomLoader())
        ],
      );
    });
  }

  Widget markedStudentDatatable(AttendanceProvider model) {
    return DataTable(
      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)),
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
        model.getMarkedStudentResponse!.lststud!.length,
        (index) => DataRow(
          cells: [
            DataCell(Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text((model.getMarkedStudentResponse!.lststud![index].sTUDNAME ?? "").toString().trim(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                    fontFamily: "Montserrat Regular",
                    color: Colors.black,
                  )),
            )),
            DataCell(Text(
                "${model.getMarkedStudentResponse!.lststud![index].cLASSDESC ?? ""}-${model.getMarkedStudentResponse!.lststud![index].sECTIONDESC ?? ""}",
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
                    decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButton<String>(
                        value: model.returnFullValueOfAttendance(
                            model.getMarkedStudentResponse!.lststud![index].pRESENT.toString()),
                        onChanged: (String? newValue) => model.updateMarkedAttendanceStatus(
                            newValue!, model.getMarkedStudentResponse!.lststud![index]),
                        items: <String>['Present', 'Absent', 'Half Day', 'Leave']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList())),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget unmarkedStudentDataTable(AttendanceProvider model) {
    return DataTable(
      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)),
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
              child: Text(model.studentResponse!.aDMSTUDREGISTRATION![index].fIRSTNAME ?? "",
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
                  decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)),
                  child: DropdownButton<String>(
                    value: model.studentResponse!.aDMSTUDREGISTRATION![index].attendance,
                    onChanged: (String? newValue) {
                      model.updateAttendanceStatus(
                          newValue!, model.studentResponse!.aDMSTUDREGISTRATION![index]);
                    },
                    items: <String>['Present', 'Absent', 'Half Day', 'Leave'].map<DropdownMenuItem<String>>(
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
    );
  }
}
