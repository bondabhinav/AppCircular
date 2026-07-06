// Removed: import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/config.dart';
import 'package:flexischool/download_file.dart';
import 'package:flexischool/models/common_model.dart';
import 'package:flexischool/models/student/student_circular_doc_list_respnose.dart';
import 'package:flexischool/models/teacher/teacher_circular_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

final GetIt getIt = GetIt.instance;

class TeacherCircularListProvider extends ChangeNotifier {
  final loaderProvider = getIt<LoaderProvider>();
  TeacherCircularListResponse? teacherCircularListResponse;
  final apiService = ApiService();

  String _startDate = Constants.currentDate;

  String get startDate => _startDate;

  String _endDate = Constants.currentDate;

  String get endDate => _endDate;

  String? _message;

  String? get message => _message;

  Future<void> fetchTeacherCircularListData({
    required int employeeId,
    required String fromDate,
    required String endDate,
  }) async {
    try {
      loaderProvider.showLoader();
      var data = {
        'EMPLOYEE_ID': employeeId,
        'FROM_DATE': fromDate,
        'TO_DATE': endDate,
        'SESSION_ID': Constants.sessionId,
      };
      final response = await apiService.post(
        url: Api.getTeacherCircularListApi,
        data: data,
      );
      if (response.statusCode == 200) {
        teacherCircularListResponse = TeacherCircularListResponse.fromJson(
          response.data,
        );
        _message = null;
        loaderProvider.hideLoader();
        if (teacherCircularListResponse!.classlist!.isEmpty) {
          _message = 'No circular found';
        }
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        _message = 'Something wents wrong';
        notifyListeners();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      loaderProvider.hideLoader();
      _message = e.toString();
      notifyListeners();
    }
  }

  Future<StudentCircularDocumentListResponse> fetchTeacherDocumentData({
    required int circularId,
  }) async {
    var studentCircularDocumentListResponse =
        StudentCircularDocumentListResponse();
    try {
      loaderProvider.showLoader();
      var data = {"APP_CIRCULAR_ID": circularId};
      final response = await apiService.post(
        url: Api.studentDocumentListApi,
        data: data,
      );
      if (response.statusCode == 200) {
        studentCircularDocumentListResponse =
            StudentCircularDocumentListResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      loaderProvider.hideLoader();
      throw Exception('Failed to connect to the API ${e.toString()}');
    }
    return studentCircularDocumentListResponse;
  }

  // Future<void> updateCircularFlag(String id) async {
  //   try {
  //     var data = {"APP_CIRCULAR_ID": id};
  //     final response = await apiService.post(url: Api.updateCircularFlagApi, data: data);
  //     if (response.statusCode == 200) {
  //       //  var commonResponse = CommonResponse.fromJson(response.data);
  //       notifyListeners();
  //     } else {
  //       throw Exception('Failed to fetch data');
  //     }
  //   } catch (e) {
  //     debugPrint('Failed to connect to the API ${e.toString()}');
  //     throw Exception('Failed to connect to the API');
  //   }
  // }

  // void updateFlagStatus(Classlist classList) {
  //   classList.fLAG = "Y";
  //   notifyListeners();
  // }

  Future<void> downloadFile(BuildContext context, String url) async {
    final String fileName = url.split('/').last;
    await DownloadPdf.downloadPdf(
      '${Api.imageBaseUrl}/$url',
      fileName,
      context,
      (message) => debugPrint('download message -> $message'),
    );
  }

  Future<String> getDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      lastDate: DateTime(2050, 06, 11),
      firstDate: DateTime(1950, 06, 11),
    );
    if (picked != null) {
      final startDate = DateFormat('yyyy-MM-dd').format(picked.start);
      final endDate = DateFormat('yyyy-MM-dd').format(picked.end);
      _startDate = startDate;
      _endDate = endDate;
      notifyListeners();
    }
    return _startDate;
  }

  Future<void> inActiveCircular(
    Classlist circular,
    BuildContext context,
  ) async {
    try {
      loaderProvider.showLoader();
      var data = {"APP_CIRCULAR_ID": circular.aPPCIRCULARID};
      notifyListeners();
      final response = await apiService.post(
        url: Api.inActiveCircularApi,
        data: data,
      );
      if (response.statusCode == 200) {
        final commonResponse = CommonResponse.fromJson(response.data);
        if (commonResponse.success ?? false) {
          circular.aCTIVE = "N";
        } else {
          if (context.mounted) {
            ShowSnackBar.error(
              context: context,
              showMessage: 'Something wents wrong',
            );
          }
        }
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        if (context.mounted) {
          ShowSnackBar.error(
            context: context,
            showMessage: 'Something wents wrong',
          );
        }
        loaderProvider.hideLoader();
        notifyListeners();
      }
    } catch (e) {
      if (context.mounted) {
        ShowSnackBar.error(
          context: context,
          showMessage: 'Something wents wrong',
        );
      }
      loaderProvider.hideLoader();
      notifyListeners();
    }
  }
}
