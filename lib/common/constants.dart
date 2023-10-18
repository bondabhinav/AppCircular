import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String appName = 'Flexi School';
  static const int maxItems = 10;
  static const String baseUrl = 'https://androidschool.sapinfotek.com/API/Version/';
  static int sessionId = 0;
  static String teacherSessionYear = '';
  static String currentDate = getCurrentDate();
  static String startDate = '';
  static String endDate = '';
  static String lastDate = '';
  static bool isAppBadgeSupported = false;

  static String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }

  static String getFormattedDate(String date) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(date));
    return formattedDate;
  }

  static Future<void> isSupportBadgeOrNot() async {
    if (await FlutterAppBadger.isAppBadgeSupported()) {
      isAppBadgeSupported = true;
      debugPrint('if part isAppBadgeSupported==> $isAppBadgeSupported');
    } else {
      isAppBadgeSupported = false;
      debugPrint('else part isAppBadgeSupported==> $isAppBadgeSupported');
    }
  }
}

const String robotoSemiBold = 'RobotoMono-SemiBold';
const String robotoRegular = 'RobotoMono-Regular';
const String robotoMedium = 'RobotoMono-Medium';
const String robotoBold = 'RobotoMono-Bold';
