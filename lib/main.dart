import 'package:flexischool/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '/common/config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/url_provider.dart';
import 'common/auth_middleware.dart';


void main() {
  runApp(MyApp());
}



//RouteObserver<PageRoute> authMiddleware = RouteObserver<PageRoute>();
// Register the RouteObserver as a navigation observer.


class MyApp extends StatelessWidget {

   MyApp({Key? key}) : super(key: key);


   //final GlobalKey<NavigatorState> navigatorKey1 = GlobalKey<NavigatorState>();


   @override
  Widget build(BuildContext context) {

    //final AuthGuard authGuard = AuthGuard();
    final AuthMiddleware authMiddleware = AuthMiddleware();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=> UrlProvider()),
        ChangeNotifierProvider(create: (_)=>LoginProvider())
      ],
      child: MaterialApp(
          title: Constants.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            //fontFamily: "Montserrat Regular",
            fontFamily: GoogleFonts.lato().fontFamily,
            primarySwatch: Colors.blue, // set the primarySwatch to blue
            //brightness: Brightness.dark,
            //primaryColor: Colors.pink,
            appBarTheme: AppBarTheme(color: Colors.blue),
            //colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.pink).copyWith(secondary: Colors.indigoAccent)// set the primarySwatch to blue
          ),
          //home: const LoaderRoute(),
          routes: routes,
          initialRoute: "/",
          //navigatorKey: navigatorKey1,
          navigatorKey: authMiddleware.navigatorKey,
          navigatorObservers: [authMiddleware]


          ),
    );


  }
}




