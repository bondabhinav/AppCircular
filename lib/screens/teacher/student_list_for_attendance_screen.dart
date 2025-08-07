import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/teacher/attendance_provider.dart';
import 'package:flexischool/widgets/custom_loader.dart';
import 'package:flexischool/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentListForAttendanceScreen extends StatefulWidget {
  final int teacherId;
  final bool isMarked;

  const StudentListForAttendanceScreen({super.key, required this.teacherId, required this.isMarked});

  @override
  State<StudentListForAttendanceScreen> createState() => _StudentListForAttendanceScreenState();
}

class _StudentListForAttendanceScreenState extends State<StudentListForAttendanceScreen> 
    with SingleTickerProviderStateMixin {
  AttendanceProvider? attendanceProvider;
  final loaderProvider = getIt<LoaderProvider>();
  late AnimationController _animationController;

  @override
  void initState() {
    attendanceProvider = Provider.of<AttendanceProvider>(context, listen: false);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(builder: (context, model, _) {
      return Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: MaterialButton(
                minWidth: double.infinity,
                color: Colors.blueAccent,
                height: 50,
                onPressed: () {
                  if (widget.isMarked) {
                    if (model.submittedMarkedList.isNotEmpty) {
                      model.applyMarkedAttendance().then((value) {
                        if (value != null) {
                          if (value.success ?? false) {
                            model.submittedMarkedList.clear();
                            ShowSnackBar.successToast(
                                context: context, showMessage: 'Attendance marked successfully!');
                          //  model.disposeAndNavigateToDashboard(context);
                            Navigator.pop(context,true);
                          } else {
                            ShowSnackBar.error(context: context, showMessage: value.errorMessage.toString());
                          }
                        } else {
                          ShowSnackBar.error(context: context, showMessage: 'Something wents wrong');
                        }
                      });
                    }
                  } else {
                    if (model.studentAttendanceList.isNotEmpty) {
                      model.applyAttendance(teacherId: widget.teacherId).then((value) {
                        if (value != null) {
                          if (value.errorMessage == null) {
                            ShowSnackBar.successToast(
                                context: context, showMessage: 'Attendance marked successfully!');
                        //    model.disposeAndNavigateToDashboard(context);
                            Navigator.pop(context,true);
                          } else {
                            ShowSnackBar.error(context: context, showMessage: value.errorMessage.toString());
                          }
                        } else {
                          ShowSnackBar.error(context: context, showMessage: 'Something wents wrong');
                        }
                      });
                    }
                  }
                },
                child: const Text('Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      fontFamily: "Montserrat Regular",
                      color: Colors.white,
                    ))),
            appBar: AppBar(
              leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context,true)),
              centerTitle: true,
              title: const Text('Attendance', style: TextStyle(color: Colors.white)),
            ),
            body: SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 50, top: 5, left: 5, right: 5),
                  child: widget.isMarked
                      ? markedStudentDatatable(model)
                      : model.studentResponse == null
                          ? const SizedBox()
                          : unmarkedStudentDataTable(model)),
            ),
          ),
          if (loaderProvider.isLoading) const Center(child: CustomLoader())
        ],
      );
    });
  }

  Color _getAttendanceColor(String? attendance) {
    switch (attendance) {
      case 'Present':
        return const Color(0xFFE8F5E9);
      case 'Absent':
        return const Color(0xFFFFEBEE);
      case 'Half Day':
        return const Color(0xFFF3E5F5);
      case 'Leave':
        return const Color(0xFFE3F2FD);
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getAttendanceBorderColor(String? attendance) {
    switch (attendance) {
      case 'Present':
        return const Color(0xFF4CAF50);
      case 'Absent':
        return const Color(0xFFF44336);
      case 'Half Day':
        return const Color(0xFF9C27B0);
      case 'Leave':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey.shade400;
    }
  }

  Color _getAttendanceTextColor(String? attendance) {
    switch (attendance) {
      case 'Present':
        return const Color(0xFF1B5E20);
      case 'Absent':
        return const Color(0xFFB71C1C);
      case 'Half Day':
        return const Color(0xFF4A148C);
      case 'Leave':
        return const Color(0xFF0D47A1);
      default:
        return Colors.grey.shade800;
    }
  }

  IconData _getAttendanceIcon(String? attendance) {
    switch (attendance) {
      case 'Present':
        return Icons.check_circle;
      case 'Absent':
        return Icons.cancel;
      case 'Half Day':
        return Icons.access_time;
      case 'Leave':
        return Icons.event_busy;
      default:
        return Icons.help_outline;
    }
  }

  Widget markedStudentDatatable(AttendanceProvider model) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: model.getMarkedStudentResponse!.lststud!.length,
      itemBuilder: (context, index) {
        final student = model.getMarkedStudentResponse!.lststud![index];
        final currentAttendance = model.returnFullValueOfAttendance(student.pRESENT.toString());
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getAttendanceColor(currentAttendance),
                _getAttendanceColor(currentAttendance).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getAttendanceBorderColor(currentAttendance).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getAttendanceBorderColor(currentAttendance).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getAttendanceBorderColor(currentAttendance).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getAttendanceIcon(currentAttendance),
                        color: _getAttendanceBorderColor(currentAttendance),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (student.sTUDNAME ?? "").toString().trim().toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Montserrat Regular",
                              color: _getAttendanceTextColor(currentAttendance),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.class_,
                                size: 14,
                                color: _getAttendanceTextColor(currentAttendance).withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${student.cLASSDESC ?? ""}-${student.sECTIONDESC ?? ""}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Montserrat Regular",
                                  color: _getAttendanceTextColor(currentAttendance).withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getAttendanceBorderColor(currentAttendance),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getAttendanceBorderColor(currentAttendance).withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: currentAttendance,
                        isDense: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: _getAttendanceBorderColor(currentAttendance),
                          size: 24,
                        ),
                        onChanged: (String? newValue) {
                          _animationController.forward().then((_) {
                            _animationController.reverse();
                          });
                          model.updateMarkedAttendanceStatus(newValue!, student);
                        },
                        items: <String>['Present', 'Absent', 'Half Day', 'Leave']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  _getAttendanceIcon(value),
                                  size: 18,
                                  color: _getAttendanceBorderColor(value),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getAttendanceTextColor(value),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget unmarkedStudentDataTable(AttendanceProvider model) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: model.studentResponse!.aDMSTUDREGISTRATION!.length,
      itemBuilder: (context, index) {
        final student = model.studentResponse!.aDMSTUDREGISTRATION![index];
        final currentAttendance = student.attendance;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getAttendanceColor(currentAttendance),
                _getAttendanceColor(currentAttendance).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getAttendanceBorderColor(currentAttendance).withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getAttendanceBorderColor(currentAttendance).withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _getAttendanceBorderColor(currentAttendance).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getAttendanceIcon(currentAttendance),
                        color: _getAttendanceBorderColor(currentAttendance),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (student.fIRSTNAME ?? "").toUpperCase(),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Montserrat Regular",
                              color: _getAttendanceTextColor(currentAttendance),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.class_,
                                size: 14,
                                color: _getAttendanceTextColor(currentAttendance).withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${student.cLASSDESC ?? ""}-${student.sECTIONDESC ?? ""}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Montserrat Regular",
                                  color: _getAttendanceTextColor(currentAttendance).withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getAttendanceBorderColor(currentAttendance),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _getAttendanceBorderColor(currentAttendance).withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: DropdownButton<String>(
                        value: currentAttendance,
                        isDense: true,
                        underline: const SizedBox(),
                        icon: Icon(
                          Icons.arrow_drop_down_rounded,
                          color: _getAttendanceBorderColor(currentAttendance),
                          size: 24,
                        ),
                        onChanged: (String? newValue) {
                          _animationController.forward().then((_) {
                            _animationController.reverse();
                          });
                          model.updateAttendanceStatus(newValue!, student);
                        },
                        items: <String>['Present', 'Absent', 'Half Day', 'Leave']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  _getAttendanceIcon(value),
                                  size: 18,
                                  color: _getAttendanceBorderColor(value),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  value,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _getAttendanceTextColor(value),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
