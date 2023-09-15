import 'dart:async';
import 'dart:convert';

import 'package:flexischool/common/api_service.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/student/add_token_response.dart';
import 'package:flexischool/models/student/student_login_response.dart';
import 'package:flexischool/notification_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/helpers.dart';

enum LoginStatus { notLoggedIn, loggedIn }

class LoginProvider extends ChangeNotifier {
  final apiService = ApiService();
  String _userName = '';
  int _employee_id = 0;
  int _employeeCode = 0;
  String _depName = '';
  String _designation = '';
  String _photo = '';
  String _session = '2022 - 2023';

  LoginStatus _loginStatus = LoginStatus.notLoggedIn;

  LoginStatus get loginInStatus => _loginStatus;

  set loginInStatus(LoginStatus value) {
    _loginStatus = value;
  }

  get userName => _userName;

  set username(value) {
    _userName = value;
  }

  get employeeId => _employee_id;

  set employeeId(value) {
    _employee_id = value;
  }

  get employeeCode => _employeeCode;

  set employeeCode(value) {
    _employeeCode = value;
  }

  get depName => _depName;

  set depName(value) {
    _depName = value;
  }

  get designation => _designation;

  set designation(value) {
    _designation = value;
  }

  get photo => _photo;

  set photo(value) {
    _photo = value;
  }

  get session => _session;

  set session(value) {
    _session = value;
  }

  Future<void> userLogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("user_details");
    prefs.remove("global_login_type");
    prefs.remove("student_data");
    prefs.remove("fcmId");
    WebService.studentLoginData = null;
    //prefs.remove("global_school_url");

    _userName = '';
    _employee_id = 0;
    _employeeCode = 0;
    _depName = '';
    _designation = '';
    _photo = '';
    _session = '';

    notify();
  }

  Future<void> assignUserProvider() async {
    //var userInfo = await WebService.getUserDetails();

    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('user_details');

    if (userDetails != '') {
      var userInfo = jsonDecode(userDetails!);
      print(userInfo);

      final empLogo = prefs.getString('global_school_logo');
      String profileLogo = "${empLogo!}employee/" + userInfo['PHOTO'];

      _userName = userInfo['USER_NAME'];
      _employee_id = userInfo['EMPLOYEE_ID'];
      _employeeCode = userInfo['EMPLOYEE_CODE'] ?? '';
      _depName = toTitleCase(userInfo['DEPARTMENT_NAME']);
      _designation = userInfo['DESIGNATION_DESC'];
      //_photo = userInfo['PHOTO'] ?? '';
      _photo = profileLogo ?? '';

      //_session = '';

      notify();
    }
  }

  //Login Validate
  Future loginValidate(String _uname, String _pass) async {
    debugPrint('enter login teacher');
    var result;
    var requestedData = {"USER_LOGIN": _uname.trim(), "USER_PASSWORD": _pass.trim()};

    //Get School URL
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseUrl = prefs.getString('global_school_url');

    var body = json.encode(requestedData);

    try {
      final response = await http.post(
        Uri.parse('${schoolBaseUrl!}EmployeeLogin/GetteacherLogin'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          //"Authorization": token
        },
        body: body,
      );

      if (response.statusCode == 200) {
        // Handle successful response.
        final responseData = json.decode(response.body);
        final responseSplit = responseData['Table1'][0];

        print(responseSplit);
        // print('test1');
        final loginResponse = User.fromJson(responseSplit);
        //print('test');
        var res = loginResponse.toJson();

        //Store Local
        final preferences = await SharedPreferences.getInstance();
        await preferences.setString(
          'user_details',
          json.encode(loginResponse.toJson()),
        );
        // await preferences.setString('global_school_url',res['API_URL']);

        final empLogo = preferences.getString('global_school_logo');

        String profileLogo = "${empLogo!}employee/" + res['PHOTO'];

        //Store Local

        _userName = res['USER_NAME'];
        _employee_id = res['EMPLOYEE_ID'];
        _employeeCode = res['EMPLOYEE_CODE'] ?? '';
        _depName = toTitleCase(res['DEPARTMENT_NAME']);
        _designation = res['DESIGNATION_DESC'];
        _photo = profileLogo ?? '';

        print(res['USER_NAME']);

        return result = {
          'status': true,
          'message': 'You have successfully logged in!',
          'data': json.encode(loginResponse.toJson())
        };
      } else {
        //return 'Unexpected response: ${response.statusCode}';

        return result = {
          'status': false,
          'message': 'Unexpected response: ${response.statusCode}',
          'data': response
        };
      }
    } catch (e) {
      // _errorMessage = 'Error: $e';
      //return 'Something went wrong please try again.';
      return result = {'status': false, 'message': 'Invalid Login Credentials.', 'data': ''};
    }
  }

  // student login

  Future<String> studentLogin(String uname, String pass) async {
    debugPrint('enter login student');
    String result = '';
    var requestedData = {"STUD_USERID": uname.trim(), "STUD_PASSWORD": pass.trim()};
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseUrl = prefs.getString('global_school_url');
    try {
      final response = await apiService.loginPost(
          url: '${schoolBaseUrl!}StudentLogin/GetStudentLogin', data: requestedData);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final loginResponse = StudentLoginResponse.fromJson(responseData);
        debugPrint('responseData response ${responseData.toString()}');
        debugPrint('loginResponse response ${loginResponse.toJson().toString()}');
        if (loginResponse.table1!.isNotEmpty) {
          WebService.setStudentLoginDetails(loginResponse);
          WebService.studentLoginData = loginResponse;
          debugPrint("check push notification ${PushNotificationsManager().fcmToken}");
          if (PushNotificationsManager().fcmToken.isNotEmpty) {
            try {
              var data = {
                "ADM_NO": loginResponse.table1!.first.aDMNO!,
                "DEVICE_TOKEN": PushNotificationsManager().fcmToken
              };
              final response = await apiService.post(url: Api.addFcmTokenApi, data: data);
              if (response.statusCode == 200) {
             //   final responseData = json.decode(response.data);
                final addTokenResponse = AddTokenResponse.fromJson(response.data);
                debugPrint('fcm token api response ${addTokenResponse.toString()}');
                debugPrint('fcm token number ${addTokenResponse.nUMBER.toString()}');
                WebService.setFcmData(addTokenResponse.nUMBER.toString());
                result = 'You have successfully logged in!';
              } else {
                result = 'You have successfully logged in!';
              }
            } on Exception catch (e) {
              debugPrint(e.toString());
              result = 'You have successfully logged in!';
            }
          } else {
            result = 'You have successfully logged in!';
          }
        } else {
          result = 'Invalid Login Credentials.';
        }
        notifyListeners();
      } else {
        debugPrint('else part');
        result = 'Unexpected response: ${response.statusCode}';
        notifyListeners();
      }
    } catch (e) {
      debugPrint('catch part');
      result = 'Invalid Login Credentials.';
      notifyListeners();
    }

    return result;
  }

  //Notify Listeners
  notify() {
    notifyListeners();
  }
}
