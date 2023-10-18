import 'package:flexischool/common/constants.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/teacher/teacher_assignment_provider.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flexischool/widgets/file_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:provider/provider.dart';
import 'package:flexischool/utils/locator.dart';

class Student {
  int id;
  String name;
  bool isChecked;

  Student({required this.id, required this.name, this.isChecked = false});
}

class Section {
  int id;
  String name;
  bool isChecked;

  Section({required this.id, required this.name, this.isChecked = false});
}

class AssignmentForm extends StatefulWidget {
  final int employeeId;

  const AssignmentForm({super.key, required this.employeeId});

  @override
  _AssignmentFormState createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();
  TeacherAssignmentProvider? teacherAssignmentProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    teacherAssignmentProvider = TeacherAssignmentProvider();
    teacherAssignmentProvider?.fetchClassData(teacherId: widget.employeeId);
    teacherAssignmentProvider?.fetchSectionData(teacherId: widget.employeeId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => teacherAssignmentProvider,
        builder: (context, child) {
          return Consumer<TeacherAssignmentProvider>(builder: (context, model, _) {
            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
                    title: const Text('Assignment Form'),
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  body: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        controller: model.scrollController,
                        children: [
                          model.getClassResponse.cLASSandSECTION == null
                              ? const SizedBox.shrink()
                              : Column(
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
                                      width: double.infinity,
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
                                            model.updateSelectedClass(value, widget.employeeId);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                          (model.getSectionResponse == null ||
                                  model.getSectionResponse!.cLASSandSECTION!.isEmpty)
                              ? const SizedBox.shrink()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 15),
                                    const Text('Section*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "Montserrat Regular",
                                          color: Colors.black,
                                        )),
                                    const SizedBox(height: 5),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        border: Border.all(),
                                      ),
                                      child: LayoutBuilder(builder: (context, constraints) {
                                        return ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minHeight: 0,
                                            maxHeight: 200,
                                          ).normalize(),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children:
                                                  model.getSectionResponse!.cLASSandSECTION!.map((item) {
                                                final sectionId = item.sECTIONID;
                                                final sectionDesc = item.sECTIONDESC;
                                                return CheckboxListTile(
                                                  title: Text(sectionDesc ?? ""),
                                                  value: model.selectedSectionIds.contains(sectionId),
                                                  onChanged: (bool? isChecked) {
                                                    model.updateSelectedSection(
                                                        sectionId!, isChecked ?? false, widget.employeeId);
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 15),
                          (model.subjectResponse == null || model.subjectResponse?.subject == null)
                              ? const SizedBox.shrink()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Subject*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "Montserrat Regular",
                                          color: Colors.black,
                                        )),
                                    const SizedBox(height: 5),
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          border: Border.all(), borderRadius: BorderRadius.circular(8)),
                                      child: DropdownButton(
                                        padding: const EdgeInsets.only(left: 10),
                                        value: model.selectedSubject,
                                        underline: const SizedBox(),
                                        isExpanded: true,
                                        hint: const Text('Select a subject'),
                                        items: model.subjectResponse?.subject
                                            ?.map((item) => DropdownMenuItem(
                                                  value: item.subjectId,
                                                  child: Text(item.subjectName ?? ""),
                                                ))
                                            .toList(),
                                        onChanged: (int? value) {
                                          if (value != null) {
                                            model.updateSelectedSubject(value);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 15),
                          (model.studentResponse == null)
                              ? const SizedBox.shrink()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Text('Student*',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            )),
                                        const Spacer(),
                                        ElevatedButton(
                                          onPressed: model.toggleSelectAll,
                                          child: Text(model.selectAll ? 'Deselect All' : 'Select All'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5.0),
                                        border: Border.all(),
                                      ),
                                      child: LayoutBuilder(builder: (context, constraints) {
                                        return ConstrainedBox(
                                          constraints: const BoxConstraints(
                                            minHeight: 0,
                                            maxHeight: 200,
                                          ).normalize(),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children:
                                                  model.studentResponse!.aDMSTUDREGISTRATION!.map((item) {
                                                final studentId = item.aDMSTUDENTID;
                                                final student = "${item.fIRSTNAME ?? ""} ${item.aDMNO ?? ""}";
                                                return CheckboxListTile(
                                                  title: Text(student),
                                                  value:
                                                      model.selectAll || model.studentIds.contains(studentId),
                                                  onChanged: (bool? isChecked) {
                                                    model.updateStudentData(studentId!, isChecked ?? false);
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),

                          const SizedBox(height: 15),
                          const Text("Assignment Details :",
                              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold)),
                          QuillToolbar.basic(
                            controller: model.quillController,
                            // embedButtons: FlutterQuillEmbeds.buttons(
                            //   onImagePickCallback: model.onImagePickCallback,
                            //   onVideoPickCallback: model.onVideoPickCallback,
                            // ),
                            showAlignmentButtons: true,
                            //   afterButtonPressed: model.focusNode.requestFocus,
                          ),

                          Container(
                            height: 300,
                            decoration:
                                BoxDecoration(borderRadius: BorderRadius.circular(5), border: Border.all()),
                            child: QuillEditor.basic(
                              padding: const EdgeInsets.all(10),
                              controller: model.quillController,
                              autoFocus: false,
                              readOnly: false,
                            ),
                          ),
                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: const Text('Start Date'),
                            subtitle: Text(
                              model.startDateController.text.isNotEmpty
                                  ? model.startDateController.text
                                  : 'Select a date',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(Constants.startDate),
                                firstDate: DateTime.parse(Constants.startDate),
                                lastDate: DateTime.parse(Constants.lastDate),
                              );
                              if (pickedDate != null) {
                                model.updateStartDate(pickedDate);
                              }
                            },
                          ),
                          Container(height: 1, color: const Color(0xFFD3D3D3)), //divider

                          ListTile(
                            contentPadding: const EdgeInsets.all(0),
                            title: const Text('End Date'),
                            subtitle: Text(
                              model.endDateController.text.isNotEmpty
                                  ? model.endDateController.text
                                  : 'Select a date',
                            ),
                            trailing: const Icon(Icons.calendar_today),
                            onTap: () async {
                              if (model.startDateController.text.isNotEmpty) {
                                final DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.parse(Constants.startDate),
                                  firstDate: DateTime.parse(Constants.startDate),
                                  lastDate: DateTime.parse(Constants.lastDate),
                                );
                                if (pickedDate != null) {
                                  if (pickedDate.isBefore(model.selectedStartDate)) {
                                    if (context.mounted) {
                                      ShowSnackBar.error(
                                          context: context,
                                          showMessage: 'End date cannot be earlier than the start date!');
                                    }
                                  } else {
                                    model.updateEndDate(pickedDate);
                                  }
                                }
                              } else {
                                if (context.mounted) {
                                  ShowSnackBar.error(
                                      context: context,
                                      showMessage:
                                          'Start date must be selected before choosing an end date!');
                                }
                              }
                            },
                          ),
                          Container(height: 1, color: const Color(0xFFD3D3D3)), //divider

                          ValueListenableBuilder<bool>(
                              valueListenable: model.active,
                              builder: (BuildContext context, bool isChecked, Widget? child) {
                                return CheckboxListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  title: const Text('Active'),
                                  value: isChecked,
                                  onChanged: (newValue) {
                                    model.active.value = newValue!;
                                  },
                                );
                              }),

                          const Text(
                            'Upload Files',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Montserrat Regular",
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    model.selectFile();
                                  },
                                  child: Container(
                                    height: 45,
                                    padding: const EdgeInsets.only(left: 5, top: 5, bottom: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(), borderRadius: BorderRadius.circular(10)),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.grey, borderRadius: BorderRadius.circular(5)),
                                            child: const Text(
                                              'Browse',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                                fontFamily: "Montserrat Regular",
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            model.fileName ?? 'Select file',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              InkWell(
                                onTap: () {
                                  if (model.filePick != null) {
                                    if (model.selectedClass != null) {
                                      model.uploadFile();
                                    } else {
                                      ShowSnackBar.info(context: context, showMessage: 'Please select class');
                                    }
                                  }
                                },
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  height: 45,
                                  decoration: BoxDecoration(
                                      color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                                  child: const Text(
                                    'Upload',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: "Montserrat Regular",
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Supported file: jpg, jpeg, png, pdf, doc, docx',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              fontFamily: "Montserrat Regular",
                              color: Colors.redAccent,
                            ),
                          ),
                          const SizedBox(height: 15),
                          model.docList.isEmpty
                              ? const SizedBox.shrink()
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Uploaded files',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Montserrat Regular",
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    FileTable(
                                      files: model.docList,
                                      onRemove: (file, index) {
                                        model.deleteFile(file, index);
                                      },
                                    ),
                                    const SizedBox(height: 100)
                                  ],
                                ),

                          // const Padding(
                          //   padding: EdgeInsets.only(left: 20.0, top: 12.0, right: 12, bottom: 0),
                          //   child: Text(
                          //     "Upload Files :",
                          //     style: TextStyle(
                          //       fontSize: 15.0,
                          //     ),
                          //   ),
                          // ),
                          // Card(
                          //   margin: const EdgeInsets.all(10.0),
                          //   child: Center(
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         const SizedBox(height: 8.0),
                          //         ElevatedButton(
                          //           style: ElevatedButton.styleFrom(
                          //             primary: Colors.green,
                          //             onPrimary: Colors.white,
                          //             shadowColor: Colors.greenAccent,
                          //             elevation: 3,
                          //             minimumSize: const Size(280, 40),
                          //           ),
                          //           onPressed: () => model.selectFile(),
                          //           child: const Text('Browse'),
                          //         ),
                          //         const Text(
                          //           'Supported file .jpg,.jpeg,.png,.doc,.docx,.pdf',
                          //           style: TextStyle(color: Colors.red),
                          //         ),
                          //         Text(
                          //           model.fileName ?? "",
                          //           style: const TextStyle(color: Colors.black54),
                          //         ),
                          //         ElevatedButton(
                          //           onPressed: () {
                          //             if (model.filePick != null) {
                          //               if (model.selectedClass != null) {
                          //                 model.uploadFile();
                          //               } else {
                          //                 ShowSnackBar.info(
                          //                     context: context, showMessage: 'Please select class');
                          //               }
                          //             } else {
                          //               ShowSnackBar.info(
                          //                   context: context, showMessage: 'Please select any file');
                          //             }
                          //           },
                          //           style: ElevatedButton.styleFrom(
                          //             backgroundColor: Colors.pink, // Background color
                          //           ),
                          //           child: const Text('Upload'),
                          //         ),
                          //         const SizedBox(height: 12.0),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          // model.docList.isEmpty
                          //     ? const SizedBox.shrink()
                          //     : Column(
                          //         crossAxisAlignment: CrossAxisAlignment.start,
                          //         children: [
                          //           const Text(
                          //             'Uploaded files',
                          //             style: TextStyle(
                          //               fontSize: 14,
                          //               fontWeight: FontWeight.bold,
                          //               fontFamily: "Montserrat Regular",
                          //               color: Colors.black,
                          //             ),
                          //           ),
                          //           const SizedBox(height: 5),
                          //           FileTable(
                          //             files: model.docList,
                          //             onRemove: (file, index) {
                          //               model.deleteFile(file, index);
                          //             },
                          //           )
                          //         ],
                          //       ),
                        ],
                      ),
                    ),
                  ),
                  bottomNavigationBar: BottomAppBar(
                    child: SizedBox(
                      height: 56.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              if (model.selectedClass == null) {
                                ShowSnackBar.info(context: context, showMessage: 'Please select a class');
                              } else if (model.selectedSectionIds.isEmpty) {
                                ShowSnackBar.info(context: context, showMessage: 'Please select any section');
                              } else if (model.selectedSubject == null) {
                                ShowSnackBar.info(context: context, showMessage: 'Please select a subject');
                              } else if (model.studentIds.isEmpty) {
                                ShowSnackBar.info(context: context, showMessage: 'Please select any student');
                              } else if (model.quillController.document.toPlainText().trim().isEmpty) {
                                ShowSnackBar.info(
                                    context: context, showMessage: 'Please enter assignment detail');
                              } else if (model.selectedStartDate == null) {
                                ShowSnackBar.info(context: context, showMessage: 'Please select start date');
                              } else if (model.selectedEndDate == null) {
                                ShowSnackBar.info(context: context, showMessage: 'Please select end date');
                              } else {
                                model.addAssignmentData(employeeId: widget.employeeId).then((value) {
                                  if (value.success ?? false) {
                                    ShowSnackBar.successToast(
                                        context: context, showMessage: 'Assignment created successfully');
                                    Navigator.pushReplacementNamed(context, '/dashboard');
                                  } else {
                                    ShowSnackBar.error(context: context, showMessage: 'Something went wrong');
                                  }
                                });
                              }
                            },
                            child: const Text('Save'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ),
                ),
                if (loaderProvider.isLoading) const CustomLoader(),
              ],
            );
          });
        });
  }
}
