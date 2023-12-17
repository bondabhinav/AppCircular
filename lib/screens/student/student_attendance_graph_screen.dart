import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flexischool/models/student/student_attendance_graph_response.dart';
import 'package:flexischool/providers/student/student_attendance_provider.dart';
import 'package:flexischool/screens/student/absent_present_student_calender_screen.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/loader_provider.dart';

class StudentAttendanceGraphScreen extends StatefulWidget {
  const StudentAttendanceGraphScreen({super.key});

  @override
  State<StudentAttendanceGraphScreen> createState() => _StudentAttendanceGraphScreenState();
}

class _StudentAttendanceGraphScreenState extends State<StudentAttendanceGraphScreen> {
  late StudentAttendanceProvider studentAttendanceProvider;
  final loaderProvider = getIt<LoaderProvider>();

  int touchedIndex = -1;
  late int showingTooltip;

  @override
  void initState() {
    showingTooltip = -1;
    super.initState();
    studentAttendanceProvider = StudentAttendanceProvider();
    studentAttendanceProvider.fetchAttendanceGraphData();
    studentAttendanceProvider.fetchOverAllPercentageData();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => studentAttendanceProvider,
        builder: (context, child) {
          return Consumer<StudentAttendanceProvider>(builder: (context, model, _) {
            return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    leading: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context)),
                    title: const Text('Attendance', style: TextStyle(color: Colors.white))),
                body: (loaderProvider.isLoading)
                    ? const Center(child: CustomLoader())
                    : model.studentAttendanceGraphResponse == null
                        ? const Center(
                            child: Text('No data found',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: "Montserrat Regular",
                                    color: Colors.black)),
                          )
                        : Column(
                            children: [
                              const SizedBox(height: 70),
                              AspectRatio(
                                  aspectRatio: 1,
                                  child: BarChart(BarChartData(
                                      borderData: FlBorderData(
                                        show: true,
                                        border: const Border(
                                          left: BorderSide(color: Colors.black, width: 2),
                                          bottom: BorderSide(color: Colors.black, width: 2),
                                        ),
                                      ),
                                      gridData: const FlGridData(
                                          show: true, drawHorizontalLine: true, drawVerticalLine: false),
                                      barTouchData: BarTouchData(
                                          enabled: true,
                                          handleBuiltInTouches: false,
                                          touchCallback: (event, response) {
                                            if (response != null &&
                                                response.spot != null &&
                                                event is FlTapUpEvent) {
                                              setState(() {
                                                final x = response.spot!.touchedBarGroup.x;
                                                final isShowing = showingTooltip == x;
                                                if (isShowing) {
                                                  showingTooltip = -1;
                                                } else {
                                                  showingTooltip = x;
                                                }
                                                debugPrint('response ${response.spot!.touchedBarGroupIndex}');

                                                List<String> monthNamesList =
                                                    model.studentAttendanceGraphResponse!.getMonthNamesList();

                                                String monthName =
                                                    monthNamesList[response.spot!.touchedBarGroupIndex];
                                                Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                AbsentPresentStudentCalenderScreen(
                                                                    month: getMonthDigit(monthName))))
                                                    .then((value) {
                                                  model.fetchAttendanceGraphData();
                                                });
                                              });
                                            }
                                          },
                                          mouseCursorResolver: (event, response) {
                                            return response == null || response.spot == null
                                                ? MouseCursor.defer
                                                : SystemMouseCursors.click;
                                          },
                                          touchTooltipData: BarTouchTooltipData(
                                              tooltipMargin: -10, tooltipBgColor: Colors.transparent)),
                                      barGroups: getData(model.studentAttendanceGraphResponse!),
                                      minY: 0,
                                      maxY: 100,
                                      titlesData: FlTitlesData(
                                        rightTitles:
                                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        topTitles:
                                            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                            reservedSize: 30,
                                            showTitles: true,
                                            getTitlesWidget: (value, meta) {
                                              for (int i = 0; i <= 100; i += 20) {
                                                if (value == i) {
                                                  return Padding(
                                                    padding: const EdgeInsets.only(right: 5),
                                                    child: Text(i.toString(),
                                                        textAlign: TextAlign.right,
                                                        style: const TextStyle(fontSize: 12)),
                                                  );
                                                }
                                              }
                                              return const Text("");
                                            },
                                          ),
                                          drawBelowEverything: true,
                                        ),
                                        bottomTitles: AxisTitles(
                                          axisNameSize: 1,
                                          drawBelowEverything: true,
                                          sideTitles: SideTitles(
                                              getTitlesWidget: (value, meta) {
                                                List<String> months = model.studentAttendanceGraphResponse!
                                                    .toJson()
                                                    .keys
                                                    .toList();
                                                if (value.toInt() >= 0 && value.toInt() < months.length) {
                                                  return Text(getShortMonth(months[value.toInt()]),
                                                      style: const TextStyle(fontSize: 10));
                                                }
                                                return const Text("");
                                              },
                                              showTitles: true,
                                              reservedSize: 30,
                                              interval: 1),
                                        ),
                                      )))),
                              if (model.overAllAttendanceResponse != null)
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10, left: 20),
                                    child: Row(
                                      children: [
                                        const Text('Overall attendance:- '),
                                        Text(
                                          '${double.parse((model.overAllAttendanceResponse?.attendance ?? '').toString()).toStringAsFixed(2)}%',
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Montserrat Regular'),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ));
          });
        });
  }

  String getShortMonth(String fullMonth) {
    final Map<String, String> shortMonths = {
      "April": "Apr",
      "May": "May",
      "June": "Jun",
      "July": "Jul",
      "August": "Aug",
      "September": "Sep",
      "October": "Oct",
      "November": "Nov",
      "December": "Dec",
      "January": "Jan",
      "February": "Feb",
      "March": "Mar",
    };

    return shortMonths[fullMonth] ?? fullMonth;
  }

  List<Color> barColors = List.generate(12,
      (index) => Color.fromRGBO(Random().nextInt(256), Random().nextInt(256), Random().nextInt(256), 1.0));

  List<BarChartGroupData> getData(StudentAttendanceGraphResponse studentAttendanceGraphResponse) {
    List<BarChartGroupData> bars = [];
    List<String> months = studentAttendanceGraphResponse.toJson().keys.toList();

    for (int i = 0; i < months.length; i++) {
      String month = months[i];
      double value = studentAttendanceGraphResponse.toJson()[month] ?? 0.0;
      value = double.parse(value.toStringAsFixed(2));
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: barColors[i],
              width: 20,
              borderRadius:
                  const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
    }

    return bars;
  }
}
