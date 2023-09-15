import 'package:flexischool/common/webService.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthGuard {
  static bool isLogged = false;

  static bool checkAuthenticationStatus() {
    // Check the "is_login" status
    return isLogged;
  }
}

//class AuthMiddleware extends RouteObserver<PageRoute<dynamic>> {
class AuthMiddleware extends NavigatorObserver {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  //late final BuildContext context;

  //AuthMiddleware(this.context);

  //final MyUrlProvider = Provider.of<UrlProvider>(context);

  @override
  Future<void> didPush(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    //context = navigatorKey.currentContext;

    print('call');
    print(route.settings.name);

    // //Provider Value Get
    // final urlAuth  = Provider.of<UrlProvider >(route!.navigator!.context, listen: false);
    // final value = urlAuth.myValue;
    // print(value);
    //var store = getValueFromSharedPreferences();
    //print(store);

    //  final prefs = await SharedPreferences.getInstance();
    // final data = prefs.getString('global_school_url');
    //
    //  print(data);

    //await isUserIn() ? print("true1") : print("false1");

    if (route.settings.name == '/home' || route.settings.name == '/schoolUrl') {
      if ((await isUserIn())) {
        final loginlAuth = Provider.of<LoginProvider>(route!.navigator!.context, listen: false);
        loginlAuth.assignUserProvider();
        Future.delayed(Duration.zero, () async {
          navigatorKey.currentState?.pushReplacementNamed('/dashboard');
        });
      } else if ((await isStudentUserIn())) {
        final loginlAuth = Provider.of<LoginProvider>(route.navigator!.context, listen: false);
        loginlAuth.assignUserProvider();
        Future.delayed(Duration.zero, () async {
          navigatorKey.currentState?.pushReplacementNamed('/studentDashboard');
        });
      } else if (!await isLoginType()) {
        print('midlcall type');
        Future.delayed(Duration.zero, () {
          navigatorKey.currentState?.pushReplacementNamed('/home');
        });
      } else if (await isSchoolUrlIn()) {
        print('midlcall');
        Future.delayed(Duration.zero, () {
          navigatorKey.currentState?.pushReplacementNamed('/login');
        });
      }
    }

    //await isSchoolUrlIn() ? print("true") : print("false");

    //Share Pre Val
    //final UrlProvider urlAuth =  Provider.of<UrlProvider>(route!.navigator!.context, listen: false);

    // print(urlAuth.urInStatus);

    //checkAuth(route, previousRoute);

    super.didPush(route, previousRoute);
    // if (route.settings.name == '/schoolUrl' && !AuthGuard.checkAuthenticationStatus()) {
    //   // Redirect to the login screen if not logged in
    //   navigator?.pushReplacementNamed('/login');
    // }
    //
    //
    // // Check if the pushed route requires authentication
    // if (route.settings.name == '/profile' && !AuthGuard.checkAuthenticationStatus()) {
    //   // Redirect to the login screen if not logged in
    //   navigator?.pushReplacementNamed('/login');
    // }
  }

  // @override
  // void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
  //   super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  //   // Check if the replaced route requires authentication
  //   if (newRoute?.settings.name == '/profile' && !AuthGuard.checkAuthenticationStatus()) {
  //     // Redirect to the login screen if not logged in
  //     navigator?.pushReplacementNamed('/login');
  //   }
  // }
  //
  @override
  Future<void> didPop(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    super.didPop(route, previousRoute);
    print('pop122');
    print(route.settings.name);
    if (route.settings.name == '/dashboard' ||
        route.settings.name == '/studentDashboard' ||
        route.settings.name == '/home' ||
        route.settings.name == '/schoolUrl' ||
        route.settings.name == '/login') {
      if ((await isUserIn())) {
        print('popA');
        final loginlAuth = Provider.of<LoginProvider>(route!.navigator!.context, listen: false);
        loginlAuth.assignUserProvider();

        Future.delayed(Duration.zero, () async {
          navigatorKey.currentState?.pushReplacementNamed('/dashboard');
        });
      } else if ((await isStudentUserIn())) {
        final loginlAuth = Provider.of<LoginProvider>(route.navigator!.context, listen: false);
        loginlAuth.assignUserProvider();
        Future.delayed(Duration.zero, () async {
          navigatorKey.currentState?.pushReplacementNamed('/studentDashboard');
        });
      } else if (await isSchoolUrlIn()) {
        Future.delayed(Duration.zero, () {
          navigatorKey.currentState?.pushReplacementNamed('/login');
        });
      }
    }
    // Check if the popped route requires authentication
    //print('call back');
    // if (previousRoute?.settings.name == '/profile' && !AuthGuard.checkAuthenticationStatus()) {
    //   // Redirect to the login screen if not logged in
    //   navigator?.pushReplacementNamed('/login');
    // }
  }

  Future<bool> isSchoolUrlIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the token from shared preferences
    String? globalSchoolUrl = prefs.getString('global_school_url');
    // Return true if the token exists, false otherwise
    return globalSchoolUrl != null;
  }

  Future<bool> isLoginType() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the token from shared preferences
    String? globalLoginType = prefs.getString('global_login_type');
    // Return true if the token exists, false otherwise
    return globalLoginType != null;
  }

  Future<bool> isUserIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('user_details');
    // Return true if the token exists, false otherwise
    return userDetails != null;
  }

  Future<bool> isStudentUserIn() async {
    final prefs = await SharedPreferences.getInstance();
    final userDetails = prefs.getString('student_data');
    // Return true if the token exists, false otherwise
    return userDetails != null;
  }

  Future<void> checkAuth(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    //Provider Value Get
    // final urlAuth  = Provider.of<UrlProvider >(route!.navigator!.context, listen: false);
    // final value = urlAuth.myValue;
    // print(value);
    //
    // final prefs = await SharedPreferences.getInstance();
    // final data = prefs.getString('school_url_response');
    //
    // print(data);

    if (route.settings.name == '/schoolUrl') {
      Future.delayed(Duration.zero, () async {
        final newType = await WebService.getLoginType();
        if (newType == 'S') {

          navigatorKey.currentState?.pushReplacementNamed('/studentDashboard');
        } else {
          navigatorKey.currentState?.pushReplacementNamed('/dashboard');
        }
      });
    }

    // WidgetsBinding.instance?.addPostFrameCallback((_) {
    //   //navigateToLogin();
    //   route.navigator?.pushReplacementNamed('/login');
    // });
  }
}
