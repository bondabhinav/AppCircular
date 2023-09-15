import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

//Home Screen
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //appBar: AppBar(
      //  title: const Text('Flexi School'),
      // ),
      //backgroundColor: Colors.blue,
      body: HomeScreen(),
    );
  }
}

//HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void loginType(type) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('global_login_type', type);
    Navigator.pushNamed(context, "/schoolUrl");
  }

  @override
  void initState() {
    super.initState();
    print('home');
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // style
    var cardTextStyle = const TextStyle(
        fontFamily: "Montserrat Regular",
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(63, 63, 63, 1));
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
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
                  //image: NetworkImage(
                  //    'https://png.pngtree.com/background/20210712/original/pngtree-vector-school-building-background-design-picture-image_1180541.jpg'),
                  //fit: BoxFit.cover,
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // SvgPicture.network(
                          //   'https://image.flaticon.com/icons/svg/1904/1904425.svg',
                          //   height: 128,
                          // ),
                          //Image.('https://image.flaticon.com/icons/svg/1904/1904425.png',height: 128,),
                          const Image(
                            image: AssetImage('assets/images/school-bus.png'),
                            height: 80,
                          ),
                          //Icon(Icons.lock_reset,size: 80.0,color:Colors.blue,),
                          const SizedBox(height: 10.0),
                          Text(
                            'I am a Bus Driver',
                            style: cardTextStyle,
                          )
                        ],
                      ),
                    ),
                    onTap: () {
                      //Navigator.pushNamed(context, "/schoolUrl");
                      loginType('T');
                    },
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        //Navigator.pushNamed(context, "/schoolUrl");
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
                          Text(
                            'I am a Teacher',
                            style: cardTextStyle,
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        //Navigator.pushNamed(context, "/schoolUrl");
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
                          )
                        ],
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        //Navigator.pushNamed(context, "/schoolUrl");
                        loginType('S');
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
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Expanded(
            //   child: GridView.count(
            //     primary: false,
            //     padding: const EdgeInsets.all(20),
            //     crossAxisSpacing: 20,
            //     mainAxisSpacing: 20,
            //     crossAxisCount: 2,
            //     children: <Widget>[
            //       InkWell(
            //         child: Container(
            //           //width:160,
            //           //height:160,
            //           //padding: const EdgeInsets.all(10),
            //
            //           child: SizedBox.fromSize(
            //             size: Size(56,56), // button width and height
            //             child: ClipRRect(
            //               borderRadius: BorderRadius.circular(8.0),
            //               child: Material(
            //                 color: Colors.pink, // button color
            //                 child: Column(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: <Widget>[
            //                     Icon(
            //                       Icons.bus_alert_outlined,
            //                       color: Colors.white,
            //                       size: 64,
            //                     ), // icon
            //                     SizedBox(height: 10),
            //                     Text(
            //                       "I am a Bus Driver",
            //                       style: TextStyle(
            //                           color: Colors.white, fontSize: 18.0),
            //                     ), // text
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         onTap: () {
            //           Navigator.pushNamed(context, "/schoolUrl");
            //         },
            //       ),
            //       InkWell(
            //         child: Container(
            //           //width:160,
            //           //height:160,
            //           //padding: const EdgeInsets.all(10),
            //           child: SizedBox.fromSize(
            //             size: Size(56, 56), // button width and height
            //             child: ClipRRect(
            //               borderRadius: BorderRadius.circular(8.0),
            //               child: Material(
            //                 color: Colors.teal, // button color
            //                 child: Column(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: <Widget>[
            //                     Icon(
            //                       Icons.school,
            //                       color: Colors.white,
            //                       size: 64,
            //                     ),
            //                     // icon
            //                     SizedBox(height: 10),
            //                     Text(
            //                       "I am a Teacher",
            //                       style: TextStyle(
            //                           color: Colors.white, fontSize: 18.0),
            //                     ),
            //                     // text
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         onTap: () {
            //           Navigator.pushNamed(context, "/schoolUrl");
            //         },
            //       ),
            //       InkWell(
            //         child: Container(
            //           //width:160,
            //           //height:160,
            //           //padding: const EdgeInsets.all(10),
            //           child: SizedBox.fromSize(
            //             size: Size(56, 56), // button width and height
            //             child: ClipRRect(
            //               borderRadius: BorderRadius.circular(8.0),
            //               child: Material(
            //                 color: Colors.deepPurple, // button color
            //                 child: Column(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: <Widget>[
            //                     Icon(
            //                       Icons.school,
            //                       color: Colors.white,
            //                       size: 64,
            //                     ),
            //                     // icon
            //                     SizedBox(height: 10),
            //                     Text(
            //                       "I am a \nParent/Student",
            //                       textAlign: TextAlign.center,
            //                       style: TextStyle(
            //                           color: Colors.white, fontSize: 18.0),
            //                     ),
            //                     // text
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         onTap: () {
            //           Navigator.pushNamed(context, "/schoolUrl");
            //         },
            //       ),
            //       InkWell(
            //         child: Container(
            //           //width:160,
            //           //height:160,
            //           //padding: const EdgeInsets.all(10),
            //           child: SizedBox.fromSize(
            //             size: Size(56, 56), // button width and height
            //             child: ClipRRect(
            //               borderRadius: BorderRadius.circular(8.0),
            //               child: Material(
            //                 color: Colors.deepOrange, // button color
            //                 child: Column(
            //                   mainAxisAlignment: MainAxisAlignment.center,
            //                   children: <Widget>[
            //                     Icon(
            //                       Icons.school,
            //                       color: Colors.white,
            //                       size: 64,
            //                     ),
            //                     // icon
            //                     SizedBox(height: 10),
            //                     Text(
            //                       "I am a \nManagement",
            //                       textAlign: TextAlign.center,
            //                       style: TextStyle(
            //                           color: Colors.white, fontSize: 18.0),
            //                     ),
            //                     // text
            //                   ],
            //                 ),
            //               ),
            //             ),
            //           ),
            //         ),
            //         onTap: () {
            //           Navigator.pushNamed(context, "/schoolUrl");
            //         },
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
