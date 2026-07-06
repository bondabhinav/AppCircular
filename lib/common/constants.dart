import 'package:flutter/material.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:intl/intl.dart';

class Constants {
  static const String privacyPolicyUrl = 'http://privacy.sapinfotek.in';
  static const String appName = 'Flexi School';
  static const String applicationId = 'flexischoolerpapp.sapinfotek.com';
  static const int maxItems = 10;

  // static const String baseUrl = 'https://androidschool.sapinfotek.com/API/Version/';
  static const String baseUrl =
      'http://androidschool.sapinfotek.in/API/Version/';
  static int sessionId = 0;
  static String studentClassId = '';
  static String studentSectionId = '';
  static String teacherSessionYear = '';
  static String currentDate = getCurrentDate();
  static String sessionStartDate = '';
  static String startDate = '';
  static String endDate = '';
  static String lastDate = '';
  static bool isAppBadgeSupported = false;
  static String sessionYear = '';

  static String getCurrentDate() {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    return formattedDate;
  }

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime parseAppDate(String? date, {DateTime? fallback}) {
    if (date == null || date.trim().isEmpty) {
      return dateOnly(fallback ?? DateTime.now());
    }

    return dateOnly(DateTime.tryParse(date) ?? fallback ?? DateTime.now());
  }

  static String formatAppDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(dateOnly(date));
  }

  static DateTime clampDate(
    DateTime date, {
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    if (date.isBefore(firstDate)) {
      return firstDate;
    }
    if (date.isAfter(lastDate)) {
      return lastDate;
    }
    return date;
  }

  static void setSessionDateWindow({
    required String? sessionStartDate,
    required String? sessionEndDate,
    required bool isActive,
  }) {
    final today = dateOnly(DateTime.now());
    final sessionStart = parseAppDate(sessionStartDate, fallback: today);
    final sessionEnd = parseAppDate(sessionEndDate, fallback: sessionStart);
    final firstDate = sessionEnd.isBefore(sessionStart)
        ? sessionEnd
        : sessionStart;
    final lastDateValue = sessionEnd.isBefore(sessionStart)
        ? sessionStart
        : sessionEnd;

    sessionStartDate = formatAppDate(firstDate);
    if (isActive) {
      final selectedDate = clampDate(
        today,
        firstDate: firstDate,
        lastDate: lastDateValue,
      );
      startDate = formatAppDate(selectedDate);
      endDate = formatAppDate(selectedDate);
    } else {
      startDate = formatAppDate(firstDate);
      endDate = formatAppDate(lastDateValue);
    }
    lastDate = formatAppDate(lastDateValue);
  }

  static DateTime get datePickerFirstDate {
    final firstDate = parseAppDate(startDate);
    final lastDateValue = parseAppDate(lastDate, fallback: firstDate);
    return lastDateValue.isBefore(firstDate) ? lastDateValue : firstDate;
  }

  static DateTime get datePickerLastDate {
    final firstDate = parseAppDate(startDate);
    final lastDateValue = parseAppDate(lastDate, fallback: firstDate);
    return lastDateValue.isBefore(firstDate) ? firstDate : lastDateValue;
  }

  static DateTime datePickerInitialDate(DateTime preferredDate) {
    return clampDate(
      dateOnly(preferredDate),
      firstDate: datePickerFirstDate,
      lastDate: datePickerLastDate,
    );
  }

  static DateTime get scheduleDatePickerFirstDate {
    return parseAppDate(sessionStartDate, fallback: datePickerFirstDate);
  }

  static DateTime get scheduleDatePickerLastDate {
    final firstDate = scheduleDatePickerFirstDate;
    final lastDateValue = parseAppDate(lastDate, fallback: firstDate);
    return lastDateValue.isBefore(firstDate) ? firstDate : lastDateValue;
  }

  static DateTime scheduleDatePickerInitialDate(DateTime preferredDate) {
    return clampDate(
      dateOnly(preferredDate),
      firstDate: scheduleDatePickerFirstDate,
      lastDate: scheduleDatePickerLastDate,
    );
  }

  static String getFormattedDate(String date) {
    String formattedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.parse(date));
    return formattedDate;
  }

  static Future<void> isSupportBadgeOrNot() async {
    final isSupported = await AppBadgePlus.isSupported();
    if (isSupported) {
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
