import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/student/student_detail_response.dart';
import 'package:flexischool/notification_count_handler.dart';
import 'package:flexischool/notification_helper.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/screens/dashboard.dart';
import 'package:flexischool/screens/student/student_notification_screen.dart';
import 'package:flexischool/screens/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:provider/provider.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> with WidgetsBindingObserver {
  StudentDashboardProvider? studentDashboardProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    studentDashboardProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
    studentDashboardProvider?.getStudentImageUrl();
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      if (value != null) {
        PushNotificationsManager.clickHandle(value.data.toString(), fromBackgroundOrTerminate: true);
      }
    });
    if (WebService.studentLoginData != null) {
      Constants.sessionId = WebService.studentLoginData!.table1!.first.sESSIONID!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        studentDashboardProvider?.getNotificationCount();
        studentDashboardProvider?.assignSessionValue();
        studentDashboardProvider?.getSessionData();
        studentDashboardProvider?.fetchStudentDetail();
      });
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    debugPrint('didChangeDependencies ------------ ');
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant StudentDashboardScreen oldWidget) {
    debugPrint('didUpdateWidget ------------ ');
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint('didChangeAppLifecycleState ------------ ${state.name}');
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (state == AppLifecycleState.resumed) {
        debugPrint('didChangeAppLifecycleState resume ------------ ${state.name}');
        await studentDashboardProvider?.getNotificationCount();
        FlutterAppBadger.updateBadgeCount(int.parse(studentDashboardProvider!
            .notificationCountResponse!.notificationCount!.first.nOTIFICATIONCOUNT!
            .toString()));
      } else if (state == AppLifecycleState.inactive) {
        FlutterAppBadger.updateBadgeCount(int.parse(studentDashboardProvider!
            .notificationCountResponse!.notificationCount!.first.nOTIFICATIONCOUNT!
            .toString()));
      } else if (state == AppLifecycleState.paused) {
        FlutterAppBadger.updateBadgeCount(int.parse(studentDashboardProvider!
            .notificationCountResponse!.notificationCount!.first.nOTIFICATIONCOUNT!
            .toString()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: NotificationCountHandler.notificationCount.stream,
        builder: (context, snapshot) {
          return Consumer<StudentDashboardProvider>(builder: (context, model, _) {
            return Scaffold(
              appBar: AppBar(title: const Text('Dashboard', style: TextStyle(color: Colors.white)), actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      color: Colors.white,
                      onPressed: () {
                        PushNotificationsManager.localNotifications.cancelAll();
                        // if (model.notificationCountResponse != null &&
                        //     model.notificationCountResponse!.notificationCount!.first.nOTIFICATIONCOUNT! >
                        //         0) {
                        Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const StudentNotificationScreen()))
                            .then((value) {
                          model.getNotificationCount();
                        });
                        // }
                      },
                      iconSize: 25,
                    ),
                    if (snapshot.data != 0)
                      Positioned(
                        right: 5,
                        top: 5,
                        child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: (snapshot.hasData)
                                ? Text(snapshot.data.toString(),
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                                : const SizedBox.shrink()),
                      ),
                  ],
                ),
              ]),
              drawer: (model.studentDetailResponse == null)
                  ? const SizedBox.shrink()
                  : Drawer(
                      child: ListView(padding: EdgeInsets.zero, children: [
                      studentHeader(model.studentDetailResponse!, model),
                      (model.sessionListResponse == null)
                          ? const SizedBox()
                          : ListTile(
                              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                              title: sessionDropDown(model),
                              leading: const Icon(Icons.access_time),
                              minLeadingWidth: 10,
                              horizontalTitleGap: 10,
                              onTap: () {},
                            ),
                      // ListTile(
                      //   visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                      //   title: const Text('Profile'),
                      //   leading: const Icon(Icons.notifications_paused_rounded),
                      //   minLeadingWidth: 10,
                      //   horizontalTitleGap: 10,
                      //   onTap: () {},
                      // ),
                      // ListTile(
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
                                    builder: (context) => const WebViewScreen(
                                        url: 'https://privacy.sapinfotek.com/', title: 'Privacy Policy')));
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
                          logout(context, model);
                        },
                      ),
                    ])),
              body: (model.studentDetailResponse == null)
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.sizeOf(context).height * .3,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                                alignment: Alignment.topCenter,
                                image: AssetImage('assets/images/top_header_new.png')),
                          ),
                        ),
                        SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 42,
                                        backgroundImage: WebService
                                                    .studentLoginData?.table1?.first.sTUDPHOTO ==
                                                null
                                            ? null
                                            : NetworkImage(
                                                '${model.imageUrl}student/${WebService.studentLoginData?.table1?.first.sTUDPHOTO ?? ""}'),
                                        child: WebService.studentLoginData?.table1?.first.sTUDPHOTO == null
                                            ? const Icon(
                                                Icons.account_circle,
                                                color: Colors.blue,
                                                size: 84, // Adjust the size as needed
                                              )
                                            : null,
                                      ),
                                      const SizedBox(
                                        width: 16,
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "${model.studentDetailResponse?.getstudentData?.first.fIRSTNAME} ${model.studentDetailResponse?.getstudentData?.first.lASTNAME}",
                                            style: const TextStyle(
                                                fontFamily: "Montserrat Medium",
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          const SizedBox(height: 10.0),
                                          Text(
                                            'Admission no. : ${model.studentDetailResponse?.getstudentData?.first.aDMNO}',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ),
                                          ),
                                          //SizedBox(height: 10.0),
                                          Text(
                                            'Class : ${model.studentDetailResponse?.getstudentData?.first.cLASSDESC}',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            'Section : ${model.studentDetailResponse?.getstudentData?.first.sECTIONDESC}',
                                            style: const TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: "Montserrat Regular",
                                              color: Colors.black,
                                            ),
                                          ),
                                          //SizedBox(height: 10.0),
                                          Text(
                                            'Session :  ${model.sessionYear}',
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
                                        return DashBoardList(dashboards: snapshot.requireData, employeeId: 0);
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
          });
        });
  }

  Future<void> logout(BuildContext context, StudentDashboardProvider model) async {
    String? appDeviceId = await WebService.getFcmData();
    if (mounted) {
      if (appDeviceId != null) {
        debugPrint('app Device Id $appDeviceId');
        model.logoutApi(context, appDeviceId);
      } else {
        debugPrint('else logout');
        final LoginProvider loginStore = Provider.of<LoginProvider>(context, listen: false);
        loginStore.userLogout();
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  Widget sessionDropDown(StudentDashboardProvider model) {
    return (model.sessionListResponse == null || model.sessionListResponse?.table1 == null)
        ? const SizedBox.shrink()
        : Container(
            width: double.infinity,
            margin: const EdgeInsets.only(right: 20.0),
            child: DropdownButton(
                items: model.sessionListResponse?.table1!.map((item) {
                  var itemDate = '${(item.sTARTDATE)?.substring(0, 4)}-${item.eNDDATE!.substring(0, 4)}';
                  return DropdownMenuItem(
                    value: item.sESSIONID,
                    child: Text(itemDate),
                  );
                }).toList(),
                value: model.selectedSessionDropDownValue,
                isExpanded: true,
                elevation: 16,
                alignment: Alignment.center,
                onChanged: (dynamic newValue) {
                  model.updateSession(newValue);
                  debugPrint('session id ---> ${Constants.sessionId}');
                }),
          );
  }

  Widget studentHeader(StudentDetailResponse studentDetailResponse, StudentDashboardProvider model) {
    final data = studentDetailResponse.getstudentData?.first;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(
                  '${model.imageUrl}student/${WebService.studentLoginData?.table1?.first.sTUDPHOTO ?? ""}',
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${data!.fIRSTNAME} ${data.lASTNAME}',
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
            'Adm No. : ${data.aDMNO}',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.white,
            ),
          ),
          Text(
            'Class : ${data.cLASSDESC}',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.white,
            ),
          ),
          Text(
            'Section : ${data.sECTIONDESC}',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.white,
            ),
          ),
          Text(
            'Session : ${model.sessionYear}',
            style: const TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
