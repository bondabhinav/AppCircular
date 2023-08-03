import 'dart:convert';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/student/session_list_response.dart';
import 'package:flexischool/models/student/student_detail_response.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class StudentDashboardProvider extends ChangeNotifier {
  final loaderProvider = getIt<LoaderProvider>();
  StudentDetailResponse? studentDetailResponse;
  SessionListResponse? sessionListResponse;
  final apiService = ApiService();
  String? _message;

  String? _sessionYear;

  String? get sessionYear => _sessionYear;

  String? get message => _message;

  int? _selectedSessionDropDownValue;

  int? get selectedSessionDropDownValue => _selectedSessionDropDownValue;

  Future<void> fetchStudentDetail() async {
    try {
      loaderProvider.showLoader();
      var data = {
        "ADM_NO": WebService.studentLoginData?.table1?.first.aDMNO,
        "SESSION_ID": selectedSessionDropDownValue
      };
      final response = await apiService.post(url: Api.studentDetailApi, data: data);
      if (response.statusCode == 200) {
        studentDetailResponse = StudentDetailResponse.fromJson(response.data);
        loaderProvider.hideLoader();
        if (studentDetailResponse!.getstudentData!.isEmpty) {
          _message = 'No detail found';
        }
        notifyListeners();
      } else {
        loaderProvider.hideLoader();
        _message = 'Something wents wrong';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
      loaderProvider.hideLoader();
      _message = e.toString();
      notifyListeners();
    }
  }

  Future<void> getSessionData() async {
    var requestedData = {"ADM_NO": WebService.studentLoginData?.table1?.first.aDMNO};
    var body = json.encode(requestedData);
    try {
      final response = await apiService.post(
        url: Api.studentSessionApi,
        data: body,
      );
      if (response.statusCode == 200) {
        sessionListResponse = SessionListResponse.fromJson(response.data);
        notifyListeners();
      } else {}
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
    }
  }

  void updateSession(newValue) {
    _selectedSessionDropDownValue = newValue!;
    Constants.sessionId = newValue;
    fetchStudentDetail();
    var sessionData = sessionListResponse?.table1?.firstWhere((data) => data.sESSIONID == newValue);
    if (sessionData != null) {
      _sessionYear = '${(sessionData.sTARTDATE)?.substring(0, 4)}-${sessionData.eNDDATE!.substring(0, 4)}';
    }
    notifyListeners();
  }

  void assignSessionValue() {
    final sessionData = WebService.studentLoginData?.table1?.first;
    _selectedSessionDropDownValue = sessionData?.sESSIONID!;
    _sessionYear = '${sessionData?.fROMSESSION} - ${sessionData?.tOSESSION}';
    notifyListeners();
  }
}
