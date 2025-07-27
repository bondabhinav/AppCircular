import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexischool/common/constants.dart';
import 'package:flexischool/common/fcm_pending_navigation.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/models/dashboard_model.dart';
import 'package:flexischool/models/student/student_detail_response.dart';
import 'package:flexischool/notification_count_handler.dart';
import 'package:flexischool/notification_helper.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/screens/change_password_screen.dart';
import 'package:flexischool/screens/dashboard.dart';
import 'package:flexischool/screens/student/fee_screen.dart';
import 'package:flexischool/screens/student/student_notification_screen.dart';
import 'package:flexischool/screens/webview_screen.dart';
import 'package:flutter/material.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> with WidgetsBindingObserver {
  late StudentDashboardProvider studentDashboardProvider;
  final loaderProvider = getIt<LoaderProvider>();

  @override
  void initState() {
    studentDashboardProvider = Provider.of<StudentDashboardProvider>(context, listen: false);
    studentDashboardProvider.getStudentImageUrl();
    WidgetsBinding.instance.addObserver(this);
    // Initial message handling is now done globally in PushNotificationsManager
    // FirebaseMessaging.instance.getInitialMessage().then((value) {
    //   if (value != null) {
    //     PushNotificationsManager.clickHandle(value.data.toString(), fromBackgroundOrTerminate: true);
    //   }
    // });
    if (WebService.studentLoginData != null) {
      Constants.sessionId = WebService.studentLoginData!.table1!.first.sESSIONID!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        studentDashboardProvider.getNotificationCount();
        studentDashboardProvider.assignSessionValue();
        studentDashboardProvider.getSessionData();
        studentDashboardProvider.fetchStudentDetail();
        studentDashboardProvider.fetchDashboard();
        
        // Mark app startup as complete for FCM navigation
        Future.delayed(const Duration(milliseconds: 1500), () {
          FCMPendingNavigation.markAppStartupComplete();
        });
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
        await studentDashboardProvider.getNotificationCount();
        setBadgeCount();
        // Dashboard data is cached, so no need to fetch again
      } else if (state == AppLifecycleState.inactive) {
        setBadgeCount();
      } else if (state == AppLifecycleState.paused) {
        setBadgeCount();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void setBadgeCount() {
    try {
      AppBadgePlus.updateBadge(int.parse(studentDashboardProvider!
          .notificationCountResponse!.notificationCount!.first.nOTIFICATIONCOUNT!
          .toString()));
    } catch (e) {
      debugPrint('error in badge count $e');
    }
  }

  void _showFloatingNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enable Floating Notifications'),
          content: const Text(
            'To receive floating notifications and sound alerts, you need to enable "Display over other apps" permission.\n\n'
            'This will allow important notifications to appear on top of other apps, even when your phone is locked.\n\n'
            'Would you like to enable this feature?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestFloatingNotificationPermission(context);
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  void _requestFloatingNotificationPermission(BuildContext context) async {
    try {
      // Check if permission is already granted
      if (await Permission.systemAlertWindow.isGranted) {
        _showPermissionStatusDialog(context, true);
        return;
      }

      // Request the permission
      final status = await Permission.systemAlertWindow.request();
      
      if (status.isGranted) {
        _showPermissionStatusDialog(context, true);
      } else if (status.isDenied) {
        _showPermissionStatusDialog(context, false);
      } else if (status.isPermanentlyDenied) {
        _showSettingsDialog(context);
      }
    } catch (e) {
      debugPrint('Error requesting floating notification permission: $e');
      _showPermissionStatusDialog(context, false);
    }
  }

  void _showPermissionStatusDialog(BuildContext context, bool isGranted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isGranted ? 'Permission Granted!' : 'Permission Denied'),
          content: Text(
            isGranted
                ? 'Floating notifications are now enabled. You will receive notifications on top of other apps.'
                : 'Floating notifications could not be enabled. You can try again later from Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'To enable floating notifications, please go to Settings and manually enable "Display over other apps" permission for Flexi School.\n\n'
            'Settings > Apps > Flexi School > Display over other apps',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
        stream: NotificationCountHandler.notificationCount.stream,
        builder: (context, snapshot) {
          return Consumer<StudentDashboardProvider>(builder: (context, model, _) {
            return Scaffold(
                appBar:
                    AppBar(title: const Text('Dashboard', style: TextStyle(color: Colors.white)), actions: [
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const StudentNotificationScreen())).then((value) {
                              model.getNotificationCount();
                            });
                          },
                          iconSize: 25),
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
                                          url: Constants.privacyPolicyUrl, title: 'Privacy Policy')));
                            }),
                        ListTile(
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            title: const Text('Change Password'),
                            leading: const Icon(Icons.lock),
                            minLeadingWidth: 10,
                            horizontalTitleGap: 10,
                            onTap: () => Navigator.push(context,
                                MaterialPageRoute(builder: (context) => const ChangePasswordScreen()))),
                        ListTile(
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            title: const Text('Floating Notifications'),
                            leading: const Icon(Icons.notifications_active),
                            minLeadingWidth: 10,
                            horizontalTitleGap: 10,
                            onTap: () => _showFloatingNotificationDialog(context)),
                        ListTile(
                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                            title: const Text('Logout'),
                            leading: const Icon(Icons.logout),
                            minLeadingWidth: 10,
                            horizontalTitleGap: 10,
                            onTap: () => logout(context, model))
                      ])),
                body: (model.studentDetailResponse == null)
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(children: <Widget>[
                        Container(
                            height: MediaQuery.sizeOf(context).height * .3,
                            decoration: const BoxDecoration(
                                image: DecorationImage(
                                    alignment: Alignment.topCenter,
                                    image: AssetImage('assets/images/top_header_new.png')))),
                        SafeArea(
                            child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(children: <Widget>[
                                  Container(
                                      margin: const EdgeInsets.only(bottom: 20),
                                      child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            CircleAvatar(
                                                radius: 42,
                                                backgroundImage: WebService
                                                            .studentLoginData?.table1?.first.sTUDPHOTO ==
                                                        null || WebService.studentLoginData?.table1?.first.sTUDPHOTO?.isEmpty == true
                                                    ? null
                                                    : NetworkImage(
                                                        '${model.imageUrl}student/${WebService.studentLoginData?.table1?.first.sTUDPHOTO}'),
                                                child: WebService.studentLoginData?.table1?.first.sTUDPHOTO ==
                                                        null || WebService.studentLoginData?.table1?.first.sTUDPHOTO?.isEmpty == true
                                                    ? const Icon(Icons.account_circle,
                                                        color: Colors.blue, size: 84)
                                                    : null),
                                            const SizedBox(width: 16),
                                            Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                      "${model.studentDetailResponse?.getstudentData?.first.fIRSTNAME} ${model.studentDetailResponse?.getstudentData?.first.lASTNAME}",
                                                      style: const TextStyle(
                                                          fontFamily: "Montserrat Medium",
                                                          color: Colors.white,
                                                          fontSize: 18)),
                                                  const SizedBox(height: 10.0),
                                                  Text(
                                                      'Admission no. : ${model.studentDetailResponse?.getstudentData?.first.aDMNO}',
                                                      style: const TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily: "Montserrat Regular",
                                                          color: Colors.black)),
                                                  //SizedBox(height: 10.0),
                                                  Text(
                                                      'Class : ${model.studentDetailResponse?.getstudentData?.first.cLASSDESC}',
                                                      style: const TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily: "Montserrat Regular",
                                                          color: Colors.black)),
                                                  Text(
                                                      'Section : ${model.studentDetailResponse?.getstudentData?.first.sECTIONDESC}',
                                                      style: const TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily: "Montserrat Regular",
                                                          color: Colors.black)),
                                                  //SizedBox(height: 10.0),
                                                  Text('Session :  ${model.sessionYear}',
                                                      style: const TextStyle(
                                                          fontSize: 14.0,
                                                          fontFamily: "Montserrat Regular",
                                                          color: Colors.black))
                                                ])
                                          ])),
                                  Expanded(
                                      child: Consumer<StudentDashboardProvider>(
                                          builder: (context, dashboardModel, _) {
                                            if (dashboardModel.isDashboardLoading) {
                                              return const Center(child: CircularProgressIndicator());
                                            } else if (dashboardModel.dashboardError != null) {
                                              return Center(child: Text('Error: ${dashboardModel.dashboardError}'));
                                            } else if (dashboardModel.dashboardData != null && dashboardModel.dashboardData!.isNotEmpty) {
                                              return DashBoardList(dashboards: dashboardModel.dashboardData!, employeeId: 0);
                                            } else {
                                              return const Center(
                                                  child: Text('No dashboard items available'));
                                            }
                                          }))
                                ])))
                      ]));
          });
        });
  }

  Future<void> logout(BuildContext context, StudentDashboardProvider model) async {
    String? appDeviceId = await WebService.getAppDeviceId();
    if (mounted) {
      if (appDeviceId != null) {
        debugPrint('app Device Id $appDeviceId');
        if (context.mounted) {
          model.logoutApi(context, appDeviceId);
        }
      } else {
        debugPrint('else logout');
        if (context.mounted) {
          final LoginProvider loginStore = Provider.of<LoginProvider>(context, listen: false);
          loginStore.userLogout();
        }
        AppBadgePlus.updateBadge(0);
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
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
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: WebService.studentLoginData?.table1?.first.sTUDPHOTO == null ||
                      WebService.studentLoginData?.table1?.first.sTUDPHOTO?.isEmpty == true
                      ? null
                      : NetworkImage(
                          '${model.imageUrl}student/${WebService.studentLoginData?.table1?.first.sTUDPHOTO}',
                        ),
                  child: WebService.studentLoginData?.table1?.first.sTUDPHOTO == null ||
                      WebService.studentLoginData?.table1?.first.sTUDPHOTO?.isEmpty == true
                      ? const Icon(Icons.account_circle, color: Colors.blue, size: 60)
                      : null,
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
      ),
    );
  }
}
