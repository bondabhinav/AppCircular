import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class DioClient {
  DioClient._();

  static Dio create({BaseOptions? options}) {
    final dio = Dio(options);
    dio.interceptors.add(_createLogger());
    return dio;
  }

  static PrettyDioLogger _createLogger() {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
      enabled: kDebugMode,
      logPrint: (object) => debugPrint(object.toString()),
      filter: (options, args) {
        if (!args.isResponse) {
          return true;
        }
        return !args.hasUint8ListData &&
            options.responseType != ResponseType.bytes &&
            options.responseType != ResponseType.stream;
      },
    );
  }
}
