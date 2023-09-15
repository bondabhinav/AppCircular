import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/models/common_model.dart';
import 'package:flexischool/models/get_class_response.dart';
import 'package:flexischool/models/get_section_response.dart';
import 'package:flexischool/models/request/student_request.dart';
import 'package:flexischool/models/section_class_model.dart';
import 'package:flexischool/models/student_response.dart';
import 'package:flexischool/models/upload_doc_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/utils/date_formater.dart';
import 'package:flexischool/widgets/custom_checkbox.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final GetIt getIt = GetIt.instance;

class CircularsProvider extends ChangeNotifier {
  final apiService = ApiService();
  final ValueNotifier<bool> circularInfo = ValueNotifier<bool>(true);
  final ValueNotifier<bool> active = ValueNotifier<bool>(true);
  final ScrollController scrollController = ScrollController();
  GetClassResponse getClassResponse = GetClassResponse();
  GetSectionResponse? getSectionResponse;
  List<UploadDocResponse> docList = [];
  List<String> allFiles = [];

  SectionClassResponse sectionClassResponse = SectionClassResponse();
  StudentResponse? studentResponse;
  FormFieldController<List<String>>? checkboxGroupValueController;
  List<String>? checkboxGroupValues;
  final loaderProvider = getIt<LoaderProvider>();
  File? filePick;
  var path;

  final startDateController = TextEditingController(text: Constants.getFormattedDate(Constants.startDate));
  final endDateController = TextEditingController(text: Constants.getFormattedDate(Constants.endDate));
  DateTime selectedStartDate = DateTime.parse(Constants.startDate);
  DateTime? selectedEndDate;

  int? _selectedClass;

  int? get selectedClass => _selectedClass;

  String selectedClassName = '';
  final List<int> _selectedSectionIds = [];

  List<int> get selectedSectionIds => _selectedSectionIds;

  List<Map<String, dynamic>> lstSectionCircular = [];
  List<StudentListModel> lstStudentCircular = [];

  final List<int> _studentIds = [];

  List<int> get studentIds => _studentIds;

  String? _fileName;

  String? get fileName => _fileName;

  bool _selectAll = false;

  bool get selectAll => _selectAll;

  final subjectController = TextEditingController();
  final descriptionController = TextEditingController();

  void toggleSelectAll() {
    _selectAll = !_selectAll;
    if (_selectAll) {
      _studentIds.clear();
      for (var item in studentResponse!.aDMSTUDREGISTRATION!) {
        _studentIds.add(item.aDMSTUDENTID!);
        // lstStudentCircular.add({"STUDENT_ID": item.aDMSTUDENTID!});
        lstStudentCircular
            .add(StudentListModel(STUDENT_ID: item.aDMSTUDENTID.toString(), ADM_NO: item.aDMNO.toString()));
      }
    } else {
      _studentIds.clear();
      lstStudentCircular.clear();
    }
    notifyListeners();
  }

  void updateSelectedSection(int sectionId, bool isChecked) {
    if (isChecked) {
      _selectedSectionIds.add(sectionId);
      lstSectionCircular.add({"SECTION_ID": sectionId});
    } else {
      _selectedSectionIds.remove(sectionId);
      lstSectionCircular.removeWhere((item) => item["SECTION_ID"] == sectionId);
    }
    if (selectedClass != null) {
      if (selectedSectionIds.isNotEmpty) {
        getStudentData();
      } else {
        studentResponse = null;
        studentResponse?.aDMSTUDREGISTRATION!.clear();
      }
    }
    notifyListeners();
  }

  void updateSelectedClass(int? value) {
    _selectedClass = value;
    selectedClassName =
        getClassResponse.cLASSandSECTION!.firstWhere((element) => element.classId == value).cLASSDESC!;
    debugPrint('class id ===> $selectedClass');
    debugPrint('class name ===> $selectedClassName');
    if (selectedClass != null) {
      if (_selectedSectionIds.isNotEmpty) {
        getStudentData();
      }
    }
    notifyListeners();
  }

  void updateStudentData(int studentId, bool isChecked) {
    if (_selectAll) {
      if (isChecked) {
        _studentIds.add(studentId);
        // lstStudentCircular.add({"STUDENT_ID": studentId});
        studentResponse!.aDMSTUDREGISTRATION!.where((element) {
          if (element.aDMSTUDENTID == studentId) {
            lstStudentCircular.add(StudentListModel(STUDENT_ID: studentId.toString(), ADM_NO: element.aDMNO));
          }
          return false;
        }).toList();
      } else {
        _studentIds.remove(studentId);
        lstSectionCircular.removeWhere((item) => item["STUDENT_ID"] == studentId);
        _selectAll = false;
      }
    } else {
      if (isChecked) {
        _studentIds.add(studentId);
        // lstStudentCircular.add({"STUDENT_ID": studentId});
        studentResponse!.aDMSTUDREGISTRATION!.where((element) {
          if (element.aDMSTUDENTID == studentId) {
            lstStudentCircular.add(StudentListModel(STUDENT_ID: studentId.toString(), ADM_NO: element.aDMNO));
          }
          return false;
        }).toList();
        if (_studentIds.length == studentResponse!.aDMSTUDREGISTRATION!.length) {
          _selectAll = true;
        }
      } else {
        lstSectionCircular.removeWhere((item) => item["STUDENT_ID"] == studentId);
        _studentIds.remove(studentId);
      }
    }

    notifyListeners();
  }

  Future<CommonResponse> addCircularsData({required int teacherId}) async {
    final List<Map<String, dynamic>> studentJsonList = lstStudentCircular.map((student) => student.toJson()).toList();

    log("student data $studentJsonList end");
    var commonResponse = CommonResponse();
    try {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      loaderProvider.showLoader();
      notifyListeners();
      var data = {
        "CIRCULAR_DATE": formattedDate,
        "CIRCULAR_DESCRIPTION": descriptionController.text,
        "EMPLOYEE_ID": teacherId,
        "ACTIVE": active.value ? "Y" : "N",
        "START_DATE": DateFormat('yyyy-MM-dd').format(selectedStartDate!),
        "END_DATE": DateFormat('yyyy-MM-dd').format(selectedEndDate!),
        "CLASS_ID": selectedClass,
        "CIRCULAR_SUBJECT": subjectController.text,
        "IS_APPLICABLETOPARENT": circularInfo.value ? "Y" : "N",
        "lstsectionCircular": lstSectionCircular,
        "lstStudentCircular": lstStudentCircular,
        "lstStudentCircularinfo": docList,
        "SESSION_ID": Constants.sessionId
      };
      log("Data======> $data");
      final response = await apiService.post(url: Api.addCircularApi, data: data);
      if (response.statusCode == 200) {
        commonResponse = CommonResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        notifyListeners();
        return commonResponse;
      }
    } catch (e) {
      loaderProvider.hideLoader();
      notifyListeners();
    }
    return commonResponse;
  }

  Future<void> fetchClassData({required int teacherId}) async {
    try {
      loaderProvider.showLoader();
      var data = {"TEACHER_ID": teacherId, "SESSION_ID": Constants.sessionId};
      final response = await apiService.post(url: Api.getClassApi, data: data);
      if (response.statusCode == 200) {
        getClassResponse = GetClassResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API');
    }
  }

  Future<void> fetchSectionData({required int teacherId}) async {
    try {
      loaderProvider.showLoader();
      var data = {"TEACHER_ID": teacherId, "SESSION_ID": Constants.sessionId};
      final response = await apiService.post(url: Api.getSectionApi, data: data);
      if (response.statusCode == 200) {
        getSectionResponse = GetSectionResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API');
    }
  }

  Future<void> getStudentData() async {
    try {
      final requestPayload = StudentRequest(
        sESSIONID: Constants.sessionId.toString(),
        lstClass: [
          LstClass(cLASSID: selectedClass.toString()),
        ],
        lstSection: selectedSectionIds
            .map((sectionId) => LstSection(cURRENTSECTIONID: sectionId.toString()))
            .toList(),
      );
      final jsonPayload = requestPayload.toJson();
      loaderProvider.showLoader();
      final response = await apiService.post(url: Api.getStudentApi, data: jsonPayload);
      if (response.statusCode == 200) {
        studentResponse = StudentResponse.fromJson(response.data);
        if (studentResponse!.aDMSTUDREGISTRATION!.isNotEmpty) {
          _studentIds.clear();
          lstStudentCircular.clear();
          _selectAll = true;
          studentResponse!.aDMSTUDREGISTRATION!.map((item) {
            _studentIds.add(item.aDMSTUDENTID!);
            lstStudentCircular
                .add(StudentListModel(STUDENT_ID: item.aDMSTUDENTID!.toString(), ADM_NO: item.aDMNO));
          }).toList();
        }
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API');
    }
  }

  Future<void> uploadFile() async {
    debugPrint('upload ${File(path).path}');
    loaderProvider.showLoader();
    notifyListeners();
    try {
      String fileName =
          '${selectedClassName.replaceAll(' ', '')}_${DateTime.now().millisecondsSinceEpoch}_${path.split('/').last}';
      debugPrint('upload fileName ----> $fileName');
      var request = http.MultipartRequest('POST', Uri.parse(Api.uploadCircularImageDocFileApi));
      request.headers['Content-Type'] = 'multipart/form-data; boundary=<calculated when request is sent>';
      request.headers['Accept'] = '*/*';
      request.files.add(await http.MultipartFile.fromPath('', File(path).path, filename: fileName));

      http.StreamedResponse response = await request.send();
      final data = await http.Response.fromStream(response);
      if (data.statusCode == 200) {
        debugPrint('data =====> ${data.body}');
        if (data.body == '[]') {
          loaderProvider.hideLoader();
          debugPrint('Empty list response');
        } else {
          List<dynamic> jsonResponse = json.decode(data.body);
          if (jsonResponse.isNotEmpty) {
            for (var jsonItem in jsonResponse) {
              Map<String, dynamic> jsonData = jsonItem;
              UploadDocResponse uploadDocResponse = UploadDocResponse.fromJson(jsonData);
              docList.add(uploadDocResponse);
              allFiles.add(File(path).path);
              path == null;
              filePick?.delete();
              filePick = null;
              _fileName = null;
              notifyListeners();
              debugPrint(uploadDocResponse.fileNAME);
              scrollController.animateTo(
                scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
              notifyListeners();
            }
          }
        }
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        debugPrint(response.reasonPhrase);
        debugPrint("else part ${response.reasonPhrase}");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("catch part ${e.toString()}");
      loaderProvider.hideLoader();
      notifyListeners();
    }
  }

  Future<void> deleteFile(String filename, int index) async {
    try {
      loaderProvider.showLoader();
      final response = await apiService.post(url: Api.deleteCircularFileApi, data: {"FILE_NAME": filename});
      if (response.statusCode == 200) {
        debugPrint('data =====> ${response.data}');
        if (response.data == "TRUE") {
          docList.removeAt(index);
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API ${e.toString()}');
    }
  }

  Future<void> selectDate({required BuildContext context, required bool startDate}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(Constants.startDate),
      firstDate: DateTime.parse(Constants.startDate),
      lastDate: DateTime.parse(Constants.endDate),
    );

    if (pickedDate != null) {
      if (startDate) {
        selectedStartDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
        );
        startDateController.text = DateTimeUtils.formatDate(selectedStartDate).toString();
      } else {
        if (pickedDate.isBefore(selectedStartDate)) {
          if (context.mounted) {
            ShowSnackBar.error(
                context: context, showMessage: 'End date cannot be earlier than the start date!');
          }
        } else {
          selectedEndDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
          );
          endDateController.text = DateTimeUtils.formatDate(selectedEndDate!).toString();
        }
      }
      notifyListeners();
    }
  }

  void selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      filePick = null;
      _fileName = null;
      path = result.files.first.path;
      filePick = File(path!);
      _fileName = result.files.first.name;
      debugPrint("File name: ${result.files.first.name}");
      debugPrint("File Path: $path");
      debugPrint("pickedFiles: ${File(path)}");
      notifyListeners();
    }
  }
}

class StudentListModel {
  String? STUDENT_ID;
  String? ADM_NO;

  StudentListModel({this.ADM_NO, this.STUDENT_ID});

  StudentListModel.fromJson(Map<String, dynamic> json) {
    STUDENT_ID = json['STUDENT_ID'];
    ADM_NO = json['ADM_NO'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ADM_NO'] = ADM_NO;
    data['STUDENT_ID'] = STUDENT_ID;
    return data;
  }
}
