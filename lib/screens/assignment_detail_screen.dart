import 'package:flexischool/models/teacher/teacher_assignment_list_response.dart';
import 'package:flexischool/providers/student/assignment_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final int assignmentId;
  final int sessionId;

  const AssignmentDetailScreen(
      {Key? key, required this.assignmentId, required this.sessionId})
      : super(key: key);

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  AssignmentDetailProvider? assignmentDetailProvider;

  @override
  void initState() {
    assignmentDetailProvider = AssignmentDetailProvider();
      assignmentDetailProvider?.fetchAssignmentDetailData(widget.assignmentId,widget.sessionId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => assignmentDetailProvider,
        builder: (context, child) {
          return Consumer<AssignmentDetailProvider>(builder: (context, model, _) {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Text(
                  'Assignment Detail',
                  style: TextStyle(color: Colors.white),
                ),
                leading: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white),
              ),
              body: Container(
                height: double.infinity,
                width: double.infinity,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(5)),
                child: model.assignmentDetailResponse == null
                    ? const Center(child: CircularProgressIndicator())
                    : model.assignmentDetailResponse!.lstAssignment!.isEmpty
                        ? const Center(
                            child: Text('No assignment detail found'),
                          )
                        : ListView(
                            padding: const EdgeInsets.all(15),
                            shrinkWrap: true,
                            children: [
                              Text(
                                model.assignmentDetailResponse?.lstAssignment?.first.sUBJECTNAME ?? "",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                              ),
                              Html(
                                shrinkWrap: true,
                                data: model.getContentAsHTML(
                                  model.assignmentDetailResponse?.lstAssignment?.first.aSSIGNMENTDETAILS ??
                                      "",
                                ),
                              ),
                              if (model
                                  .assignmentDetailResponse!.lstAssignment!.first.lstCircularFile!.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 10),
                                    const Text('Attachments',
                                        style: TextStyle(
                                            color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    if (model.assignmentDetailResponse!.lstAssignment!.first.lstCircularFile!
                                        .isNotEmpty)
                                      InkWell(
                                          onTap: () {
                                            if (model.assignmentDetailResponse!.lstAssignment!.first
                                                .lstCircularFile!.isNotEmpty) {
                                              showDialog(
                                                context: context,
                                                barrierDismissible: false,
                                                builder: (BuildContext context) {
                                                  var data = model.assignmentDetailResponse?.lstAssignment
                                                      ?.first.lstCircularFile!;
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
                                                                  title: Text(data![index].fILENAME ?? ""),
                                                                  trailing: IconButton(
                                                                      onPressed: () {
                                                                        model
                                                                            .requestWritePermission(context)
                                                                            .then((_) {
                                                                          model.downloadFile(context,
                                                                              data[index].fILENAME ?? "");
                                                                        });
                                                                      },
                                                                      icon: const Icon(Icons.download)),
                                                                ),
                                                            itemCount: data?.length);
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
                                          },
                                          child: const CircleAvatar(
                                              backgroundColor: Colors.blue,
                                              child: Icon(
                                                Icons.cloud_download,
                                                color: Colors.white,
                                              ))),
                                    // ListView.builder(
                                    //   shrinkWrap: true,
                                    //   physics: const NeverScrollableScrollPhysics(),
                                    //   itemBuilder: (context, index) => ListTile(
                                    //     contentPadding: const EdgeInsets.all(0),
                                    //     title: Text(
                                    //       model.assignmentDetailResponse?.lstAssignment?.first
                                    //               .lstCircularFile![index].fILENAME ??
                                    //           "",
                                    //     ),
                                    //     trailing: IconButton(
                                    //       onPressed: () {
                                    //         model.requestWritePermission(context).then((_) {
                                    //           model.downloadFile(
                                    //             context,
                                    //             model.assignmentDetailResponse?.lstAssignment?.first
                                    //                     .lstCircularFile![index].fILENAME ??
                                    //                 "",
                                    //           );
                                    //         });
                                    //       },
                                    //       icon: const Icon(Icons.download),
                                    //     ),
                                    //   ),
                                    //   itemCount: model.assignmentDetailResponse?.lstAssignment?.first
                                    //       .lstCircularFile!.length,
                                    // ),
                                  ],
                                ),
                            ],
                          ),
              ),
            );
          });
        });
  }
}
