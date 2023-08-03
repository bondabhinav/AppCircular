import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:http/http.dart' as http;

class ApiService {
  late Dio _dio;
  String? _bearerToken;

  ApiService() {
    _dio = Dio();
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          //  options.headers['Authorization'] = 'Bearer $_bearerToken';
          return handler.next(options);
        },
      ),
    );
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
      throw e;
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
    final responseLog = 'Response: ${response.statusCode}\nHeaders: ${response.headers}\nBody: ${response.body}';
    print('$requestLog\n$responseLog');
  }

}
