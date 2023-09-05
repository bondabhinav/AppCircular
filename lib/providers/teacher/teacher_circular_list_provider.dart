import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/config.dart';
import 'package:flexischool/models/student/student_circular_doc_list_respnose.dart';
import 'package:flexischool/models/teacher/teacher_circular_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> fetchTeacherCircularListData(
      {required int employeeId, required String fromDate, required String endDate}) async {
    try {
      loaderProvider.showLoader();
      var data = {
        'EMPLOYEE_ID': employeeId,
        'FROM_DATE': fromDate,
        'TO_DATE': endDate,
        'SESSION_ID': Constants.sessionId
      };
      final response = await apiService.post(url: Api.getTeacherCircularListApi, data: data);
      if (response.statusCode == 200) {
        teacherCircularListResponse = TeacherCircularListResponse.fromJson(response.data);
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

  Future<StudentCircularDocumentListResponse> fetchTeacherDocumentData({required int circularId}) async {
    var studentCircularDocumentListResponse = StudentCircularDocumentListResponse();
    try {
      loaderProvider.showLoader();
      var data = {"APP_CIRCULAR_ID": circularId};
      final response = await apiService.post(url: Api.studentDocumentListApi, data: data);
      if (response.statusCode == 200) {
        studentCircularDocumentListResponse = StudentCircularDocumentListResponse.fromJson(response.data);
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

  Future<void> requestWritePermission(BuildContext context) async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
    } else {
      if (context.mounted) {
        ShowSnackBar.error(context: context, showMessage: 'Write permission denied.');
      }
    }
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

    // final directory = await getExternalStorageDirectory();

    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationSupportDirectory();
    }

    if (directory == null) {
      debugPrint('Error: Unsupported platform.');
      return;
    }

    final savePath = '${directory.path}/$fileName';
    debugPrint('save Path $savePath');
    debugPrint('download url ${Api.imageBaseUrl + url}');

    try {
      final dio = Dio();
      await dio.download(
        '${Api.imageBaseUrl}/$url',
        savePath,
        onReceiveProgress: (received, total) async {
          int progress = ((received / total) * 100).toInt();
          debugPrint('progress---> $progress');
          if (Platform.isAndroid) {
            await NotificationService.showNotification(
              channelId: 1,
              title: fileName,
              body: "",
              summary: "",
              progress: progress,
              notificationLayout: NotificationLayout.ProgressBar,
            );
          }
          //  NotificationService().showProgressNotification(progress, fileName);
        },
      );
      await NotificationService.cancelProgressNotification();
      await NotificationService.showNotification(
        channelId: 2,
        title: fileName,
        body: "",
        summary: "",
        payload: {"path": savePath},
      );
      //  NotificationService().cancelProgressNotification();
      //  NotificationService().showNotification(savePath, fileName);
    } catch (e) {
      debugPrint('Error during file download: $e');
    }
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
}
