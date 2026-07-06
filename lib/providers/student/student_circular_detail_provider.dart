// Removed: import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/auth_middleware.dart';
import 'package:flexischool/download_file.dart';
import 'package:flexischool/models/student/student_circular_detail_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/providers/student/student_notification_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

final GetIt getIt = GetIt.instance;

class StudentCircularDetailProvider extends ChangeNotifier {
  final loaderProvider = getIt<LoaderProvider>();
  StudentCircularDetailResponse? studentCircularDetailResponse;
  final apiService = ApiService();

  String? _message;

  String? get message => _message;

  Future<void> fetchStudentCircularDetail(
    int id,
    int sessionId,
    int? notificationId,
  ) async {
    try {
      loaderProvider.showLoader();
      var data = {"APP_CIRCULAR_ID": id, "SESSION_ID": sessionId};
      final response = await apiService.post(
        url: Api.getCircularByIdApi,
        data: data,
      );
      if (response.statusCode == 200) {
        studentCircularDetailResponse = StudentCircularDetailResponse.fromJson(
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

        if (studentCircularDetailResponse!.classlist!.isEmpty) {
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
