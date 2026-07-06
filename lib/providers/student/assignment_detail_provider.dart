import 'dart:convert';

// Removed: import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/auth_middleware.dart';
import 'package:flexischool/download_file.dart';
import 'package:flexischool/models/student/assignment_detail_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/providers/student/student_notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

  Future<void> fetchAssignmentDetailData(
    int assignmentId,
    int sessionId,
    int? notificationId,
  ) async {
    try {
      loaderProvider.showLoader();
      var data = {"APP_ASSIGNMENT_ID": assignmentId, "SESSION_ID": sessionId};
      final response = await apiService.post(
        url: Api.getAssignmentByIdApi,
        data: data,
      );
      if (response.statusCode == 200) {
        assignmentDetailResponse = AssignmentDetailResponse.fromJson(
          response.data,
        );
        loaderProvider.hideLoader();
        if (notificationId != null) {
          Provider.of<StudentNotificationProvider>(
            AuthMiddleware.navigatorKey.currentContext!,
            listen: false,
          ).notificationUpdate(notificationId).then((value) {
            if (value.success ?? false) {
              Provider.of<StudentDashboardProvider>(
                AuthMiddleware.navigatorKey.currentContext!,
                listen: false,
              ).getNotificationCount();
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

  Future<void> downloadFile(BuildContext context, String url) async {
    final String fileName = url.split('/').last;
    await DownloadPdf.downloadPdf(
      '${Api.imageBaseUrl}/$url',
      fileName,
      context,
      (message) => debugPrint('download message -> $message'),
    );
  }
}
