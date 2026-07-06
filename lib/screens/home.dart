import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flexischool/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Home Screen
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: HomeScreen());
  }
}

//HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void loginType(String type) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('global_login_type', type);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginRoute()),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // style
    var cardTextStyle = const TextStyle(
      fontFamily: "Montserrat Regular",
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(63, 63, 63, 1),
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        SystemNavigator.pop();
      },
      child: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 0.0),
              height: size.height * .3,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/school-clip-art-86.png"),
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Flexi School',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "Montserrat Regular",
                fontSize: 20.0,
                color: Colors.blue,
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                primary: false,
                crossAxisCount: 2,
                children: <Widget>[
                  GestureDetector(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Image(
                            image: AssetImage('assets/images/school-bus.png'),
                            height: 80,
                          ),
                          const SizedBox(height: 10.0),
                          Text('I am a Bus Driver', style: cardTextStyle),
                        ],
                      ),
                    ),
                    onTap: () {
                      // Bus Driver functionality - currently not implemented
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Bus Driver login is not available yet',
                          ),
                        ),
                      );
                    },
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        loginType('T');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Image(
                            image: AssetImage('assets/images/teacher.png'),
                            height: 80,
                          ),
                          const SizedBox(height: 10.0),
                          Text('I am a Teacher', style: cardTextStyle),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        loginType('S');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Image(
                            image: AssetImage('assets/images/parents.png'),
                            height: 80,
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            'I am a \nParent/Student',
                            style: cardTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        // Management functionality - currently not implemented
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Management login is not available yet',
                            ),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Image(
                            image: AssetImage('assets/images/immigration.png'),
                            height: 80,
                          ),
                          const SizedBox(height: 10.0),
                          Text(
                            'I am a \nManagement',
                            textAlign: TextAlign.center,
                            style: cardTextStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
