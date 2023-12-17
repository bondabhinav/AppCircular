import 'package:flexischool/common/webService.dart';
import 'package:flexischool/providers/teacher/teacher_dashboard_provider.dart';
import 'package:flexischool/screens/student/academic_calender_screen.dart';
import 'package:flexischool/screens/student/student_assignment_screen.dart';
import 'package:flexischool/screens/student/student_attendance_graph_screen.dart';
import 'package:flexischool/screens/student/student_circular.dart';
import 'package:flexischool/screens/teacher/attendance_screen.dart';
import 'package:flexischool/screens/teacher/teacher_assignment_list_screen.dart';
import 'package:flexischool/screens/teacher/teacher_circular_list_screen.dart';
import 'package:flexischool/screens/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/login_provider.dart';

class MyDropdownWidget extends StatefulWidget {
  final TeacherDashboardProvider model;

  const MyDropdownWidget({super.key, required this.model});

  @override
  _MyDropdownWidgetState createState() => _MyDropdownWidgetState();
}

class _MyDropdownWidgetState extends State<MyDropdownWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 20.0),
      child: DropdownButton(
          items: widget.model.teacherSessionResponse?.sessionDD?.map((item) {
            var itemDate = '${(item.sTARTDATE)!.substring(0, 4)}-${(item.eNDDATE)!.substring(0, 4)}';
            return DropdownMenuItem(
              value: item.sESSIONID,
              child: Text(itemDate),
            );
          }).toList(),
          value: widget.model.selectedTeacherSessionDropDownValue,
          isExpanded: true,
          elevation: 16,
          alignment: Alignment.center,
          onChanged: (newValue) {
            widget.model.updateSession(newValue);
          }),
    );
  }
}

class CustomUserAccountsDrawerHeader extends StatelessWidget {
  final TeacherDashboardProvider model;

  const CustomUserAccountsDrawerHeader({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    final LoginProvider loginStore = Provider.of<LoginProvider>(context);
    return Container(
      padding: const EdgeInsets.only(top: 30, left: 20, bottom: 20),
      decoration: const BoxDecoration(color: Colors.blue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            CircleAvatar(backgroundImage: NetworkImage(loginStore.photo), radius: 30),
            const SizedBox(width: 10),
            Text('${loginStore.userName}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Montserrat Regular",
                    color: Colors.white))
          ]),
          const SizedBox(height: 5),
          Text('Employee Code : ${loginStore.employeeCode}',
              style: const TextStyle(fontSize: 13, fontFamily: "Montserrat Regular", color: Colors.black)),
          Text('Department : ${loginStore.depName}',
              style: const TextStyle(fontSize: 13, fontFamily: "Montserrat Regular", color: Colors.black)),
          Text('Designation : ${loginStore.designation}',
              style: const TextStyle(fontSize: 13, fontFamily: "Montserrat Regular", color: Colors.black)),
          Text('Session : ${model.sessionYear}',
              style: const TextStyle(fontSize: 13, fontFamily: "Montserrat Regular", color: Colors.black)),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void logout(BuildContext context) {
    final LoginProvider loginStore = Provider.of<LoginProvider>(context, listen: false);
    loginStore.userLogout();

    Navigator.pushReplacementNamed(context, '/home');
  }

  TeacherDashboardProvider? teacherDashboardProvider;

  @override
  void initState() {
    teacherDashboardProvider = TeacherDashboardProvider();
    teacherDashboardProvider?.getSessionData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => teacherDashboardProvider,
        builder: (context, child) {
          return Consumer<TeacherDashboardProvider>(builder: (context, model, _) {
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(title: const Text('Dashboard', style: TextStyle(color: Colors.white))),
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    CustomUserAccountsDrawerHeader(model: model),
                    model.teacherSessionResponse == null
                        ? const SizedBox()
                        : ListTile(
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            title: MyDropdownWidget(model: model),
                            leading: const Icon(Icons.access_time),
                            minLeadingWidth: 10,
                            horizontalTitleGap: 10,
                            onTap: () {}),
                    // ListTile(
                    //   visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                    //   title: const Text('Profile'),
                    //   leading: const Icon(Icons.notifications_paused_rounded),
                    //   minLeadingWidth: 10,
                    //   horizontalTitleGap: 10,
                    //   onTap: () {},
                    // ),
                    // ListTile(
                    //   //dense: true,
                    //   //contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                    //   visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                    //   title: const Text('Change Session'),
                    //   leading: const Icon(Icons.lock_reset),
                    //   minLeadingWidth: 10,
                    //   horizontalTitleGap: 10,
                    //   onTap: () {},
                    // ),

                    ListTile(
                        visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                        title: const Text('Privacy Policy'),
                        leading: const Icon(Icons.lock),
                        minLeadingWidth: 10,
                        horizontalTitleGap: 10,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const WebViewScreen(url: 'https://privacy.sapinfotek.com/',title:'Privacy Policy')));
                        }),

                    // ListTile(
                    //   visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                    //   title: const Text('Change Password'),
                    //   leading: const Icon(Icons.lock),
                    //   minLeadingWidth: 10,
                    //   horizontalTitleGap: 10,
                    //   onTap: () {},
                    // ),
                    ListTile(
                      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                      title: const Text('Logout'),
                      leading: const Icon(Icons.logout),
                      minLeadingWidth: 10,
                      horizontalTitleGap: 10,
                      onTap: () {
                        logout(context);
                      },
                    ),
                  ],
                ),
              ),
              body: DashboardWidget(model: model),
            );
          });
        });
  }
}

class DashboardWidget extends StatefulWidget {
  final TeacherDashboardProvider model;

  const DashboardWidget({super.key, required this.model});

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final LoginProvider loginStore = Provider.of<LoginProvider>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: size.height * .3,
            decoration: const BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.topCenter, image: AssetImage('assets/images/top_header_new.png')),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Container(
                    //height: 64,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 42,
                          backgroundImage: NetworkImage(loginStore.photo),
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              loginStore.userName,
                              style: const TextStyle(
                                  fontFamily: "Montserrat Medium", color: Colors.white, fontSize: 18),
                            ),
                            const SizedBox(height: 10.0),
                            Text(
                              'Employee Code : ${loginStore.employeeCode}',
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              ),
                            ),
                            //SizedBox(height: 10.0),
                            Text(
                              'Department : ${loginStore.depName}',
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Designation : ${loginStore.designation}',
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              ),
                            ),
                            //SizedBox(height: 10.0),
                            Text(
                              'Session : ${widget.model.sessionYear}',
                              style: const TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List>(
                      future: WebService.fetchDashboard(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('Something went wrong please try again!'),
                          );
                        } else if (snapshot.hasData) {
                          return DashBoardList(
                              dashboards: snapshot.requireData, employeeId: loginStore.employeeId);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> dashboardIcon() async {
  final prefs = await SharedPreferences.getInstance();
  final icon = prefs.getString('global_school_logo');
  return icon!;
}

class DashBoardList extends StatelessWidget {
  final List dashboards;
  final int employeeId;

  final iconImage = [
    'assets/images/list.png',
    'assets/images/comments.png',
    'assets/images/online-learning.png',
    'assets/images/immigration.png',
    'assets/images/exam.png',
    'assets/images/live-chat.png'
  ];

  DashBoardList({super.key, required this.dashboards, required this.employeeId});

  @override
  Widget build(BuildContext context) {
    var cardTextStyle = const TextStyle(
        fontFamily: "Montserrat Regular",
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(63, 63, 63, 1));
    return FutureBuilder<String>(
      future: dashboardIcon(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String? iconPath = snapshot.data;
          return GridView.builder(
            primary: false,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            padding: const EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: dashboards.length,
            itemBuilder: (context, index) {
              return InkWell(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(iconPath! + dashboards[index].IMAGE, height: 80),
                      const SizedBox(height: 10.0),
                      Text(dashboards[index].MENUNAME, style: cardTextStyle)
                    ],
                  ),
                ),
                onTap: () async {
                  final type = await WebService.getLoginType();
                  if (dashboards[index].MENUNAME.toString().toLowerCase() == 'circulars') {
                    if (type == 'S') {
                      if (context.mounted) {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const StudentCircularScreen()));
                      }
                    } else {
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeacherCircularListScreen(
                                      employeeId: employeeId,
                                    )));
                      }
                    }
                  } else if (dashboards[index].MENUNAME.toString().toLowerCase() == 'attendance') {
                    if (type == 'T') {
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AttendanceScreen(
                                      employeeId: employeeId,
                                    )));
                      }
                    } else {
                      if (context.mounted) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const StudentAttendanceGraphScreen()));
                      }
                    }
                  } else if (dashboards[index].MENUNAME.toString().toLowerCase() == 'assignments') {
                    if (type == 'T') {
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TeacherAssignmentListScreen(
                                      employeeId: employeeId,
                                    )));
                      }
                    } else if (type == 'S') {
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => StudentAssignmentCalenderWithList(
                                      employeeId: employeeId,
                                    )));
                      }
                    }
                  } else if (dashboards[index].MENUNAME.toString().toLowerCase() == 'academic') {
                    if (type == 'S') {
                      if (context.mounted) {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const AcademicCalenderScreen()));
                      }
                    }
                  }
                },
              );
            },
          );
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
