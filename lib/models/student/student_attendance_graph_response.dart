class StudentAttendanceGraphResponse {
  dynamic april;
  dynamic may;
  dynamic june;
  dynamic july;
  dynamic august;
  dynamic september;
  dynamic october;
  dynamic november;
  dynamic december;
  dynamic january;
  dynamic february;
  dynamic march;

  StudentAttendanceGraphResponse(
      {this.april,
      this.may,
      this.june,
      this.july,
      this.august,
      this.september,
      this.october,
      this.november,
      this.december,
      this.january,
      this.february,
      this.march});

  StudentAttendanceGraphResponse.fromJson(Map<String, dynamic> json) {
    april = json['April'];
    may = json['May'];
    june = json['June'];
    july = json['July'];
    august = json['August'];
    september = json['September'];
    october = json['October'];
    november = json['November'];
    december = json['December'];
    january = json['January'];
    february = json['February'];
    march = json['March'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['April'] = april;
    data['May'] = may;
    data['June'] = june;
    data['July'] = july;
    data['August'] = august;
    data['September'] = september;
    data['October'] = october;
    data['November'] = november;
    data['December'] = december;
    data['January'] = january;
    data['February'] = february;
    data['March'] = march;
    return data;
  }

  List<String> getMonthNamesList() {
    return [
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
      'January',
      'February',
      'March',
    ];
  }
}

int getMonthDigit(String monthName) {
  switch (monthName.toLowerCase()) {
    case 'january':
      return 1;
    case 'february':
      return 2;
    case 'march':
      return 3;
    case 'april':
      return 4;
    case 'may':
      return 5;
    case 'june':
      return 6;
    case 'july':
      return 7;
    case 'august':
      return 8;
    case 'september':
      return 9;
    case 'october':
      return 10;
    case 'november':
      return 11;
    case 'december':
      return 12;
    default:
      return 0;
  }
}
