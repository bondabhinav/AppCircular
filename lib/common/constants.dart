import 'package:intl/intl.dart';

class Constants {
  static const String appName = 'Flexi School';
  static const int maxItems = 10;
  static const String baseUrl = 'https://androidschool.sapinfotek.com/API/Version/';
  static int sessionId = 0;
  static String currentDate = getCurrentDate();

  static String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }
}

const String robotoSemiBold = 'RobotoMono-SemiBold';
const String robotoRegular = 'RobotoMono-Regular';
const String robotoMedium = 'RobotoMono-Medium';
const String robotoBold = 'RobotoMono-Bold';
