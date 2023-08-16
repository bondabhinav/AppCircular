import 'dart:async';
import 'dart:convert';

import 'package:flexischool/common/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../models/schoolUrl_model.dart';

enum UrlStatus { notUrlIn, urlIn }

class UrlProvider extends ChangeNotifier {
  //String myValue = 'Hello, World!';

  UrlStatus _urlInStatus = UrlStatus.notUrlIn;

  UrlStatus get urInStatus => _urlInStatus;

  // UrlStatus get urInStatus {
  //   return _urlInStatus;
  // }

  set urlInStatus(UrlStatus value) {
    _urlInStatus = value;
  }

  //get URl
  Future getUrl(String _url) async {
    var result;
    var requestedData = {
      "SCHOOL_URL": _url,
    };
    var body = json.encode(requestedData);

    try {
      final response = await http.post(
        Uri.parse(Constants.baseUrl + 'GetURL'),
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

        final SchoolurlResponse = SchoolUrl.fromJson(responseSplit);
        final preferences = await SharedPreferences.getInstance();

        var res = SchoolurlResponse.toJson();
        await preferences.setString(
          'school_url_response',
          json.encode(SchoolurlResponse.toJson()),
        );

        final schoolLogo = res['SCHOOL_URL'] + "/code/img/";
        await preferences.setString('global_school_url', res['API_URL']);

        await preferences.setString('global_school_logo', schoolLogo);

        await preferences.setString('global_school_image_url', res['API_IMAGE']);

        Api.baseUrl = res['API_URL'];
        Api.imageBaseUrl = res['API_IMAGE'];
        notifyListeners();

        return result = {
          'status': true,
          //'api' : res['API_URL'],
          'message': 'School Details has been fetched Successfully!',
          'data': json.encode(SchoolurlResponse.toJson())
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
      return result = {'status': false, 'message': 'Something went wrong please try again.', 'data': ''};
    }
  }

  notify() {
    notifyListeners();
  }
}
