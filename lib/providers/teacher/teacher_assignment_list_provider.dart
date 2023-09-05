import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/models/teacher/teacher_assignment_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

final GetIt getIt = GetIt.instance;

class TeacherAssignmentListProvider extends ChangeNotifier {
  final apiService = ApiService();
  final loaderProvider = getIt<LoaderProvider>();
  TeacherAssignmentListModel? teacherAssignmentListModel;
  final QuillController _controller = QuillController.basic();

  String _startDate = Constants.currentDate;

  String get startDate => _startDate;

  String _endDate = Constants.currentDate;

  String get endDate => _endDate;

  String? _message;

  String? get message => _message;

  Future<void> fetchTeacherAssignmentListData(
      {required int employeeId, required String fromDate, required String endDate}) async {
    try {
      _message = null;
      loaderProvider.showLoader();
      var data = {
        'EMPLOYEE_ID': employeeId,
        'FROM_DATE': fromDate,
        'TO_DATE': endDate,
        'SESSION_ID': Constants.sessionId
      };
      final response = await apiService.post(url: Api.getAssignmentByDatesApi, data: data);
      if (response.statusCode == 200) {
        teacherAssignmentListModel = TeacherAssignmentListModel.fromJson(response.data);
        _message = null;
        loaderProvider.hideLoader();
        if (teacherAssignmentListModel!.lstAssignment!.isEmpty) {
          _message = 'No assignment found';
        }
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        teacherAssignmentListModel = TeacherAssignmentListModel();
        _message = 'Something wents wrong';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      teacherAssignmentListModel = TeacherAssignmentListModel();
      loaderProvider.hideLoader();
      _message = e.toString();
      notifyListeners();
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

  Future<void> requestWritePermission(BuildContext context) async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
    } else {
      if (context.mounted) {
        ShowSnackBar.error(context: context, showMessage: 'Write permission denied.');
      }
    }
  }

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

  String getContentAsHTML(String jsonString) {
    // final List<dynamic> jsonData = jsonDecode(jsonString);
    // return QuillJsonToHTML.encodeJson(jsonData);

    List<Map<String, dynamic>> quillDelta = (jsonDecode(jsonString) as List).cast<Map<String, dynamic>>();
    Delta delta = Delta.fromJson(quillDelta);
    String plainText = delta.toList().where((op) => op.data != null).map((op) => op.data).join('');
    debugPrint('Plain Text ===> $plainText');
    return plainText;
  }
}
