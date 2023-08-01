import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dashboard_model.dart';
import 'config.dart';

class WebService {
  static getSchoolUrl() async {
    //Get School URL
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseUrl = prefs.getString('global_school_url');
    return schoolBaseUrl!;
  }

  static getLoginType() async {
    //Get School URL
    final prefs = await SharedPreferences.getInstance();
    final loginType = prefs.getString('global_login_type');
    return loginType!;
  }

  static  getUserDetails() async {
    //Get user Info
    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('user_details');
    var userInfo ='';
    if(userDetails != null){ userInfo = jsonDecode(userDetails!); }
    return userInfo;
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
  static Future<List<Dashboard>> fetchDashboard() async {

    var schoolBaseUrl = await getSchoolUrl();
    //await Future.delayed(Duration(seconds: 2));
    var loginType = await getLoginType();
    await Future.delayed(Duration(seconds: 1));
    var requestedData = {
      "Type": loginType,
    };

    var body = json.encode(requestedData);

    final response = await http.post(
      Uri.parse('${schoolBaseUrl!}DashboardForTeacher/DashboardForTeacher'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        //"Authorization": token
      },
      body: body,
    );
    final responseData = json.decode(response.body);
    final responseSplit = responseData['lstDashobaord'];
    return compute(parseDashboard, json.encode(responseSplit));

  }

  // A function that converts a response body into a List<Dashboard>.
  static List<Dashboard> parseDashboard(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
    return parsed.map<Dashboard>((json) => Dashboard.fromJson(json)).toList();
  }

}
