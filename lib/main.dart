import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flexischool/app_update.dart';
import 'package:flexischool/common/fcm_navigation_handler.dart';
import 'package:flexischool/common/remote_config_service.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/debug_fcm_notifications.dart';
import 'package:flexischool/firebase_options.dart';
import 'package:flexischool/notification_helper.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flexischool/providers/student/fee_provider.dart';
import 'package:flexischool/providers/student/payment_detail_provider.dart';
import 'package:flexischool/providers/student/student_dashboard_provider.dart';
import 'package:flexischool/providers/student/student_notification_provider.dart';
import 'package:flexischool/providers/teacher/attendance_provider.dart';
import 'package:flexischool/screens/loader.dart';
import 'package:flexischool/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/common/config.dart';
import 'common/auth_middleware.dart';
import 'providers/url_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  // Enable edge-to-edge mode for Android 15 compatibility
  // This uses only the brightness properties, avoiding deprecated color APIs
  // We only set brightness, not colors, to avoid deprecated APIs
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Set icon brightness for system bars
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      // Set status bar brightness (iOS)
      statusBarBrightness: Brightness.light,
      // Explicitly avoid setting deprecated color properties:
      // - statusBarColor (deprecated in Android 15)
      // - navigationBarColor (deprecated in Android 15)
      // - navigationBarDividerColor (deprecated in Android 15)
    ),
  );
  WebService.init();
  Constants.isSupportBadgeOrNot();
  FirebaseApp app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Initialized default app $app from Android resource');
  await PushNotificationsManager().init();
  // NotificationService is only for file downloads, not FCM notifications
  // await NotificationService.initializeNotification();

  // Initialize FCM debugging
  FCMNotificationDebugger.initialize();
  await FCMNotificationDebugger.printFCMSettings();
  FCMNotificationDebugger.printNotificationTypesSummary();

  // Print FCM navigation mapping for debugging
  FCMNavigationHandler.printNavigationMapping();

  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  setupLocator();
  debugPrint('fcm token ===> ${PushNotificationsManager().fcmToken}');
  await RemoteConfigService().initialize();
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UrlProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => LoaderProvider()),
        ChangeNotifierProvider(create: (_) => StudentDashboardProvider()),
        ChangeNotifierProvider(create: (_) => StudentNotificationProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => FeeProvider()),
        ChangeNotifierProvider(create: (_) => PaymentDetailProvider()),
      ],
      child: MaterialApp(
        title: Constants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            fontFamily: GoogleFonts.lato().fontFamily,
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(color: Colors.blue)),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'), // English
          // Add more locales as needed
        ],
        home: const LoaderRoute(),
        navigatorKey: AuthMiddleware.navigatorKey,
        //  navigatorObservers: [authMiddleware]
      ),
    );
  }
}
