import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flexischool/common/api_urls.dart';
import 'package:flexischool/common/webService.dart';
import 'package:flutter/material.dart';

import '../common/config.dart';

//Loader Screen
class LoaderRoute extends StatefulWidget {
  const LoaderRoute({Key? key}) : super(key: key);

  @override
  State<LoaderRoute> createState() => _LoaderRouteState();
}

class _LoaderRouteState extends State<LoaderRoute> {
  late final String appName = Constants.appName;

  Future<void> checkConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      Future.delayed(const Duration(seconds: 3), () {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const Home()),
        // );
        if (mounted) {
          Navigator.pushNamed(context, "/home");
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
            Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )),
            SizedBox(height: 10.0),
            Text(
              appName,
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 22.0,
                color: Colors.white,
              ),
            )
          ],
        ));
  }
}
