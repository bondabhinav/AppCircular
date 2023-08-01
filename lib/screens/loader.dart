import 'package:flutter/material.dart';
import '../common/config.dart';
import '/screens/home.dart';
import 'check_internet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
//Loader Screen
class LoaderRoute extends StatefulWidget {
  const LoaderRoute({Key? key}) : super(key: key);

  @override
  State<LoaderRoute> createState() => _LoaderRouteState();
}

class _LoaderRouteState extends State<LoaderRoute> {
  late final String appName = Constants.appName;

  Future<void> checkConnection() async {


    final connectivityResult =
    await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {

      Future.delayed(const Duration(seconds: 3), () {
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const Home()),
        // );
        Navigator.pushNamed(context, "/home");
      });
    }else{
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
    checkConnection();
    // Future.delayed(const Duration(seconds: 3), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const CheckInternet()),
    //   );
    // });
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
