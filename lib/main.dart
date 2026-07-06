import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flexischool/app_update.dart';
import 'package:flexischool/common/fcm_navigation_handler.dart';
// import 'package:flexischool/common/ota_update_service.dart';
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
import 'package:flexischool/utils/notification_service.dart';
import 'package:flexischool/utils/locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // Modern edge-to-edge approach for Android 15 compatibility
  // Only set brightness properties - color is now handled by native enableEdgeToEdge()
  // This avoids deprecated statusBarColor, navigationBarColor, navigationBarDividerColor
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Set icon brightness for system bars (Android)
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      // Set status bar brightness (iOS)
      statusBarBrightness: Brightness.light,
    ),
  );
  await WebService.init();
  Constants.isSupportBadgeOrNot();
  setupLocator();
  runApp(const MyApp());

  unawaited(_initializeStartupServices());
}

Future<void> _initializeStartupServices() async {
  try {
    final app = await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(const Duration(seconds: 10));
    debugPrint('Initialized default app $app from Android resource');
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
    return;
  }

  await _runStartupTask(
    'push notifications',
    () => PushNotificationsManager().init(),
  );
  // Register local notification callbacks for downloaded files.
  await _runStartupTask(
    'file download notifications',
    NotificationService.initializeForFileDownloads,
  );

  try {
    // Initialize FCM debugging
    FCMNotificationDebugger.initialize();
    await FCMNotificationDebugger.printFCMSettings().timeout(
      const Duration(seconds: 5),
    );
    FCMNotificationDebugger.printNotificationTypesSummary();

    // Print FCM navigation mapping for debugging
    FCMNavigationHandler.printNavigationMapping();
  } catch (e) {
    debugPrint('FCM diagnostics skipped: $e');
  }

  debugPrint('fcm token ===> ${PushNotificationsManager().fcmToken}');
  await _runStartupTask(
    'remote config',
    () => RemoteConfigService().initialize(),
    timeout: const Duration(seconds: 6),
  );
}

Future<void> _runStartupTask(
  String name,
  Future<void> Function() task, {
  Duration timeout = const Duration(seconds: 8),
}) async {
  try {
    await task().timeout(timeout);
  } catch (e) {
    debugPrint('$name initialization skipped: $e');
  }
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
    // OTA update entry point disabled.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _checkOtaUpdate();
    // });
  }

  // /// Check for OTA update
  // Future<void> _checkOtaUpdate() async {
  //   // Wait a bit for app to fully initialize
  //   await Future.delayed(const Duration(seconds: 2));
  //
  //   if (!mounted) return;
  //
  //   try {
  //     await OtaUpdateService().checkAndUpdate(
  //       context: context,
  //       showProgress: true,
  //       onProgress: (progress) {
  //         debugPrint(
  //           'OTA Update Progress: ${(progress * 100).toStringAsFixed(1)}%',
  //         );
  //       },
  //       onError: (error) {
  //         debugPrint('OTA Update Error: $error');
  //         // Error is already shown in dialog by the service
  //       },
  //     );
  //   } catch (e) {
  //     debugPrint('Error checking OTA update: $e');
  //   }
  // }

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final newVersion = NewVersionPlus(
        iOSId: Constants.applicationId,
        androidId: Constants.applicationId,
        androidPlayStoreCountry: "es_ES",
      );
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
            dismissButtonText: '',
          );
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
          appBarTheme: const AppBarTheme(backgroundColor: Colors.blue),
        ),
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
