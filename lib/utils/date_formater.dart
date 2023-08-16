import 'package:intl/intl.dart';

class DateTimeUtils {
  static String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  static String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDateTime = DateFormat("d MMMM").format(dateTime);
    return formattedDateTime;
  }

  static String formatNextDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    DateTime oneDayAhead = dateTime.add(const Duration(days: 1));
    String formattedDateTime = DateFormat("d MMMM").format(oneDayAhead);
    return formattedDateTime;
  }
}
