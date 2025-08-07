import 'dart:convert';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/dashboard_model.dart';
import 'package:flexischool/models/student/session_list_response.dart';
import 'package:flexischool/models/teacher/teacher_session_response.dart';
import 'package:flexischool/models/user_model.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flexischool/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TeacherDashboardProvider extends ChangeNotifier {
  final apiService = ApiService();
  TeacherSessionResponse? teacherSessionResponse;
  List<DashboardResponse>? dashboardData;
  bool _isDashboardLoading = false;
  String? _dashboardError;

  int? _selectedTeacherSessionDropDownValue;

  int? get selectedTeacherSessionDropDownValue => _selectedTeacherSessionDropDownValue;

  String _sessionYear = '';

  String get sessionYear => _sessionYear;

  bool get isDashboardLoading => _isDashboardLoading;
  String? get dashboardError => _dashboardError;

  Future<void> fetchDashboard() async {
    // Return cached data if available
    if (dashboardData != null && dashboardData!.isNotEmpty) {
      return;
    }

    try {
      _isDashboardLoading = true;
      _dashboardError = null;
      notifyListeners();

      var schoolBaseUrl = await WebService.getSchoolUrl();
      var loginType = await WebService.getLoginType();
      debugPrint('Login type ****** $loginType');

      var requestedData = {"Type": loginType};
      var body = json.encode(requestedData);

      final response = await apiService.post(
          url: '${schoolBaseUrl!}DashboardForTeacher/DashboardForTeacher', data: body);

      final responseData = response.data;
      debugPrint("dashboard data ===> $responseData");

      if (responseData['lstDashobaord'] != null) {
        final List<dynamic> dashboardList = responseData['lstDashobaord'];
        dashboardData = dashboardList.map((json) => DashboardResponse.fromJson(json)).toList();
        _dashboardError = null;
      } else {
        _dashboardError = 'Dashboard data is null';
        dashboardData = [];
      }
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
      _dashboardError = 'Failed to load dashboard data: $e';
      dashboardData = [];
    } finally {
      _isDashboardLoading = false;
      notifyListeners();
    }
  }

  void clearDashboardCache() {
    dashboardData = null;
    _dashboardError = null;
    _isDashboardLoading = false;
    notifyListeners();
  }

  Future<void> getSessionData() async {
    var requestedData = {"SCHOOL_ID": "1"};
    var body = json.encode(requestedData);
    try {
      final response = await apiService.post(url: Api.getTeacherSessionApi, data: body);
      if (response.statusCode == 200) {
        teacherSessionResponse = TeacherSessionResponse.fromJson(response.data);

        var sessionData = teacherSessionResponse?.sessionDD?.firstWhere((data) => data.aCTIVE == 'Y');
        if (sessionData != null) {
          _selectedTeacherSessionDropDownValue = sessionData.sESSIONID;
          Constants.sessionId = sessionData.sESSIONID!;
          _sessionYear =
              '${(sessionData.sTARTDATE)?.substring(0, 4)}-${sessionData.eNDDATE!.substring(0, 4)}';

          Constants.startDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
          Constants.endDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
          Constants.lastDate = sessionData.eNDDATE!;
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
    clearDashboardCache(); // Clear dashboard cache when session changes
    var sessionData = teacherSessionResponse?.sessionDD?.firstWhere((data) => data.sESSIONID == newValue);
    if (sessionData != null) {
      _sessionYear = '${(sessionData.sTARTDATE)?.substring(0, 4)}-${sessionData.eNDDATE!.substring(0, 4)}';
      // Constants.startDate = sessionData.sTARTDATE!;
      // Constants.endDate = sessionData.eNDDATE!;

      if (sessionData.aCTIVE == 'Y') {
        Constants.startDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
        Constants.endDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
      } else {
        Constants.startDate = sessionData.sTARTDATE!;
        Constants.endDate = sessionData.eNDDATE!;
      }
      Constants.lastDate = sessionData.eNDDATE!;
    }
    fetchDashboard(); // Fetch dashboard for new session
    notifyListeners();
  }

  Future<void> teacherLogout(BuildContext context) async {
    // Stop the continuous API call timer before logout
    apiService.stop();
    
    try {
      final appDeviceId = await WebService.getAppDeviceId();
      final response =
          await apiService.post(url: Api.removeFcmTokenApi, data: {"APP_DEVICE_ID": appDeviceId});
      if (response.statusCode == 200) {
        SessionListResponse.fromJson(response.data);
        if (context.mounted) {
          final LoginProvider loginStore = Provider.of<LoginProvider>(context, listen: false);
          loginStore.userLogout();
          AppBadgePlus.updateBadge(0);
                      Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Home()),
            );
        }
      } else {}
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> callRefreshApi() async {
    final teacherData = await WebService.getUserDetails();
    final data = User.fromJson(teacherData);
    apiService.startContinueListening(
        data: {"EMPLOYEE_ID": data.EMPLOYEEID.toString(), "USER_TYPE": "T"},
        url: "${Api.baseUrl}getDeviceDetailbyADM_NO/getDeviceDetailbyADM_NO");
  }
}
