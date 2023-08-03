import 'package:intl/intl.dart';

class DateTimeUtils {

  static String formatDate(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  static String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String formattedDateTime = DateFormat("d MMMM | hh:mm a").format(dateTime);
    return formattedDateTime;
  }

}
