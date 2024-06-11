import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flexischool/common/auth_middleware.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:provider/provider.dart';
import 'package:unique_identifier/unique_identifier.dart';

class ApiService {
  late Dio _dio;
  String? _bearerToken;

  ApiService() {
    _dio = Dio();
    _dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      //  options.headers['Authorization'] = 'Bearer $_bearerToken';
      return handler.next(options);
    }));
  }

  Future<Response> get({required String url}) async {
    try {
      final options = Options(headers: {});
      if (_bearerToken != null) {
        options.headers?['Authorization'] = 'Bearer $_bearerToken';
      }
      final response = await _dio.get(url, options: options);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post({required String url, dynamic data}) async {
    try {
      final options = Options(headers: {});
      //  if (_bearerToken != null) {
      // options.headers?['Authorization'] = 'Bearer $_bearerToken';
      options.headers?['Content-Type'] = 'application/json';
      options.headers?['Accept'] = 'application/json';
      //   }
      final response = await _dio.post(url, data: data, options: options);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> loginPost({required String url, dynamic data}) async {
    try {
      final headers = <String, String>{};
      headers['Content-Type'] = 'application/json';
      headers['Accept'] = 'application/json';

      final response = await http.post(Uri.parse(url), headers: headers, body: json.encode(data));
      _logRequestResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> postMultipart({
    required String url,
    required FormData data,
  }) async {
    try {
      final options = Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      );
      final response = await _dio.post(url, data: data, options: options);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void _logRequestResponse(http.Response response) {
    final request = response.request;
    final requestLog = 'Request: ${request?.method} ${request?.url}\nHeaders: ${request?.headers}';
    final responseLog =
        'Response: ${response.statusCode}\nHeaders: ${response.headers}\nBody: ${response.body}';
    debugPrint('$requestLog\n$responseLog');
  }

  Timer? _timer;
  final Duration _interval = const Duration(seconds: 5);
  late dynamic uniqueId;

  Future<void> startContinueListening({required Map<String, String> data, required String url}) async {
    debugPrint('refresh api url -- $url');
    uniqueId = await UniqueIdentifier.serial ?? 'Unknown';
    debugPrint('uniqueId: $uniqueId');
    _timer = Timer.periodic(_interval, (timer) async {
      await _makeApiCall(data: data, url: url);
    });
  }

  void stop() => _timer?.cancel();

  Future<void> _makeApiCall({required Map<String, String> data, required String url}) async {
    try {
      final response = await compute(_fetchData, {'url': url, 'data': data});
      if (response.statusCode == 200) {
        _processResponse(response.body);
        debugPrint('continue response api data: ${response.body}');
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception: $e');
    }
  }

  Future<void> _processResponse(String responseBody) async {
    final data = jsonDecode(responseBody);
    log('response --- $data');
    log('uniqueId: $uniqueId');
    final List<dynamic> lstDevice = data['lstDevice'];
    bool allDevicesDifferent = lstDevice.every((device) => device['UNIQUE_ID'] != uniqueId);
    if (allDevicesDifferent) {
      debugPrint('Unique ID not found in the device list');
      stop();
      final LoginProvider loginStore =
          Provider.of<LoginProvider>(AuthMiddleware.navigatorKey.currentContext!, listen: false);
      loginStore.userLogout();
      FlutterAppBadger.removeBadge();
      Navigator.pushReplacementNamed(AuthMiddleware.navigatorKey.currentContext!, '/home');
    } else {
      debugPrint('Unique ID found in the device list');
    }
  }

  static Future<http.Response> _fetchData(Map<String, dynamic> params) async {
    final String url = params['url'];
    final Map<String, String> data = params['data'];
    debugPrint('test api url -- $url');
    final response = await http.post(Uri.parse(url), body: data);
    return response;
  }
}
