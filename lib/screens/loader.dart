import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flexischool/app_update.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flexischool/providers/login_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/src/url_launcher_uri.dart';

import '../common/config.dart';

//Loader Screen
class LoaderRoute extends StatefulWidget {
  const LoaderRoute({super.key});

  @override
  State<LoaderRoute> createState() => _LoaderRouteState();
}

class _LoaderRouteState extends State<LoaderRoute> {
  late final String appName = Constants.appName;

  Future<void> checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      Future.delayed(const Duration(seconds: 3), () async {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const Home()),
        // );
        // if (mounted) {
        //   Navigator.pushNamed(context, "/home");
        // }

        if (mounted) {
          if (!await checkForUpdate(context)) {
            if (!await isUserIn() && !await isStudentUserIn() && !await isSchoolUrlIn()) {
              // Navigate to /schoolUrl
              Navigator.pushReplacementNamed(context, '/schoolUrl');
            } else if (!await isUserIn() && !await isStudentUserIn() && await isSchoolUrlIn()) {
              // Check isLoginType
              if (!await isLoginType()) {
                // Navigate to /home
                Navigator.pushReplacementNamed(context, '/home');
              } else {
                // Navigate to /login
                Navigator.pushReplacementNamed(context, '/login');
              }
            } else {
              final loginAuth = Provider.of<LoginProvider>(context, listen: false);
              loginAuth.assignUserProvider();

              if (await isUserIn()) {
                // Navigate to /dashboard
                Navigator.pushReplacementNamed(context, '/dashboard');
              } else if (await isStudentUserIn()) {
                // Navigate to /studentDashboard
                Navigator.pushReplacementNamed(context, '/studentDashboard');
              } else {
                debugPrint('Last else');
              }
            }
          } else {
            if (mounted) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                            body: Material(
                              child: PopScope(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Center(
                                            child: Text(
                                              'Update Required',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 20),
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                              'A new version of the app is available. Please update to continue using the app.'),
                                          const SizedBox(height: 20),
                                          Center(
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.blue,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      )),
                                                  onPressed: () async {
                                                    SystemNavigator.pop();
                                                    if (await canLaunchUrl(Uri.parse(
                                                        'https://play.google.com/store/apps/details?id=flexischoolerpapp.sapinfotek.com'))) {
                                                      await launchUrl(Uri.parse(
                                                          'https://play.google.com/store/apps/details?id=flexischoolerpapp.sapinfotek.com'));
                                                    } else {
                                                      throw 'Could not launch appStoreLink';
                                                    }
                                                  },
                                                  child: const Text(
                                                    'Update Now',
                                                    style: TextStyle(color: Colors.white),
                                                  )),
                                            ),
                                          ),
                                        ]),
                                  ),
                                  onPopInvoked: (_) {
                                    SystemNavigator.pop();
                                    return;
                                  }),
                            ),
                          )));
            }
          }
        }
      });
    } else {
      Future.delayed(const Duration(seconds: 3), () {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const CheckInternet()),
        // );
        Navigator.pushNamed(context, "/checkInternet");
      });
    }
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

  @override
  void initState() {
    super.initState();
    getLoginData();
    getUrlData();
    checkConnection();
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const CheckInternet()),
    //   );
    // });
  }

  void getLoginData() async {
    final data = await WebService.getStudentLoginDetails();
    if (data != null) {
      WebService.studentLoginData = data;
      setState(() {});
      log('user data ***** ${data.toJson().toString()}');
    }
  }

  void getUrlData() async {
    final data = await WebService.getSchoolUrl();
    final imageUrlData = await WebService.getSchoolImageUrl();
    if (data != null) {
      Api.baseUrl = data;
      setState(() {});
      log('baseUrl ***** ${Api.baseUrl}');
    }

    if (imageUrlData != null) {
      Api.imageBaseUrl = imageUrlData;
      setState(() {});
      log('imageUrlData ***** ${Api.imageBaseUrl}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )),
            const SizedBox(height: 10.0),
            Text(
              appName,
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 22.0,
                color: Colors.white,
              ),
            )
          ],
        ));
  }
}
