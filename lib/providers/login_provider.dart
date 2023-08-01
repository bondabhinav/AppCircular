import 'package:flexischool/common/webService.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/constants.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import '../utils/helpers.dart';

enum LoginStatus { notLoggedIn, loggedIn }

class LoginProvider extends ChangeNotifier {
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
      String profileLogo = empLogo! + "employee/" + userInfo['PHOTO'];

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
    var result;
    var requestedData = {"USER_LOGIN": _uname, "USER_PASSWORD": _pass};

    //Get School URL
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseUrl = prefs.getString('global_school_url');

    var body = json.encode(requestedData);

    try {
      final response = await http.post(
        Uri.parse(schoolBaseUrl! + 'EmployeeLogin/GetteacherLogin'),
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

        String profileLogo = empLogo! + "employee/" + res['PHOTO'];

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
      return result = {
        'status': false,
        'message': 'Invalid Login Credentials.',
        'data': ''
      };
    }
  }

  //Notify Listeners
  notify() {
    notifyListeners();
  }
}
