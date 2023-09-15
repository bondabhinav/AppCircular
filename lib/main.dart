import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/firebase_options.dart';
import 'package:flexischool/notification_helper.dart';
import 'package:flexischool/providers/loader_provider.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flexischool/utils/locator.dart';
import 'package:flexischool/utils/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/common/config.dart';
import 'common/auth_middleware.dart';
import 'providers/url_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WebService.init();
  FirebaseApp app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Initialized default app $app from Android resource');
  await PushNotificationsManager().init();
  await NotificationService.initializeNotification();
  setupLocator();
  debugPrint('fcm token ===> ${PushNotificationsManager().fcmToken}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthMiddleware authMiddleware = AuthMiddleware();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UrlProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => LoaderProvider())
      ],
      child: MaterialApp(
          title: Constants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: GoogleFonts.lato().fontFamily,
            primarySwatch: Colors.blue,
            appBarTheme: const AppBarTheme(color: Colors.blue),
          ),
          routes: routes,
          initialRoute: "/",
          navigatorKey: AuthMiddleware.navigatorKey,
          navigatorObservers: [authMiddleware]),
    );
  }
}

class TokenScreen extends StatefulWidget {
  const TokenScreen({Key? key}) : super(key: key);

  @override
  State<TokenScreen> createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  String token = '';

  @override
  void initState() {
    getToken();
    super.initState();
  }

  getToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(
            token,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }
}
