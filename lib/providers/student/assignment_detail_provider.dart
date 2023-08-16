import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:dio/dio.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/config.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/student/assignment_detail_response.dart';
import 'package:flexischool/models/student/student_assignment_model.dart';
import 'package:flexischool/models/student/student_circular_doc_list_respnose.dart';
import 'package:flexischool/models/student/student_circular_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quill_json_to_html/json_to_html.dart';
import 'package:table_calendar/table_calendar.dart';

final GetIt getIt = GetIt.instance;

class AssignmentDetailProvider extends ChangeNotifier {
  AssignmentDetailResponse? assignmentDetailResponse;
  final QuillController _controller = QuillController.basic();
  final loaderProvider = getIt<LoaderProvider>();
  final apiService = ApiService();

  String getContentAsHTML(String jsonString) {
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return QuillJsonToHTML.encodeJson(jsonData);
  }

  Future<void> fetchAssignmentDetailData(int assignmentId) async {
    try {
      loaderProvider.showLoader();
      var data = {"APP_ASSIGNMENT_ID": assignmentId, "SESSION_ID": Constants.sessionId};
      final response = await apiService.post(url: Api.getAssignmentByIdApi, data: data);
      if (response.statusCode == 200) {
        assignmentDetailResponse = AssignmentDetailResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        notifyListeners();
      } else {
        assignmentDetailResponse = AssignmentDetailResponse();
        loaderProvider.hideLoader();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      assignmentDetailResponse = AssignmentDetailResponse();
      loaderProvider.hideLoader();
      notifyListeners();
    }
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
}
