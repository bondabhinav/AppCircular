import 'dart:async';

import 'package:flexischool/common/webService.dart';
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
  await NotificationService.initializeNotification();
  setupLocator();
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
          navigatorKey: authMiddleware.navigatorKey,
          navigatorObservers: [authMiddleware]),
    );
  }
}
