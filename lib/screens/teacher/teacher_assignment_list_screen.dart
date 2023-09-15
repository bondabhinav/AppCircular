import 'package:flexischool/common/constants.dart';
import 'package:flexischool/models/teacher/teacher_assignment_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/teacher/teacher_assignment_list_provider.dart';
import 'package:flexischool/screens/assignment_detail_screen.dart';
import 'package:flexischool/screens/assignmentform.dart';
import 'package:flexischool/utils/date_formater.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherAssignmentListScreen extends StatefulWidget {
  final int employeeId;

  const TeacherAssignmentListScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<TeacherAssignmentListScreen> createState() => _TeacherAssignmentListScreenState();
}

class _TeacherAssignmentListScreenState extends State<TeacherAssignmentListScreen> {
  TeacherAssignmentListProvider? teacherAssignmentListProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    debugPrint('init called again ');
    teacherAssignmentListProvider = TeacherAssignmentListProvider();
    teacherAssignmentListProvider?.fetchTeacherAssignmentListData(
        employeeId: widget.employeeId, endDate: Constants.currentDate, fromDate: Constants.currentDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => teacherAssignmentListProvider,
        builder: (context, child) {
          return Consumer<TeacherAssignmentListProvider>(builder: (context, model, _) {
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
                actions: [
                  IconButton(
                    onPressed: () {
                      model.getDateRange(context).then((value) {
                        if (value.isNotEmpty) {
                          model.fetchTeacherAssignmentListData(
                              employeeId: widget.employeeId,
                              endDate: model.endDate,
                              fromDate: model.startDate);
                        }
                      });
                    },
                    icon: const Icon(Icons.filter_alt),
                    color: Colors.white,
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AssignmentForm(
                                    employeeId: widget.employeeId,
                                  )));
                    },
                    icon: const Icon(Icons.add),
                    color: Colors.white,
                  ),
                ],
              ),
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          height: 50,
                          padding: const EdgeInsets.only(left: 10),
                          margin: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration:
                              BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all()),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_outlined,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 5),
                              Text("${model.startDate} - ${model.endDate}",
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
                        Expanded(
                          child: (model.teacherAssignmentListModel == null ||
                                  model.teacherAssignmentListModel!.lstAssignment == null)
                              ? const SizedBox.shrink()
                              : model.message != null
                                  ? Center(
                                      child: Text(
                                      model.message ?? "",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ))
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: model.teacherAssignmentListModel!.lstAssignment!.length,
                                      itemBuilder: (context, index) => listItem(
                                          model: model,
                                          assignment: model.teacherAssignmentListModel!.lstAssignment![index],
                                          documentOnTap: () {
                                            if (model.teacherAssignmentListModel!.lstAssignment![index]
                                                .lstCircularFile!.isNotEmpty) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  var data =
                                                      model.teacherAssignmentListModel!.lstAssignment![index];
                                                  return AlertDialog(
                                                    title: const Text('Document'),
                                                    content: SizedBox(
                                                      width: double.maxFinite,
                                                      child: LayoutBuilder(builder:
                                                          (BuildContext context, BoxConstraints constraints) {
                                                        return ListView.builder(
                                                            shrinkWrap: true,
                                                            itemBuilder: (context, index) => ListTile(
                                                                  contentPadding: const EdgeInsets.all(0),
                                                                  title: Text(
                                                                      data.lstCircularFile![index].fILENAME ??
                                                                          ""),
                                                                  trailing: IconButton(
                                                                      onPressed: () {
                                                                        model
                                                                            .requestWritePermission(context)
                                                                            .then((_) {
                                                                          model.downloadFile(
                                                                              context,
                                                                              data.lstCircularFile![index]
                                                                                      .fILENAME ??
                                                                                  "");
                                                                        });
                                                                      },
                                                                      icon: const Icon(Icons.download)),
                                                                ),
                                                            itemCount: data.lstCircularFile!.length);
                                                      }),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context).pop();
                                                        },
                                                        child: const Text('Close'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                            //  });
                                          },
                                          showMoreOnTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => AssignmentDetailScreen(
                                                      sessionId: Constants.sessionId,
                                                        assignmentId: model.teacherAssignmentListModel!
                                                            .lstAssignment![index].aPPASSIGNMENTID!)));
                                          })),
                        ),
                      ],
                    ),
                  ),
                  if (loaderProvider.isLoading) const CustomLoader(),
                ],
              ),
            );
          });
        });
  }

  Widget listItem(
      {void Function()? documentOnTap,
      void Function()? showMoreOnTap,
      required TeacherAssignmentListProvider model,
      required LstAssignment assignment}) {
    return Opacity(
      opacity: assignment.aCTIVE == "Y" ? 1.0 : 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
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
                    margin: const EdgeInsets.only(right: 10),
                    //   decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(10)),
                    child: Text(assignment.sUBJECTNAME ?? "",
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Assignment Date: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Montserrat Regular",
                              color: Colors.black,
                            )),
                        Text(DateTimeUtils.formatDateTime(assignment.aSSIGNMENTDATE ?? ""),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Montserrat Regular",
                              color: Colors.orange,
                            )),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Start Date: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Montserrat Regular",
                              color: Colors.black,
                            )),
                        Text(DateTimeUtils.formatDateTime(assignment.sTARTDATE ?? ""),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Montserrat Regular",
                              color: Colors.orange,
                            )),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Submission Date: ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Montserrat Regular",
                              color: Colors.black,
                            )),
                        Text(DateTimeUtils.formatDateTime(assignment.eNDDATE ?? ""),
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
              ],
            ),
            const SizedBox(height: 5),
            Text(model.getContentAsHTML(assignment.aSSIGNMENTDETAILS ?? ""),
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
            //     data: model.getContentAsHTML(assignment.aSSIGNMENTDETAILS ?? ""),
            //   ),
            // ),
            const SizedBox(height: 5),
            Row(
              children: [
                if (assignment.lstCircularFile!.isNotEmpty)
                  InkWell(
                      onTap: documentOnTap,
                      child: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.cloud_download,
                            color: Colors.white,
                          ))),
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
            ),

            const SizedBox(height: 5),

            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Class: ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              )),
                          Text(assignment.cLASSDESC ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.normal,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              )),
                        ],
                      ),
                      if (assignment.lstCircularSection != null)
                        SizedBox(
                          height: 30,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Section: ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: "Montserrat Regular",
                                    color: Colors.black,
                                  )),
                              Expanded(
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: assignment.lstCircularSection!.length,
                                  itemBuilder: (context, index) {
                                    return Text(
                                      assignment.lstCircularSection![index].sECTIONDESC ?? "",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: "Montserrat Regular",
                                        color: Colors.black,
                                      ),
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) {
                                    return const Text(', ');
                                  },
                                ),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: assignment.aCTIVE == "Y",
                      onChanged: assignment.aCTIVE == "Y"
                          ? (newValue) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Action'),
                                    content: const Text('Are you sure you want to inactive this assignment?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          model.inActiveAssignment(assignment, context);
                                        },
                                        child: const Text('Yes'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          : null,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                     Text(assignment.aCTIVE == "Y"?'Active':'Inactive')
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
