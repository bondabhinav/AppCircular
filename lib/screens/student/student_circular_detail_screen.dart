import 'package:flexischool/models/student/student_circular_detail_response.dart';
import 'package:flexischool/providers/student/student_circular_detail_provider.dart';
import 'package:flexischool/utils/date_formater.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentCircularDetailScreen extends StatefulWidget {
  final int id;

  const StudentCircularDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  State<StudentCircularDetailScreen> createState() => _StudentCircularDetailScreenState();
}

class _StudentCircularDetailScreenState extends State<StudentCircularDetailScreen> {

  StudentCircularDetailProvider? studentCircularDetailProvider;

  @override
  void initState() {
    studentCircularDetailProvider = StudentCircularDetailProvider();
    studentCircularDetailProvider?.fetchStudentCircularDetail(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => studentCircularDetailProvider,
        builder: (context, child) {
          return Consumer<StudentCircularDetailProvider>(builder: (context, model, _) {
            return Scaffold(
              appBar: AppBar(
                leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context)),
                centerTitle: true,
                title: const Text('Circulars'),
              ),
              body: Container(
                padding: const EdgeInsets.all(10),
                  child: model.studentCircularDetailResponse != null ? listItem(
                      circular: model.studentCircularDetailResponse!.classlist!.first,
                      documentOnTap: () {
                        if (model.studentCircularDetailResponse!.classlist!.first
                            .lstCircularFile!.isNotEmpty) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              var data =
                                  model.studentCircularDetailResponse!.classlist!.first;
                              return AlertDialog(
                                title: const Text('Document'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: LayoutBuilder(builder:
                                      (BuildContext context, BoxConstraints constraints) {
                                    return ListView.builder(
                                        shrinkWrap: true,
                                        itemBuilder: (context, index) =>
                                            ListTile(
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
                      }
                  ):const SizedBox()
              )
            );
          }
          );
        }
    );
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
        if(circular.cLASSDESC != null)  Row(
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Section: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Montserrat Regular",
                      color: Colors.black,
                    )),
                Wrap(
                  children: circular.lstCircularSection!
                      .map((e) {
                    return Text(
                      e.sECTIONDESC ?? "",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        fontFamily: "Montserrat Regular",
                        color: Colors.black,
                      ),
                    );
                  })
                      .map((widget) => [widget, const Text(', ')])
                      .expand((i) => i)
                      .toList(),
                ),
              ],
            ),
          const SizedBox(height: 5),
          Text(circular.aPPCIRCULARDESCRIPTION ?? "",
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
