import 'package:flexischool/providers/circulars_provider.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flexischool/widgets/file_table.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CircularsScreen extends StatefulWidget {
  final int employeeId;

  const CircularsScreen({Key? key, required this.employeeId}) : super(key: key);

  @override
  State<CircularsScreen> createState() => _CircularsScreenState();
}

class _CircularsScreenState extends State<CircularsScreen> {
  CircularsProvider? circularsProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    circularsProvider = CircularsProvider();
    circularsProvider?.fetchClassData(teacherId: widget.employeeId);
    circularsProvider?.fetchSectionData(teacherId: widget.employeeId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => circularsProvider,
        builder: (context, child) {
          return Consumer<CircularsProvider>(builder: (context, model, _) {
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
              ),
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    child: SingleChildScrollView(
                      controller: model.scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Circulars Information',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              )),
                          const SizedBox(height: 10),
                          const Text('Subject*',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              )),
                          const SizedBox(height: 5),
                          Container(
                            decoration:
                                BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)),
                            child: TextFormField(
                              controller: model.subjectController,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                border: InputBorder.none,
                                hintText: 'Enter subject',
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text('Description*',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              )),
                          const SizedBox(height: 5),
                          Container(
                            decoration:
                                BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(8)),
                            child: TextFormField(
                              controller: model.descriptionController,
                              maxLines: 5,
                              maxLength: 4000,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(10),
                                border: InputBorder.none,
                                hintText: 'Enter description',
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
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
                                            model.updateSelectedClass(value);
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
                                    const Text('Section',
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
                                                        sectionId!, isChecked ?? false);
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
                          Row(
                            children: [
                              const Text('Circulars Information Applicable To',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: "Montserrat Regular",
                                    color: Colors.black,
                                  )),
                              ValueListenableBuilder<bool>(
                                  valueListenable: model.circularInfo,
                                  builder: (BuildContext context, bool isChecked, Widget? child) {
                                    return Checkbox(
                                      value: isChecked,
                                      onChanged: (value) {
                                        model.circularInfo.value = value!;
                                      },
                                    );
                                  }),
                              const Text('Parent',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: "Montserrat Regular",
                                    color: Colors.black,
                                  )),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Start Date*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "Montserrat Regular",
                                          color: Colors.black,
                                        )),
                                    const SizedBox(height: 5),
                                    InkWell(
                                      onTap: () => model.selectDate(context: context, startDate: true),
                                      child: Container(
                                          height: 45,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(
                                              border: Border.all(), borderRadius: BorderRadius.circular(8)),
                                          child: Text(
                                            model.startDateController.text,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('End Date*',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "Montserrat Regular",
                                          color: Colors.black,
                                        )),
                                    const SizedBox(height: 5),
                                    InkWell(
                                      onTap: () => model.selectDate(context: context, startDate: false),
                                      child: Container(
                                          height: 45,
                                          alignment: Alignment.centerLeft,
                                          padding: const EdgeInsets.only(left: 10),
                                          decoration: BoxDecoration(
                                              border: Border.all(), borderRadius: BorderRadius.circular(8)),
                                          child: Text(
                                            model.endDateController.text,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              const Text(
                                'Active',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  fontFamily: "Montserrat Regular",
                                  color: Colors.black,
                                ),
                              ),
                              ValueListenableBuilder<bool>(
                                  valueListenable: model.active,
                                  builder: (BuildContext context, bool isChecked, Widget? child) {
                                    return Checkbox(
                                      value: isChecked,
                                      onChanged: (value) {
                                        model.active.value = value!;
                                      },
                                    );
                                  }),
                            ],
                          ),
                          const SizedBox(height: 10),
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
                                    )
                                  ],
                                ),
                          const SizedBox(height: 20),
                          MaterialButton(
                              minWidth: double.infinity,
                              color: Colors.blueAccent,
                              height: 50,
                              onPressed: () {
                                if (model.subjectController.text.isEmpty) {
                                  ShowSnackBar.error(context: context, showMessage: 'Please enter subject');
                                } else if (model.descriptionController.text.isEmpty) {
                                  ShowSnackBar.error(
                                      context: context, showMessage: 'Please enter description');
                                } else if (model.selectedClass == null) {
                                  ShowSnackBar.error(context: context, showMessage: 'Please select a class');
                                } else if (model.selectedSectionIds.isEmpty) {
                                  ShowSnackBar.error(context: context, showMessage: 'Please select section');
                                } else if (model.selectedSectionIds.isEmpty) {
                                  ShowSnackBar.error(context: context, showMessage: 'Please select section');
                                } else if (model.studentIds.isEmpty) {
                                  ShowSnackBar.error(context: context, showMessage: 'Please select students');
                                } else if (model.selectedStartDate == null) {
                                  ShowSnackBar.error(
                                      context: context, showMessage: 'Please select start date');
                                } else if (model.selectedEndDate == null) {
                                  ShowSnackBar.error(context: context, showMessage: 'Please select end date');
                                } else {
                                  model.addCircularsData(teacherId: widget.employeeId).then((value) {
                                    if (value.success ?? false) {
                                      ShowSnackBar.successToast(
                                          context: context, showMessage: 'Circular created successfully');
                                      Navigator.pop(context);
                                    } else {
                                      ShowSnackBar.error(
                                          context: context, showMessage: 'Something went wrong');
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
