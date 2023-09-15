import 'dart:convert';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/common_model.dart';
import 'package:flexischool/models/student/notification_list_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get_it/get_it.dart';
import 'package:quill_json_to_html/json_to_html.dart';

final GetIt getIt = GetIt.instance;

class StudentNotificationProvider extends ChangeNotifier {
  final loaderProvider = getIt<LoaderProvider>();
  NotificationListResponse? notificationListResponse;
  final apiService = ApiService();

  String? _message;

  String? get message => _message;

  final QuillController _controller = QuillController.basic();

  String getContentAsHTML(String jsonString) {
    try {
      final dynamic jsonData = jsonDecode(jsonString);
      if (jsonData is List) {
        return QuillJsonToHTML.encodeJson(jsonData);
      } else if (jsonData is String) {
        // Handle the case when jsonData is a single string
        return jsonData;
      } else {
        // Handle other unexpected data types
        return "Invalid JSON data";
      }
    } catch (e) {
      // Handle JSON decoding errors
      return "Error decoding JSON: $e";
    }
  }

  Future<void> fetchNotificationData() async {
    try {
      _message = null;
      loaderProvider.showLoader();
      var data = {"STUDENT_ID": WebService.studentLoginData?.table1?.first.aDMSTUDENTID};
      final response = await apiService.post(url: Api.notificationListApi, data: data);
      if (response.statusCode == 200) {
        notificationListResponse = NotificationListResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        if (notificationListResponse!.notification!.isEmpty) {
          _message = 'No notification found';
        }
        notifyListeners();
      } else {
        notificationListResponse = NotificationListResponse();
        loaderProvider.hideLoader();
        _message = 'Something wents wrong';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      notificationListResponse = NotificationListResponse();
      loaderProvider.hideLoader();
      _message = e.toString();
      notifyListeners();
    }
  }

  Future<void> notificationUpdate(int? notificationId, int index) async {
    try {
      var data = {"NOTIFICATION_ID": notificationId};
      final response = await apiService.post(url: Api.notificationUpdateApi, data: data);
      if (response.statusCode == 200) {
        final commonResponse = CommonResponse.fromJson(response.data);
        if (commonResponse.success ?? false) {
          if (notificationListResponse != null && notificationListResponse!.notification!.isNotEmpty) {
            notificationListResponse?.notification![index].nOTIFICATIONFLAG = 'Y';
          }
        }
        notifyListeners();
      } else {}
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      notifyListeners();
    }
  }
}
