import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/auth_middleware.dart';
import 'package:flexischool/models/student/assignment_detail_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/providers/student/student_notification_provider.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:quill_json_to_html/json_to_html.dart';

final GetIt getIt = GetIt.instance;

class AssignmentDetailProvider extends ChangeNotifier {
  AssignmentDetailResponse? assignmentDetailResponse;
  final loaderProvider = getIt<LoaderProvider>();
  final apiService = ApiService();

  String getContentAsHTML(String jsonString) {
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return QuillJsonToHTML.encodeJson(jsonData);
  }

  Future<void> fetchAssignmentDetailData(int assignmentId, int sessionId, int? notificationId) async {
    try {
      loaderProvider.showLoader();
      var data = {"APP_ASSIGNMENT_ID": assignmentId, "SESSION_ID": sessionId};
      final response = await apiService.post(url: Api.getAssignmentByIdApi, data: data);
      if (response.statusCode == 200) {
        assignmentDetailResponse = AssignmentDetailResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        if (notificationId != null) {
          Provider.of<StudentNotificationProvider>(AuthMiddleware.navigatorKey.currentContext!, listen: false)
              .notificationUpdate(notificationId)
              .then((value) {
            if (value.success ?? false) {
              Provider.of<StudentDashboardProvider>(AuthMiddleware.navigatorKey.currentContext!,
                      listen: false)
                  .getNotificationCount();
            }
          });
        }
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

  // Future<void> requestWritePermission(BuildContext context) async {
  //   PermissionStatus status = await Permission.storage.request();
  //   debugPrint('Assignment detail provider Permission status: $status');
  //   if (status.isGranted) {
  //   } else {
  //     if (context.mounted) {
  //       ShowSnackBar.error(context: context, showMessage: 'Write permission denied.');
  //     }
  //   }
  // }

  Future<bool> requestWritePermission() async {
    final DeviceInfoPlugin info = DeviceInfoPlugin();
    final AndroidDeviceInfo androidInfo = await info.androidInfo;
    debugPrint('releaseVersion : ${androidInfo.version.release}');
    final int androidVersion = int.parse(androidInfo.version.release);
    bool havePermission = false;

    if (androidVersion >= 13) {
      final request = await [Permission.videos, Permission.photos].request();
      havePermission = request.values.every((status) => status == PermissionStatus.granted);
    } else {
      final status = await Permission.storage.request();
      havePermission = status.isGranted;
    }

    if (!havePermission) {
      await openAppSettings();
    }
    return havePermission;
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
