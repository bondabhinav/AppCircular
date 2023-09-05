import 'package:flexischool/common/config.dart';
import 'package:flexischool/models/teacher/teacher_circular_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/teacher/teacher_circular_list_provider.dart';
import 'package:flexischool/screens/circulars_screen.dart';
import 'package:flexischool/utils/date_formater.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeacherCircularListScreen extends StatefulWidget {
  final int employeeId;

  const TeacherCircularListScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<TeacherCircularListScreen> createState() => _TeacherCircularListScreenState();
}

class _TeacherCircularListScreenState extends State<TeacherCircularListScreen> {
  TeacherCircularListProvider? teacherCircularListProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    teacherCircularListProvider = TeacherCircularListProvider();
    teacherCircularListProvider?.fetchTeacherCircularListData(
        employeeId: widget.employeeId, endDate: Constants.currentDate, fromDate: Constants.currentDate);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => teacherCircularListProvider,
        builder: (context, child) {
          return Consumer<TeacherCircularListProvider>(builder: (context, model, _) {
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
                title: const Text('Circulars'),
                actions: [
                  IconButton(
                    onPressed: () {
                      model.getDateRange(context).then((value) {
                        if (value.isNotEmpty) {
                          model.fetchTeacherCircularListData(
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
                              builder: (context) => CircularsScreen(
                                    employeeId: widget.employeeId,
                                  ))).then((value) {
                        teacherCircularListProvider?.fetchTeacherCircularListData(
                            employeeId: widget.employeeId,
                            endDate: Constants.currentDate,
                            fromDate: Constants.currentDate);
                      });
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
                          child: (model.teacherCircularListResponse == null ||
                                  model.teacherCircularListResponse!.classlist == null)
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
                                      itemCount: model.teacherCircularListResponse!.classlist!.length,
                                      itemBuilder: (context, index) => listItem(
                                          circular: model.teacherCircularListResponse!.classlist![index],
                                          documentOnTap: () {
                                            // model
                                            //     .fetchStudentDocumentData(
                                            //         circularId: model.teacherCircularListResponse
                                            //             .classlist![index].aPPCIRCULARID!)
                                            //     .then((value) {
                                            if (model.teacherCircularListResponse!.classlist![index]
                                                .lstCircularFile!.isNotEmpty) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  var data =
                                                      model.teacherCircularListResponse!.classlist![index];
                                                  // if (data.fLAG == "N") {
                                                  //   model.updateCircularFlag(
                                                  //       data.aPPCIRCULARID.toString());
                                                  // }
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
                                              ).whenComplete(() {
                                                // if (model.teacherCircularListResponse!.classlist![index]
                                                //     .fLAG ==
                                                //     "N") {
                                                //   model.updateFlagStatus(model
                                                //       .teacherCircularListResponse!.classlist![index]);
                                                // }
                                              });
                                            }
                                            //  });
                                          },
                                          showMoreOnTap: () {
                                            showScrollableTextDialog(
                                                model: model,
                                                complete: () {
                                                  // if (model.teacherCircularListResponse!.classlist![index]
                                                  //     .fLAG ==
                                                  //     "N") {
                                                  //   model.updateFlagStatus(model
                                                  //       .teacherCircularListResponse!.classlist![index]);
                                                  // }
                                                },
                                                context: context,
                                                data: model.teacherCircularListResponse!.classlist![index]);
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

  void showScrollableTextDialog(
      {required BuildContext context,
      required void Function() complete,
      required TeacherCircularListProvider model,
      required Classlist data}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        //  if (data.fLAG == "N") model.updateCircularFlag(data.aPPCIRCULARID.toString());
        return AlertDialog(
          title: const Text('Description'),
          content: SingleChildScrollView(
            child: Text(data.aPPCIRCULARDESCRIPTION ?? ""),
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
    ).whenComplete(() {
      complete();
    });
  }

  Widget listItem(
      {required Classlist circular, void Function()? documentOnTap, void Function()? showMoreOnTap}) {
    return Container(
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
                child: Text(circular.aPPCIRCULARSUBJECT ?? "",
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat Regular",
                      color: Colors.black,
                    )),
              ),
              //  const Spacer(),
              Row(
                children: [
                  Text(DateTimeUtils.formatDateTime(circular.aPPCIRCULARDATE ?? ""),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Montserrat Regular",
                        color: Colors.orange,
                      )),
                  const SizedBox(width: 5),
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: circular.aCTIVE == 'Y' ? Colors.green : Colors.red,
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(circular.aPPCIRCULARDESCRIPTION ?? "",
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                fontFamily: "Montserrat Regular",
                color: Colors.black,
              )),
          const SizedBox(height: 5),
          Row(
            children: [
              if (circular.lstCircularFile!.isNotEmpty)
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
              Text(
                circular.cLASSDESC ?? "",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  fontFamily: "Montserrat Regular",
                  color: Colors.black,
                ),
              )
            ],
          ),
          if (circular.lstCircularSection != null)
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
                      itemCount: circular.lstCircularSection!.length,
                      itemBuilder: (context, index) {
                        return Text(
                          circular.lstCircularSection![index].sECTIONDESC ?? "",
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
    );

    // ListTile(
    //   contentPadding: const EdgeInsets.all(0),
    //   trailing: Text(circular.aPPCIRCULARDATE ?? "",
    //       style: const TextStyle(
    //         fontSize: 14,
    //         fontWeight: FontWeight.normal,
    //         fontFamily: "Montserrat Regular",
    //         color: Colors.black,
    //       )),
    //   // Column(
    //   //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //   //   children: [
    //   //     if (circular.lstCircularFile!.isNotEmpty)
    //   //       GestureDetector(onTap: documentOnTap, child: const Icon(CupertinoIcons.cloud_download)),
    //   //     GestureDetector(onTap: showMoreOnTap, child: const Icon(Icons.chrome_reader_mode))
    //   //   ],
    //   // ),
    //   leading: const CircleAvatar(
    //     radius: 30,
    //     child: Icon(Icons.blur_circular_outlined),
    //   ),
    //   title: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(circular.aPPCIRCULARSUBJECT ?? "",
    //           style: const TextStyle(
    //             fontSize: 16,
    //             fontWeight: FontWeight.bold,
    //             fontFamily: "Montserrat Regular",
    //             color: Colors.black,
    //           )),
    //     ],
    //   ),
    //   subtitle: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Text(circular.aPPCIRCULARDESCRIPTION ?? "",
    //           maxLines: 3,
    //           overflow: TextOverflow.ellipsis,
    //           style: const TextStyle(
    //             fontSize: 14,
    //             fontWeight: FontWeight.normal,
    //             fontFamily: "Montserrat Regular",
    //             color: Colors.black54,
    //           )),
    //       Row(
    //         children: [
    //           const CircleAvatar(child: Icon(Icons.cloud_download)),
    //           const Spacer(),
    //           MaterialButton(
    //             onPressed: () {},
    //             color: Colors.blue,
    //             child: const Text("View more",
    //                 style: TextStyle(
    //                   fontSize: 14,
    //                   fontWeight: FontWeight.normal,
    //                   fontFamily: "Montserrat Regular",
    //                   color: Colors.white,
    //                 )),
    //           ),
    //         ],
    //       )
    //     ],
    //   ),
    // );
  }
}
