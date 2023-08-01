import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:search_choices/search_choices.dart';
import 'package:intl/intl.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import './studentlist.dart';

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
  @override
  _AssignmentFormState createState() => _AssignmentFormState();
}

class _AssignmentFormState extends State<AssignmentForm> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  DateTime? assignmentDate;
  String? selectedClass;
  List<dynamic> selectedSections = [];
  List<String> selectedStudents = [];
  String? selectedSubject;
  String? selectedEmployee;
  String? assignmentDetails;
  DateTime? startDate;
  DateTime? endDate;
  bool isActive = false;
  List<String> uploadedFiles = [];

  // Dropdown options
  List<String> classOptions = ['Class A', 'Class B', 'Class C'];
  List<dynamic> sectionOptions = ['Section 1', 'Section 2', 'Section 3','Section 4', 'Section 5', 'Section 6'];
  List<dynamic> studentOptions = ['Student 1', 'Student 2', 'Student 3'];
  List<String> subjectOptions = ['Subject 1', 'Subject 2', 'Subject 3'];
  List<String> employeeOptions = ['Employee 1', 'Employee 2', 'Employee 3'];

  List<int> selectedItemsMultiMenuSelectAllNone = [];
  List<DropdownMenuItem> items = [];

  List<int> selectedItemsStudents = [];
  List<DropdownMenuItem> itemsStudents = [];

  String? selectedItemsClass;
  List<DropdownMenuItem> itemsClass = [];

  String? selectedItemsSubject;
  List<DropdownMenuItem> itemsSubject = [];

  String? selectedItemsEmployee;
  List<DropdownMenuItem> itemsEmployee = [];

  //String? selectedValueSingleDialog;

  HtmlEditorController controller = HtmlEditorController();

  //Student
  List<Student> students = [
    Student(id: 1, name: "Student 1"),
    Student(id: 2, name: "Student 2"),
    Student(id: 3, name: "Student 3"),
    Student(id: 4, name: "Student 4"),
    Student(id: 5, name: "Student 5"),
    Student(id: 6, name: "Student 6"),
    Student(id: 7, name: "Student 7"),
    // Add more students here
  ];

  bool selectAll = false;
  List<int> selectedIds = [];

  //Section
  List<Section> sections = [
    Section(id: 1, name: "Section 1"),
    Section(id: 2, name: "Section 2"),
    Section(id: 3, name: "Section 3"),

    // Add more students here
  ];

  bool selectAllSection = false;
  List<int> selectedIdsSection = [];


  List<File> _selectedFiles = [];

  void _openFileExplorer() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        _selectedFiles = result.paths.map((path) => File(path!)).toList();
        if (_selectedFiles.length > 3) {
          _selectedFiles = _selectedFiles.sublist(0, 3);
        }
      });
    }
  }

  void _deleteFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _uploadFiles() async {

    if (_selectedFiles.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Warning :'),
          content: Text('Please choose at least one file.'),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // Perform API upload logic here using the selected files
    // Example code:
    for (var file in _selectedFiles) {
      // Construct the multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('YOUR_API_ENDPOINT'),
      );

      // Attach the file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
      ));

      // Send the request and await the response
      var response = await request.send();

      // Process the response
      if (response.statusCode == 200) {
        // File uploaded successfully
        print('File uploaded: ${file.path}');
      } else {
        // Error uploading file
        print('Error uploading file: ${file.path}');
      }
    }
  }
  // final QuillEditorController controller = QuillEditorController();
  //
  // final _toolbarColor = Colors.grey.shade200;
  // final _backgroundColor = Colors.white70;
  // final _toolbarIconColor = Colors.black87;
  // final _editorTextStyle = const TextStyle(
  //     fontSize: 18,
  //     color: Colors.black,
  //     fontWeight: FontWeight.normal,
  //     fontFamily: 'Architects Daughter');
  // final _hintTextStyle = const TextStyle(
  //     fontSize: 18, color: Colors.black12, fontWeight: FontWeight.normal);

  bool _hasFocus = false;

  cancelForm(){
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  void initState() {
    selectedIds = [];
    selectedIdsSection = [];

    //Class Options
    classOptions.map((sclass) =>{
      //classOptions.indexOf(sclass)
      itemsClass.add(DropdownMenuItem(
        value: classOptions.indexOf(sclass),
        child: Text(sclass),
      ))

    }).toList();


    //Section Options
    sectionOptions.map((section) =>{
      //sectionOptions.indexOf(section)
      items.add(DropdownMenuItem(
        value: section,
        child: Text(section),
      ))

    }).toList();

    // for(var i = 0; i < sectionOptions.length; i++){
    //   print(sectionOptions[i]);
    //   items.add(DropdownMenuItem(
    //     value: sectionOptions[i],
    //     child: Text(sectionOptions[i]),
    //   ));
    //
    // }

    //Students Options
    studentOptions.map((student) =>{
      //sectionOptions.indexOf(section)
      itemsStudents.add(DropdownMenuItem(
        value: student,
        child: Text(student),
      ))

    }).toList();

    //Subject Options
    subjectOptions.map((subject) =>{
      itemsSubject.add(DropdownMenuItem(
        value: subjectOptions.indexOf(subject),
        child: Text(subject),
      ))

    }).toList();

    //Employee Options
    employeeOptions.map((employee) =>{
      itemsEmployee.add(DropdownMenuItem(
        value: employeeOptions.indexOf(employee),
        child: Text(employee),
      ))

    }).toList();


    //
    // items.add(DropdownMenuItem(
    //   value: 'raj%1',
    //   child: Text('raj'),
    // ));
    //
    // items.add(DropdownMenuItem(
    //   value: 'vijay%2',
    //   child: Text('vijay'),
    // ));

    print(items[1].value);

    super.initState();
  }

  void toggleSelectAll() {
    setState(() {
      selectAll = !selectAll;
      students.forEach((student) {
        student.isChecked = selectAll;
      });
      if (selectAll) {
        selectedIds = students.map((student) => student.id).toList();
      } else {
        selectedIds.clear();
      }
    });
  }

  void toggleStudentSelection(int studentId, bool value) {
    setState(() {
      students.firstWhere((student) => student.id == studentId).isChecked = value;
      if (value) {
        selectedIds.add(studentId);
      } else {
        selectedIds.remove(studentId);
      }
      selectAll = students.every((student) => student.isChecked);
    });
  }


  void toggleSelectAllSection() {
    setState(() {
      selectAllSection = !selectAllSection;
      sections.forEach((section) {
        section.isChecked = selectAllSection;
      });
      if (selectAllSection) {
        selectedIdsSection = sections.map((section) => section.id).toList();
      } else {
        selectedIdsSection.clear();
      }
    });
  }

  void toggleSectionSelection(int sectionId, bool value) {
    setState(() {
      sections.firstWhere((section) => section.id == sectionId).isChecked = value;
      if (value) {
        selectedIdsSection.add(sectionId);
      } else {
        selectedIdsSection.remove(sectionId);
      }
      selectAllSection = sections.every((section) => section.isChecked);
    });
  }

  // File upload variables
  int maxFiles = 3;
  int uploadedFileCount = 0;



  void saveForm() {
    print('form load');
    if (_formKey.currentState!.validate()) {
      // Perform your API call to save the data
      // Replace the API_URL with your actual API endpoint
      const String API_URL = 'https://example.com/saveAssignment';
      // Prepare the data to be sent
      Map<String, dynamic> postData = {
        'assignmentDate': assignmentDate!.toIso8601String(),
        'selectedClass': selectedClass,
        'selectedSections': selectedSections,
        'selectedStudents': selectedStudents,
        'selectedSubject': selectedSubject,
        'selectedEmployee': selectedEmployee,
        'assignmentDetails': assignmentDetails,
        'startDate': startDate!.toIso8601String(),
        'endDate': endDate!.toIso8601String(),
        'isActive': isActive,
        'uploadedFiles': uploadedFiles,
      };
      // Make the API call
      // Replace the implementation according to your preferred HTTP client library
      // Here's an example using the http package
      // Import the http package: `import 'package:http/http.dart' as http;`
      // http.post(Uri.parse(API_URL), body: postData)
      //     .then((response) {
      //   if (response.statusCode == 200) {
      //     // Success
      //     print('Assignment saved successfully!');
      //   } else {
      //     // Error
      //     print('Failed to save assignment. Error: ${response.body}');
      //   }
      // }).catchError((error) {
      //   print('Failed to save assignment. Error: $error');
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Assignment Form'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Assignment Date - DatePicker

                ListTile(
                  title: Text('Assignment Date'),
                  subtitle: Text(
                    // assignmentDate != null
                    //     ? assignmentDate.toString()
                    //     : 'Select a date',
                    assignmentDate != null
                        ? DateFormat('dd/MM/yyyy').format(assignmentDate!) // Format date as dd/MM/yyyy
                        : 'Select a date',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        assignmentDate = pickedDate;
                      });
                    }
                  },
                ),
                Container(height: 1, color: Color(0xFFD3D3D3)), //divider



                //Class Dropdown
                SearchChoices.single(
                  items: itemsClass,
                  value: selectedItemsClass,
                  hint: "Class",
                  searchHint: "Select Class",
                  displayClearIcon: false,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      selectedItemsClass = value;
                    });
                  },
                  dialogBox: false,
                  isExpanded: true,
                  menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                ),

                //Section Custom List
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 12.0, right: 12,bottom:0),
                  child: Text("Section *",
                    style: TextStyle(
                      fontSize: 15.0,

                      //color: Colors.blue,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: toggleSelectAllSection,
                          child: Text(
                            selectAllSection ? 'Deselect All' : 'Select All',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Text(
                          'Selected: ${selectedIdsSection.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      //height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFD3D3D3)),
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          /*decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),*/
                          child: Column(
                            children: sections.map((section) {
                              return ListTileTheme(
                                horizontalTitleGap: 0.0,

                                child: CheckboxListTile(
                                  //dense:true,
                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                  contentPadding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 0.0,top: 0.0),
                                  title: Text(section.name),
                                  //activeColor: Colors.blue,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  value: section.isChecked,
                                  onChanged: (bool? value) {
                                    toggleSectionSelection(section.id, value!);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Retrieve the selected student IDs
                    //     print(selectedIdsSection);
                    //   },
                    //   child: Text('Get Selected IDs'),
                    // ),
                  ],
                ),


                //Section Custom List


                // Section Multi-Select Checkbox Dropdown
                // SearchChoices.multiple(
                //   items: items,
                //   selectedItems: selectedItemsMultiMenuSelectAllNone,
                //   hint: "Section",
                //   searchHint: "Select Section",
                //   // validator: (selectedItemsForValidator) {
                //   //   if (selectedItemsForValidator.length != 1) {
                //   //     return ("Must select 1");
                //   //   }
                //   //   return (null);
                //   // },
                //   // validator: (value) {
                //   //   if (value == null || value.isEmpty) {
                //   //     return 'Please select a section';
                //   //   }
                //   //   return null;
                //   // },
                //   displayClearIcon: false,
                //   onChanged: (value) {
                //     print(value);
                //     setState(() {
                //       selectedItemsMultiMenuSelectAllNone = value;
                //     });
                //   },
                //   dialogBox: true,
                //   closeButton: (selectedItemsClose, closeContext, Function updateParent) {
                //     return Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: <Widget>[
                //         ElevatedButton(
                //             onPressed: () {
                //               setState(() {
                //                 selectedItemsClose.clear();
                //                 selectedItemsClose.addAll(
                //                     Iterable<int>.generate(items.length).toList());
                //               });
                //               updateParent(selectedItemsClose);
                //             },
                //             child: Text("Select all")),
                //         ElevatedButton(
                //             onPressed: () {
                //               setState(() {
                //                 selectedItemsClose.clear();
                //               });
                //               updateParent(selectedItemsClose);
                //             },
                //             child: Text("Select none")),
                //       ],
                //     );
                //   },
                //   isExpanded: true,
                // ),

               //Student List Custom
                const Padding(
                  padding: EdgeInsets.only(left: 8.0, top: 12.0, right: 12,bottom:0),
                  child: Text("Students *",
                    style: TextStyle(
                      fontSize: 15.0,

                      //color: Colors.blue,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: toggleSelectAll,
                          child: Text(
                            selectAll ? 'Deselect All' : 'Select All',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Text(
                          'Selected: ${selectedIds.length}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      //height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFD3D3D3)),
                      ),
                      child: SingleChildScrollView(
                        child: Container(
                          /*decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),*/
                          child: Column(
                            children: students.map((student) {
                              return ListTileTheme(
                                horizontalTitleGap: 0.0,

                                child: CheckboxListTile(
                                  //dense:true,
                                  visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                                  contentPadding: EdgeInsets.only(left: 10.0,right: 10.0,bottom: 0.0,top: 0.0),
                                  title: Text(student.name),
                                  //activeColor: Colors.blue,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                  value: student.isChecked,
                                  onChanged: (bool? value) {
                                    toggleStudentSelection(student.id, value!);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     // Retrieve the selected student IDs
                    //     print(selectedIds);
                    //   },
                    //   child: Text('Get Selected IDs'),
                    // ),
                  ],
                ),

                //Student List Custom
                //Students Multiple
                // SearchChoices.multiple(
                //   items: itemsStudents,
                //   selectedItems: selectedItemsStudents,
                //   hint: "Students",
                //   searchHint: "Select Students",
                //   displayClearIcon: false,
                //   onChanged: (value) {
                //     print(value);
                //     setState(() {
                //       selectedItemsStudents = value;
                //     });
                //   },
                //   dialogBox: true,
                //   closeButton: (selectedItemsClose, closeContext, Function updateParent) {
                //     return Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: <Widget>[
                //         ElevatedButton(
                //             onPressed: () {
                //               setState(() {
                //                 selectedItemsClose.clear();
                //                 selectedItemsClose.addAll(
                //                     Iterable<int>.generate(itemsStudents.length).toList());
                //               });
                //               updateParent(selectedItemsClose);
                //             },
                //             child: Text("Select all")),
                //         ElevatedButton(
                //             onPressed: () {
                //               setState(() {
                //                 selectedItemsClose.clear();
                //               });
                //               updateParent(selectedItemsClose);
                //             },
                //             child: Text("Select none")),
                //       ],
                //     );
                //   },
                //   isExpanded: true,
                // ),

                //Subject Dropdown
                SearchChoices.single(
                  items: itemsSubject,
                  value: selectedItemsSubject,
                  hint: "Subject",
                  searchHint: "Select Subject",
                  displayClearIcon: false,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      selectedItemsSubject = value;
                    });
                  },
                  dialogBox: false,
                  isExpanded: true,
                  menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                ),

                //Employee Dropdown
                SearchChoices.single(
                  items: itemsEmployee,
                  value: selectedItemsEmployee,
                  hint: "Employee",
                  searchHint: "Select Employee",
                  displayClearIcon: false,
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      selectedItemsEmployee = value;
                    });
                  },
                  dialogBox: false,
                  isExpanded: true,
                  menuConstraints: BoxConstraints.tight(Size.fromHeight(350)),
                ),


                // Assignment Details - HTML Text Editor

                // ToolBar(
                //   toolBarColor: Colors.cyan.shade50,
                //   activeIconColor: Colors.green,
                //   padding: const EdgeInsets.all(8),
                //   iconSize: 20,
                //   controller: controller,
                //   customButtons: [
                //     InkWell(onTap: () {}, child: const Icon(Icons.favorite)),
                //     InkWell(onTap: () {}, child: const Icon(Icons.add_circle)),
                //   ],
                // ),
                // QuillHtmlEditor(
                //     text: "<h1>Hello</h1>This is a quill html editor example 😊",
                //     hintText: 'Hint text goes here',
                //     controller: controller,
                //     isEnabled: true,
                //     minHeight: 300,
                //     textStyle: _editorTextStyle,
                //     hintTextStyle: _hintTextStyle,
                //     hintTextAlign: TextAlign.start,
                //     padding: const EdgeInsets.only(left: 10, top: 5),
                //     hintTextPadding: EdgeInsets.zero,
                //     backgroundColor: _backgroundColor,
                //     onFocusChanged: (hasFocus) => debugPrint('has focus $hasFocus'),
                //     onTextChanged: (text) => debugPrint('widget text change $text'),
                //     onEditorCreated: () => debugPrint('Editor has been loaded'),
                //     onEditorResized: (height) =>
                //         debugPrint('Editor resized $height'),
                //     onSelectionChanged: (sel) =>
                //         debugPrint('${sel.index},${sel.length}')
                // ),
                //

                Padding(
                  padding: EdgeInsets.all(12), //apply padding to all four sides
                  child: Text("Assignment Details :",
                    style: TextStyle(
                      fontSize: 15.0,

                      //color: Colors.blue,
                    ),
                  ),
                ),


                SizedBox(height: 10.0),

                HtmlEditor(
                  controller: controller,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: 'Please enter assignment details...',
                    shouldEnsureVisible: true,
                    autoAdjustHeight:true,
                    //initialText: "<p>text content initial, if any</p>",
                  ),
                  otherOptions: OtherOptions(
                    //height: 400,
                  ),


                  htmlToolbarOptions: HtmlToolbarOptions(
                    defaultToolbarButtons: [
                      StyleButtons(),
                      //ParagraphButtons(lineHeight: false, caseConverter: false),
                      FontSettingButtons(),
                      FontButtons(),
                      ColorButtons(),
                      ListButtons(),
                      ParagraphButtons(),
                      InsertButtons(),
                      OtherButtons(),
                    ],

                    customToolbarInsertionIndices: [2, 5],
                    toolbarPosition: ToolbarPosition.aboveEditor, //by default
                    toolbarType: ToolbarType.nativeExpandable,

                  ),

                ),

                // TextFormField(
                //   decoration: InputDecoration(labelText: 'Assignment Details'),
                //   maxLines: 5,
                //   onChanged: (value) {
                //     setState(() {
                //       assignmentDetails = value;
                //     });
                //   },
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Please enter assignment details';
                //     }
                //     return null;
                //   },
                // ),

                // Start Date - DatePicker
                ListTile(
                  title: Text('Start Date'),
                  subtitle: Text(
                    startDate != null
                        ? DateFormat('dd/MM/yyyy').format(startDate!) // Format date as dd/MM/yyyy
                        : 'Select a date',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        startDate = pickedDate;
                      });
                    }
                  },
                ),
                Container(height: 1, color: Color(0xFFD3D3D3)), //divider

                // End Date - DatePicker
                ListTile(
                  title: Text('End Date'),
                  subtitle: Text(
                    endDate != null
                        ? DateFormat('dd/MM/yyyy').format(endDate!) // Format date as dd/MM/yyyy
                        : 'Select a date',
                  ),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        endDate = pickedDate;
                      });
                    }
                  },
                ),
                Container(height: 1, color: Color(0xFFD3D3D3)), //divider

                // Active Checkbox
                CheckboxListTile(
                  contentPadding: EdgeInsets.only(left: 10.0, top: 8.0, right: 8,bottom:8),
                  title: Text('  Active'),
                  value: isActive,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isActive = newValue!;
                    });
                  },
                ),

                //file

                const Padding(
                  padding: EdgeInsets.only(left: 20.0, top: 12.0, right: 12,bottom:0),
                   child: Text("Upload Files :",
                    style: TextStyle(
                      fontSize: 15.0,

                      //color: Colors.blue,
                    ),
                  ),
                ),

                Card(
                  margin: EdgeInsets.all(10.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 8.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.green,
                            onPrimary: Colors.white,
                            shadowColor: Colors.greenAccent,
                            elevation: 3,
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(32.0)),
                            minimumSize: Size(280, 40), //////// HERE
                          ),
                          onPressed: _openFileExplorer,
                          child: Text('Browse'),
                        ),
                        Text('Supported file .jpg,.jpeg,.png,.doc,.docx,.pdf',style: TextStyle(color: Colors.red),),
                        //Text('Upload Files (Max 3)'),
                        // Text(
                        //   'Selected Files:',
                        //   style: TextStyle(fontSize: 18),
                        // ),
                        SizedBox(height: 8.0),
                        if( _selectedFiles.isNotEmpty)
                          DataTable(
                            border: TableBorder.all(
                              width: 1.0,
                              color:Color(0xFFD3D3D3),
                            style: BorderStyle.solid
                            ),
                            columns: [
                              DataColumn(
                                label: Text('Filename'),
                              ),
                              DataColumn(
                                label: Text('Delete'),
                              ),
                            ],
                            rows: List<DataRow>.generate(
                              _selectedFiles.length,
                                  (index) =>
                                  DataRow(
                                    cells: [
                                      DataCell(Text(path.basename(
                                          _selectedFiles[index].path))),
                                      DataCell(
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () => _deleteFile(index),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),

                        // ListView.builder(
                        //   shrinkWrap: true,
                        //   itemCount: _selectedFiles.length,
                        //   itemBuilder: (context, index) {
                        //     final file = _selectedFiles[index];
                        //     final fileName = path.basename(file.path);
                        //     return ListTile(
                        //       //title: Text(file.path),
                        //       title: Text(fileName),
                        //       trailing: IconButton(
                        //         icon: Icon(Icons.delete),
                        //         onPressed: () => _deleteFile(index),
                        //       ),
                        //     );
                        //   },
                        // ),
                        ElevatedButton(
                          onPressed: _uploadFiles,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink, // Background color
                          ),
                          child: Text('Upload'),
                        ),

                        SizedBox(height: 12.0),
                      ],
                    ),
                  ),
                ),

                // File Upload


                // Save Button
                // ElevatedButton(
                //   onPressed: saveForm,
                //   child: Text('Save'),
                // ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          //color: Colors.white70,
          child: Container(
            height: 56.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                ElevatedButton(
                  onPressed: () {
                    // Handle save button press
                    saveForm();
                  },
                  child: Text('Save'),
                ),

                ElevatedButton(
                  onPressed: () {
                    // Handle cancel button press
                    cancelForm();

                  },
                  child: Text('Cancel'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
        // bottomNavigationBar: Padding(
        //   padding: EdgeInsets.all(16.0),
        //   child: ElevatedButton(
        //     onPressed: () {saveForm();},
        //
        //     child: Text('Fixed Button'),
        //   ),
        // ),
      ),
    );
  }
}

