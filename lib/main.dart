import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flexischool/app_update.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/firebase_options.dart';
import 'package:flexischool/notification_helper.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/providers/student/student_notification_provider.dart';
import 'package:flexischool/providers/teacher/attendance_provider.dart';
import 'package:flexischool/utils/locator.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/common/config.dart';
import 'common/auth_middleware.dart';
import 'providers/url_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  WebService.init();
  Constants.isSupportBadgeOrNot();
  FirebaseApp app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Initialized default app $app from Android resource');
  await PushNotificationsManager().init();
  await NotificationService.initializeNotification();
  setupLocator();
  debugPrint('fcm token ===> ${PushNotificationsManager().fcmToken}');
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    //checkForUpdate(context);
  }

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final newVersion = NewVersionPlus(
          iOSId: Constants.applicationId,
          androidId: Constants.applicationId,
          androidPlayStoreCountry: "es_ES");
      final status = await newVersion.getVersionStatus();
      if (status != null) {
        debugPrint(status.releaseNotes);
        debugPrint(status.appStoreLink);
        debugPrint(status.localVersion);
        debugPrint(status.storeVersion);
        debugPrint(status.canUpdate.toString());
        if (context.mounted) {
          newVersion.showUpdateDialog(
              context: context,
              versionStatus: status,
              dialogTitle: 'Custom Title',
              dialogText: 'Custom Text',
              launchModeVersion: LaunchModeVersion.external,
              allowDismissal: true,
              dismissAction: () {},
              dismissButtonText: '');
        }
      }
    } on Exception catch (e) {
      debugPrint('Error checking for update: $e');
    }
    // try {
    //   print('enter in checkForUpdate');
    //   AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
    //   if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
    //     print('enter in updateAvailable');
    //     await InAppUpdate.performImmediateUpdate();
    //   }else{
    //     print('enter in update not Available');
    //   }
    // } catch (e) {
    //   debugPrint('Error checking for update: $e');
    // }
  }

  @override
  Widget build(BuildContext context) {
    final AuthMiddleware authMiddleware = AuthMiddleware();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UrlProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => LoaderProvider()),
        ChangeNotifierProvider(create: (_) => StudentDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StudentNotificationProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: MaterialApp(
          title: Constants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              fontFamily: GoogleFonts.lato().fontFamily,
              primarySwatch: Colors.blue,
              appBarTheme: const AppBarTheme(color: Colors.blue)),
          routes: routes,
          initialRoute: "/",
          navigatorKey: AuthMiddleware.navigatorKey,
        //  navigatorObservers: [authMiddleware]
      ),
    );
  }
}
