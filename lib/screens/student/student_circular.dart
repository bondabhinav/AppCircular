import 'package:flexischool/models/student/student_circular_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/student/student_circular_provider.dart';
import 'package:flexischool/utils/date_formater.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class StudentCircularScreen extends StatefulWidget {
  const StudentCircularScreen({super.key});

  @override
  State<StudentCircularScreen> createState() => _StudentCircularScreenState();
}

class _StudentCircularScreenState extends State<StudentCircularScreen> with SingleTickerProviderStateMixin {
  StudentCircularProvider? studentCircularProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    studentCircularProvider = StudentCircularProvider();
    studentCircularProvider?.tabController = TabController(length: 2, vsync: this);
    studentCircularProvider?.fetchStudentCircularData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => studentCircularProvider,
        builder: (context, child) {
          return Consumer<StudentCircularProvider>(builder: (context, model, _) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.pop(context)),
                centerTitle: true,
                title: const Text('Circulars', style: TextStyle(color: Colors.white)),
              ),
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          height: 45,
                          decoration: BoxDecoration(
                              color: Colors.blueAccent, borderRadius: BorderRadius.circular(25.0)),
                          child: TabBar(
                              controller: model.tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                              indicator: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25.0), color: Colors.lightBlueAccent),
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white,
                              tabs: const [Tab(text: 'Current'), Tab(text: 'Previous')]),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: TabBarView(
                            controller: model.tabController,
                            children: [
                              (model.studentCircularListResponse == null ||
                                      model.studentCircularListResponse!.classlist == null)
                                  ? const SizedBox.shrink()
                                  : model.message != null
                                      ? Center(
                                          child: Text(
                                          model.message ?? "",
                                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                                        ))
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: model.studentCircularListResponse!.classlist!.length > 5
                                              ? 5
                                              : model.studentCircularListResponse!.classlist!.length,
                                          itemBuilder: (context, index) => listItem(
                                              circular: model.studentCircularListResponse!.classlist![index],
                                              documentOnTap: () {
                                                // model
                                                //     .fetchStudentDocumentData(
                                                //         circularId: model.studentCircularListResponse
                                                //             .classlist![index].aPPCIRCULARID!)
                                                //     .then((value) {
                                                if (model.studentCircularListResponse!.classlist![index]
                                                    .lstCircularFile!.isNotEmpty) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext context) {
                                                      var data = model
                                                          .studentCircularListResponse!.classlist![index];
                                                      if (data.fLAG == "N") {
                                                        model.updateCircularFlag(
                                                            data.aPPCIRCULARID.toString());
                                                      }
                                                      return AlertDialog(
                                                        title: const Text('Document'),
                                                        content: SizedBox(
                                                          width: double.maxFinite,
                                                          child: LayoutBuilder(builder: (BuildContext context,
                                                              BoxConstraints constraints) {
                                                            return ListView.builder(
                                                                shrinkWrap: true,
                                                                itemBuilder: (context, index) => ListTile(
                                                                      contentPadding: const EdgeInsets.all(0),
                                                                      title: Text(data.lstCircularFile![index]
                                                                              .fILENAME ??
                                                                          ""),
                                                                      trailing: IconButton(
                                                                          onPressed: () {
                                                                            model
                                                                                .requestWritePermission(
                                                                                    context)
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
                                                    if (model.studentCircularListResponse!.classlist![index]
                                                            .fLAG ==
                                                        "N") {
                                                      model.updateFlagStatus(model
                                                          .studentCircularListResponse!.classlist![index]);
                                                    }
                                                  });
                                                }
                                                //  });
                                              },
                                              showMoreOnTap: () {
                                                showScrollableTextDialog(
                                                    model: model,
                                                    complete: () {
                                                      if (model.studentCircularListResponse!.classlist![index]
                                                              .fLAG ==
                                                          "N") {
                                                        model.updateFlagStatus(model
                                                            .studentCircularListResponse!.classlist![index]);
                                                      }
                                                    },
                                                    context: context,
                                                    data:
                                                        model.studentCircularListResponse!.classlist![index]);
                                              })),
                              (model.studentCircularListResponse == null ||
                                      model.studentCircularListResponse!.classlist == null)
                                  ? const SizedBox.shrink()
                                  : model.message != null
                                      ? Center(
                                          child: Text(
                                          model.message ?? "",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ))
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: model.studentCircularListResponse!.classlist!.length,
                                          itemBuilder: (context, index) => listItem(
                                              circular: model.studentCircularListResponse!.classlist![index],
                                              documentOnTap: () {
                                                // model
                                                //     .fetchStudentDocumentData(
                                                //         circularId: model.studentCircularListResponse
                                                //             .classlist![index].aPPCIRCULARID!)
                                                //     .then((value) {
                                                if (model.studentCircularListResponse!.classlist![index]
                                                    .lstCircularFile!.isNotEmpty) {
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext context) {
                                                      var data = model
                                                          .studentCircularListResponse!.classlist![index];
                                                      if (data.fLAG == "N") {
                                                        model.updateCircularFlag(
                                                            data.aPPCIRCULARID.toString());
                                                      }
                                                      return AlertDialog(
                                                        title: const Text('Document'),
                                                        content: SizedBox(
                                                          width: double.maxFinite,
                                                          child: LayoutBuilder(builder: (BuildContext context,
                                                              BoxConstraints constraints) {
                                                            return ListView.separated(
                                                                shrinkWrap: true,
                                                                itemBuilder: (context, index) => ListTile(
                                                                      contentPadding: const EdgeInsets.all(0),
                                                                      title: Text(data.lstCircularFile![index]
                                                                              .fILENAME ??
                                                                          ""),
                                                                      trailing: IconButton(
                                                                          onPressed: () async {
                                                                            PermissionStatus status =
                                                                                await Permission.storage
                                                                                    .request();
                                                                            if (status.isGranted) {
                                                                              if (context.mounted) {
                                                                                model.downloadFile(
                                                                                    context,
                                                                                    data
                                                                                            .lstCircularFile![
                                                                                                index]
                                                                                            .fILENAME ??
                                                                                        "");
                                                                              }
                                                                            }
                                                                          },
                                                                          icon: const Icon(Icons.download)),
                                                                    ),
                                                                separatorBuilder:
                                                                    (BuildContext context, int index) {
                                                                  return const Divider(
                                                                    color: Colors.tealAccent,
                                                                    thickness: 2,
                                                                  );
                                                                },
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
                                                    if (model.studentCircularListResponse!.classlist![index]
                                                            .fLAG ==
                                                        "N") {
                                                      model.updateFlagStatus(model
                                                          .studentCircularListResponse!.classlist![index]);
                                                    }
                                                  });
                                                }
                                              },
                                              showMoreOnTap: () {
                                                showScrollableTextDialog(
                                                    model: model,
                                                    complete: () {
                                                      if (model.studentCircularListResponse!.classlist![index]
                                                              .fLAG ==
                                                          "N") {
                                                        model.updateFlagStatus(model
                                                            .studentCircularListResponse!.classlist![index]);
                                                      }
                                                    },
                                                    context: context,
                                                    data:
                                                        model.studentCircularListResponse!.classlist![index]);
                                              })),
                            ],
                          ),
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
      required StudentCircularProvider model,
      required Classlist data}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        if (data.fLAG == "N") model.updateCircularFlag(data.aPPCIRCULARID.toString());
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
                child: Container(
                  //   padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 10),
                  // decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(10)),
                  child: Text(circular.aPPCIRCULARSUBJECT ?? "",
                      maxLines: 5,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Montserrat Regular",
                        color: Colors.black,
                      )),
                ),
              ),
              //  const Spacer(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(DateTimeUtils.formatDateTime(circular.aPPCIRCULARDATE ?? ""),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Montserrat Regular",
                      color: Colors.orange,
                    )),
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
