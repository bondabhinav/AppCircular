import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/models/student/student_login_response.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dashboard_model.dart';

class WebService {
  static SharedPreferences? _preferences;
  static StudentLoginResponse? studentLoginData;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static clearAllPref() async {
    _preferences?.remove("user_details");
    _preferences?.remove("global_login_type");
    _preferences?.remove("student_data");
    WebService.studentLoginData = null;
  }

  static getSchoolUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseUrl = prefs.getString('global_school_url');
    return schoolBaseUrl ?? '';
  }

  static getSchoolImageUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseImageUrl = prefs.getString('global_school_image_url');
    return schoolBaseImageUrl ?? '';
  }

  static getLoginType() async {
    final prefs = await SharedPreferences.getInstance();
    final loginType = prefs.getString('global_login_type');
    return loginType!;
  }

  // static getUserDetails() async {
  //   //Get user Info
  //   final prefs = await SharedPreferences.getInstance();
  //   final userDetails = prefs.getString('user_details');
  //   var userInfo = '';
  //   if (userDetails != null) {
  //     userInfo = jsonDecode(userDetails);
  //   }
  //   return userInfo;
  // }

  static Future<Map<String, dynamic>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('user_details');
    if (userDetails != null) {
      return jsonDecode(userDetails) as Map<String, dynamic>;
    } else {
      throw Exception('User details not found');
    }
  }

  static setStudentLoginDetails(StudentLoginResponse loginResponse) async {
    await _preferences?.setString("student_data", json.encode(loginResponse));
  }

  static setAppDeviceId(String appDeviceId) async {
    await _preferences?.setString("appDeviceId", appDeviceId);
  }

  static Future<String?> getAppDeviceId() async {
    final value = await _preferences?.get("appDeviceId").toString();
    return value;
  }

  static getTeacherDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('teacher_data');
    dynamic userInfo;
    if (userDetails != null) {
      userInfo = jsonDecode(userDetails);
    }
    return userInfo;
  }

  static setTeacherLoginDetails(dynamic loginResponse) async {
    await _preferences?.setString("teacher_data", json.encode(loginResponse));
  }

  static Future<StudentLoginResponse?> getStudentLoginDetails() async {
    try {
      final loginResponseString = await _preferences?.getString('student_data');
      if (loginResponseString != null) {
        final loginResponseJson = json.decode(loginResponseString);
        return StudentLoginResponse.fromJson(loginResponseJson);
      }
      return null;
    } catch (e) {
      debugPrint('Error reading loginResponse from Flutter shared pref: $e');
      return null;
    }
  }

  //API Call : Dashboard
  // static Future fetchDashboard1(String type) async {
  //   //Map<String, Object> returnData;
  //   var returnData;
  //   var requestedData = {
  //     "Type":type,
  //
  //   };
  //
  //   var schoolBaseUrl = await getSchoolUrl();
  //   //await Future.delayed(Duration(seconds: 2));
  //
  //   var body = json.encode(requestedData);
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse('${schoolBaseUrl!}DashboardForTeacher/DashboardForTeacher'),
  //       headers: {
  //         "Accept": "application/json",
  //         "Content-Type": "application/json",
  //         //"Authorization": token
  //       },
  //       body: body,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       // Handle successful response.
  //       final responseData = json.decode(response.body);
  //       final responseSplit = responseData['lstDashobaord'];
  //
  //       //final parsed = jsonDecode(responseSplit).cast<Map<String, dynamic>>();
  //      // var res = parsed.map<Dashboard>((json) => Dashboard.fromJson(json)).toList();
  //
  //
  //       returnData = {
  //         'status': true,
  //         'message': 'Successfully Load dashboard!',
  //         //'data': json.encode(responseSplit.toJson())
  //         'data': responseSplit
  //       };
  //     } else {
  //       //return 'Unexpected response: ${response.statusCode}';
  //
  //       returnData = {
  //         'status': false,
  //         'message': 'Unexpected response: ${response.statusCode}',
  //         'data': response
  //       };
  //     }
  //   } catch (e) {
  //     // _errorMessage = 'Error: $e';
  //     returnData = {
  //       'status': false,
  //       'message': 'Something went wrong please try again. $e',
  //       'data':''
  //     };
  //   }
  //
  //   return returnData;
  //
  // }

  //API Call : Dashboard
  //Dashboard API Call
  static Future<List<DashboardResponse>> fetchDashboard() async {
    try {
      var schoolBaseUrl = await getSchoolUrl();
      var loginType = await getLoginType();
      debugPrint('Login type ****** $loginType');

      var requestedData = {"Type": loginType};
      var body = json.encode(requestedData);

      final response = await ApiService()
          .post(url: '${schoolBaseUrl!}DashboardForTeacher/DashboardForTeacher', data: body);

      final responseData = response.data;
      log("dashboard data ===> $responseData");

      if (responseData['lstDashobaord'] != null) {
        final List<dynamic> dashboardList = responseData['lstDashobaord'];
        return dashboardList.map((json) => DashboardResponse.fromJson(json)).toList();
      } else {
        throw Exception('Dashboard data is null');
      }
    } catch (e) {
      debugPrint('Error fetching dashboard: $e');
      throw Exception('Failed to load dashboard data: $e');
    }
  }
}
