import 'dart:convert';
import 'dart:developer';

import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/screens/assignmentform.dart';
import 'package:flexischool/screens/student/student_circular.dart';
import 'package:flexischool/screens/teacher/attendance_screen.dart';
import 'package:flexischool/screens/teacher/teacher_circular_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/login_provider.dart';

class DropdownSession {
  final int SESSION_ID;
  final String START_DATE;
  final String END_DATE;
  final String? ACTIVE;

  DropdownSession(
      {required this.SESSION_ID, required this.START_DATE, required this.END_DATE, required this.ACTIVE});
}

class MyDropdownWidget extends StatefulWidget {
  const MyDropdownWidget({super.key});

  @override
  _MyDropdownWidgetState createState() => _MyDropdownWidgetState();
}

class _MyDropdownWidgetState extends State<MyDropdownWidget> {
  List sData = [];
  var selectedDropdownItem;
  var activeVal;

  Future<void> sessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseUrl = prefs.getString('global_school_url');
    debugPrint('schoolBaseUrl-----> $schoolBaseUrl ');
    var requestedData = {"SCHOOL_ID": "1"};
    var body = json.encode(requestedData);
    final response = await http.post(
      Uri.parse('${schoolBaseUrl!}SessionSearch/SessionSearch'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final data1 = json.decode(response.body);
      log("session data ===> $data1");
      final data = data1['SessionDD'];

      setState(() {
        sData = data;
      });
      await Future.delayed(const Duration(milliseconds: 1000));
    } else {}
  }

  @override
  void initState() {
    super.initState();
    sessionData();
  }

  @override
  Widget build(BuildContext context) {
    final activeItem = sData.where((item) => item['ACTIVE'] == 'Y').toList();
    if (activeItem.isNotEmpty) {
      activeVal = (activeItem.first)['SESSION_ID'];
      selectedDropdownItem ??= activeVal;
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(right: 20.0),
      child: DropdownButton(
          items: sData.map((item) {
            var itemDate = (item['START_DATE']).substring(0, 4) + '-' + (item['END_DATE']).substring(0, 4);
            //print('inside');
            //print(item['SESSION_ID']);
            return DropdownMenuItem(
              value: item['SESSION_ID'],
              child: Text(itemDate),
            );
          }).toList(),
          value: selectedDropdownItem,
          isExpanded: true,
          elevation: 16,
          alignment: Alignment.center,
          onChanged: (newValue) {
            setState(() {
              selectedDropdownItem = newValue!;
              Constants.sessionId = selectedDropdownItem;
            });
            debugPrint('session id ---> ${Constants.sessionId}');
          }),
    );
  }
}

class CustomUserAccountsDrawerHeader extends StatelessWidget {
  const CustomUserAccountsDrawerHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginProvider loginStore = Provider.of<LoginProvider>(context);
    return DrawerHeader(
      decoration: const BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(loginStore.photo),
                radius: 30,
              ),
              const SizedBox(width: 10),
              Text(
                '${loginStore.userName}',
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Montserrat Regular",
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),
          Text(
            'Employee Code : ${loginStore.employeeCode}',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.black,
            ),
          ),

          //SizedBox(height: 5),
          Text(
            'Department : ${loginStore.depName}',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.black,
            ),
          ),
          Text(
            'Designation : ${loginStore.designation}',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.black,
            ),
          ),
          //SizedBox(height: 5),
          Text(
            'Session : ${loginStore.session}',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void logout(BuildContext context) {
    final LoginProvider loginStore = Provider.of<LoginProvider>(context, listen: false);
    loginStore.userLogout();

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    sessionData();
    super.initState();
  }

  Future<void> sessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseUrl = prefs.getString('global_school_url');
    Api.baseUrl = schoolBaseUrl ?? "";
    debugPrint('setup base url ----> ${Api.baseUrl}');
    var requestedData = {"SCHOOL_ID": "1"};
    var body = json.encode(requestedData);
    final response = await http.post(
      Uri.parse('${schoolBaseUrl!}SessionSearch/SessionSearch'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final data1 = json.decode(response.body);
      log("session data ===> $data1");
      final data = data1['SessionDD'];
      final activeItem = data.where((item) => item['ACTIVE'] == 'Y').toList();
      if (activeItem.isNotEmpty) {
        Constants.sessionId = (activeItem.first)['SESSION_ID'];
        setState(() {});
      }
      debugPrint('dashboard init session id ${Constants.sessionId}');
      await Future.delayed(const Duration(milliseconds: 1000));
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const CustomUserAccountsDrawerHeader(),
            ListTile(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              title: const MyDropdownWidget(),
              leading: const Icon(Icons.access_time),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              onTap: () {},
            ),
            ListTile(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              title: const Text('Profile'),
              leading: const Icon(Icons.notifications_paused_rounded),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              onTap: () {},
            ),
            ListTile(
              //dense: true,
              //contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              title: const Text('Change Session'),
              leading: const Icon(Icons.lock_reset),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              onTap: () {},
            ),
            ListTile(
              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
              title: const Text('Change Password'),
              leading: const Icon(Icons.lock),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              onTap: () {},
            ),
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
      body: const DashboardWidget(),
    );
  }
}

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

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
                              'Session :  ${loginStore.session}',
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
              return GestureDetector(
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.network(iconPath! + dashboards[index].IMAGE, height: 80),
                      const SizedBox(height: 10.0),
                      Text(
                        dashboards[index].MENUNAME,
                        style: cardTextStyle,
                      )
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
                    }
                  } else if (dashboards[index].MENUNAME.toString().toLowerCase() == 'assignments') {
                    if (type == 'T') {
                      if (context.mounted) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AssignmentForm(
                                      employeeId: employeeId,
                                    )));
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
