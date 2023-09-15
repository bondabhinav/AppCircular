import 'dart:convert';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/models/teacher/teacher_session_response.dart';
import 'package:flutter/material.dart';

class TeacherDashboardProvider extends ChangeNotifier {
  final apiService = ApiService();
  TeacherSessionResponse? teacherSessionResponse;

  int? _selectedTeacherSessionDropDownValue;

  int? get selectedTeacherSessionDropDownValue => _selectedTeacherSessionDropDownValue;

  String _sessionYear = '';

  String get sessionYear => _sessionYear;

  Future<void> getSessionData() async {
    var requestedData = {"SCHOOL_ID": "1"};
    var body = json.encode(requestedData);
    try {
      final response = await apiService.post(
        url: Api.getTeacherSessionApi,
        data: body,
      );
      if (response.statusCode == 200) {
        teacherSessionResponse = TeacherSessionResponse.fromJson(response.data);

        var sessionData = teacherSessionResponse?.sessionDD?.firstWhere((data) => data.aCTIVE == 'Y');
        if (sessionData != null) {
          _selectedTeacherSessionDropDownValue = sessionData.sESSIONID;
          Constants.sessionId = sessionData.sESSIONID!;
          _sessionYear =
              '${(sessionData.sTARTDATE)?.substring(0, 4)}-${sessionData.eNDDATE!.substring(0, 4)}';
          Constants.startDate = sessionData.sTARTDATE!;
          Constants.endDate = sessionData.eNDDATE!;
        }
        notifyListeners();
        debugPrint('session id----> ${Constants.sessionId}');
      } else {}
    } catch (e) {
      debugPrint('Failed to connect to the API ${e.toString()}');
    }
  }

  void updateSession(newValue) {
    _selectedTeacherSessionDropDownValue = newValue!;
    Constants.sessionId = newValue;
    var sessionData = teacherSessionResponse?.sessionDD?.firstWhere((data) => data.sESSIONID == newValue);
    if (sessionData != null) {
      _sessionYear = '${(sessionData.sTARTDATE)?.substring(0, 4)}-${sessionData.eNDDATE!.substring(0, 4)}';
      Constants.startDate = sessionData.sTARTDATE!;
      Constants.endDate = sessionData.eNDDATE!;
    }
    notifyListeners();
  }
}
