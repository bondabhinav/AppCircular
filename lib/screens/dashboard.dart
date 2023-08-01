import 'dart:ffi';

import 'package:flexischool/common/webService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/webService.dart';
import '../providers/login_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DropdownSession {
  final int SESSION_ID;
  final String START_DATE;
  final String END_DATE;
  final String? ACTIVE;

  DropdownSession(
      {required this.SESSION_ID,
      required this.START_DATE,
      required this.END_DATE,
      required this.ACTIVE});
}

class MyDropdownWidget extends StatefulWidget {
  @override
  _MyDropdownWidgetState createState() => _MyDropdownWidgetState();
}

class _MyDropdownWidgetState extends State<MyDropdownWidget> {
  //List<DropdownSession> dropdownItems = [];
  //DropdownSession ? selectedDropdownItem;
  //bool hasError = false;
  List sData = [];
  var selectedDropdownItem;
  var activeVal;

  // Future<List<DropdownSession>> fetchData() async {
  //   // Make an HTTP GET request to your API endpoint
  //   //final response = await http.get(Uri.parse('YOUR_API_ENDPOINT'));
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final schoolBaseUrl = prefs.getString('global_school_url');
  //
  //   var requestedData = {
  //     "SCHOOL_ID":"1"
  //   };
  //
  //   var body = json.encode(requestedData);
  //
  //     final response = await http.post(
  //       Uri.parse(schoolBaseUrl! + 'SessionSearch/SessionSearch'),
  //       headers: {
  //         "Accept": "application/json",
  //         "Content-Type": "application/json",
  //         //"Authorization": token
  //       },
  //       body: body,
  //     );
  //
  //   if (response.statusCode == 200) {
  //     // Parse the response JSON
  //     final data1 = json.decode(response.body);
  //     final data = data1['SessionDD'];
  //
  //     //print(data);
  //
  //     // Create a list of DropdownItem objects from the response data
  //     final items = List<DropdownSession>.from(data.map(
  //           (item) => DropdownSession(
  //               SESSION_ID: item['SESSION_ID'] ?? 0,
  //               START_DATE: item['START_DATE'] ?? '',
  //               END_DATE: item['END_DATE'] ?? '',
  //               ACTIVE: item['ACTIVE'] ?? 'N',
  //       ),
  //     ));
  //
  //     // Filter the items to find the active item
  //     // final activeItem = items.firstWhere(
  //     //       (item) => item.ACTIVE == 'Y',
  //     //                //orElse: () => null,
  //     // );
  //
  //     final activeItem = items.where((item) => item.ACTIVE == 'Y').toList();
  //
  //     if (activeItem.isNotEmpty) {
  //       // Set the selected item based on the condition
  //
  //       selectedDropdownItem = activeItem.first;
  //     } else {
  //       // No active item found
  //       hasError = true;
  //     }
  //
  //     //Set the selected item based on the condition
  //     //selectedDropdownItem = activeItem;
  //
  //     return items;
  //   } else {
  //     throw Exception('Failed to fetch data');
  //   }
  // }

  Future<void> sessionData() async {
    final prefs = await SharedPreferences.getInstance();
    final schoolBaseUrl = prefs.getString('global_school_url');

    var requestedData = {"SCHOOL_ID": "1"};

    var body = json.encode(requestedData);

    final response = await http.post(
      Uri.parse(schoolBaseUrl! + 'SessionSearch/SessionSearch'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        //"Authorization": token
      },
      body: body,
    );
    if (response.statusCode == 200) {
      final data1 = json.decode(response.body);
      final data = data1['SessionDD'];

      setState(() {
        sData = data;
        //print(sData);
      });
      await Future.delayed(const Duration(milliseconds: 1000));
    } else {
      print('Failed to fetch data from API');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sessionData();

    //selectedDropdownItem=6;
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider loginStore = Provider.of<LoginProvider>(context);

    // setState(() {
    //   loginStore.session =  'vijay1';
    //   print(loginStore.session);
    // });
    //loginStore.notify();

    final activeItem = sData.where((item) => item['ACTIVE'] == 'Y').toList();
    if (activeItem.isNotEmpty) {
      activeVal = (activeItem.first)['SESSION_ID'];
      selectedDropdownItem ??= activeVal;
    }

    return Container(
      //width: 200.0,
      width: double.infinity,
      margin: const EdgeInsets.only(right: 20.0),
      child: DropdownButton(
          items: sData.map((item) {
            var itemDate = (item['START_DATE']).substring(0, 4) +
                '-' +
                (item['END_DATE']).substring(0, 4);
            //print('inside');
            //print(item['SESSION_ID']);
            return DropdownMenuItem(
              value: item['SESSION_ID'],
              child: Text(itemDate),
            );
          }).toList(),
          value: selectedDropdownItem,
          isExpanded: true,
          elevation: 16,
          alignment: Alignment.center,
          //style: const TextStyle(color: Colors.deepPurple),
          onChanged: (newValue) {
            setState(() {
              selectedDropdownItem = newValue!;
            });
          }),
    );

    // return FutureBuilder<List<DropdownSession>>(
    //   future: fetchData(),
    //   builder: (context, snapshot) {
    //     if (snapshot.hasData) {
    //       dropdownItems = snapshot.data!;
    //       if (hasError) {
    //         // Display error message in the dropdown
    //         return DropdownButton<DropdownSession>(
    //           items: [
    //             DropdownMenuItem<DropdownSession>(
    //               value: null,
    //               child: Text('No active item found'),
    //             ),
    //           ],
    //           onChanged: null,
    //         );
    //       } else {
    //       return Container(
    //         width: 30,
    //         //padding: EdgeInsets.all(12),
    //         child: DropdownButton<DropdownSession>(
    //           value: selectedDropdownItem,
    //           icon: const Icon(Icons.arrow_downward),
    //           elevation: 16,
    //           // style: const TextStyle(color: Colors.deepPurple),
    //           // underline: Container(
    //           //   height: 2,
    //           //   color: Colors.deepPurpleAccent,
    //           // ),
    //           items: dropdownItems.map((item) {
    //             var itemDate = (item.START_DATE).substring(0, 4) + '-' +
    //                 (item.END_DATE).substring(0, 4);
    //
    //             return DropdownMenuItem<DropdownSession>(
    //               value: item,
    //               child: Text(itemDate),
    //             );
    //           }).toList(),
    //           onChanged: (newValue) {
    //             setState(() {
    //               print('ses');
    //               print(newValue.toString());
    //
    //               selectedDropdownItem = newValue;
    //             });
    //           },
    //         ),
    //       );
    //     }
    //     } else if (snapshot.hasError) {
    //       return Text('Error: ${snapshot.error}');
    //     } else {
    //       return Column(
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: <Widget>[
    //           Center(
    //             child: Container(
    //               height: 20,
    //               width: 20,
    //               margin: EdgeInsets.all(5),
    //               child: CircularProgressIndicator(
    //                 strokeWidth: 2.0,
    //                 valueColor : AlwaysStoppedAnimation(Colors.blue),
    //               ),
    //             ),
    //           ),
    //         ],
    //       );
    //     }
    //   },
    // );
  }
}

class CustomUserAccountsDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final LoginProvider loginStore = Provider.of<LoginProvider>(context);
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(loginStore.photo),
                radius: 30,
              ),
              SizedBox(width: 10),
              Text(
                '${loginStore.userName}',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Montserrat Regular",
                  color: Colors.white,
                ),
              ),
            ],
          ),

          SizedBox(height: 5),
          Text(
            'Employee Code : ${loginStore.employeeCode}',
            style: TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.black,
            ),
          ),

          //SizedBox(height: 5),
          Text(
            'Department : ${loginStore.depName}',
            style: TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.black,
            ),
          ),
          Text(
            'Designation : ${loginStore.designation}',
            style: TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.black,
            ),
          ),
          //SizedBox(height: 5),
          Text(
            'Session : ${loginStore.session}',
            style: TextStyle(
              fontSize: 13,
              fontFamily: "Montserrat Regular",
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool hasNotifications = true; // Set this to false to hide the notification icon

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //Fetch Dashboard
  // Future _fetchDashboard() async {
  //   print('load');
  //   var loginType ='T';
  //
  //   WebService.fetchDashboard(loginType).then((response) {
  //     //API Response
  //     print('load1');
  //
  //     print(response);
  //
  //     if (response['status'] == true) {
  //
  //       print(response['data']);
  //
  //
  //     }
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(response['message'])),
  //     );
  //
  //     //API Response
  //   }).catchError((e) {
  //     //_errorMessage = 'Error: $e';
  //
  //   }).whenComplete(() {
  //     // setState(() {
  //     //   _isLoading = false;
  //     // });
  //   });
  // }

  void logout(BuildContext context) {
    final LoginProvider loginStore =
        Provider.of<LoginProvider>(context, listen: false);
    loginStore.userLogout();
    print('user logout');

    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LoginProvider loginStore = Provider.of<LoginProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          if (hasNotifications) ...[
            IconButton(
              icon: Stack(
                children: [
                  Icon(Icons.notifications),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              onPressed: () {
                //Navigator.pushNamed(context, '/notificationPage');
                Navigator.pushReplacementNamed(context, '/notificationAssignment');
              },
            ),
          ],
        ],
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            CustomUserAccountsDrawerHeader(),
            // UserAccountsDrawerHeader(
            //   accountName: Text(loginStore.userName),
            //   accountEmail: Text('vijay@demo.com'),
            //   currentAccountPicture: CircleAvatar(
            //     backgroundImage: NetworkImage(
            //         'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQD5-iT2qq-hExKNkJmcZKaKJmpZGZAgLH7eUKF_PAT0g&usqp=CAU&ec=48600112'),
            //     radius: 50.0,
            //   ),
            //   /*
            //     otherAccountsPictures: <Widget>[
            //       CircleAvatar(
            //         backgroundColor: Colors.white,
            //         child: Text('Xyz'),
            //       )
            //     ],
            //     */
            // ),
            /*
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.pink,
                ),
                child: Text('Flexi School',style: TextStyle(color: Colors.white),),
              ),*/

            ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              title: MyDropdownWidget(),
              leading: Icon(Icons.access_time),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              //trailing: Icon(Icons.add),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              title: const Text('Profile'),
              leading: Icon(Icons.notifications_paused_rounded),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              //trailing: Icon(Icons.add),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),
            ListTile(
              //dense: true,
              //contentPadding: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              title: const Text('Change Session'),
              leading: Icon(Icons.lock_reset),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              onTap: () {},
            ),
            ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              title: const Text('Change Password'),
              leading: Icon(Icons.lock),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              onTap: () {
                // Update the state of the app.
                // ...
                /*
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginRoute()),
                  );*/
              },
            ),
            ListTile(
              visualDensity: VisualDensity(horizontal: 0, vertical: -4),
              title: const Text('Logout'),
              leading: Icon(Icons.logout),
              minLeadingWidth: 10,
              horizontalTitleGap: 10,
              onTap: () {
                //Navigator.pushNamed(context, "/", arguments: " Login");
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: const DashboardWidget(),
      // bottomNavigationBar: BottomNavigationBar(
      //     items: const <BottomNavigationBarItem>[
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.home),
      //         label: 'Home',
      //         backgroundColor: Colors.blue,
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.business),
      //         label: 'Student',
      //         backgroundColor: Colors.blue,
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.school),
      //         label: 'School',
      //         backgroundColor: Colors.blue,
      //       ),
      //       BottomNavigationBarItem(
      //         icon: Icon(Icons.settings),
      //         label: 'Settings',
      //         backgroundColor: Colors.blue,
      //       ),
      //     ],
      //     currentIndex: _selectedIndex,
      //     selectedItemColor: Colors.black,
      //     onTap: _onItemTapped),
    );
  }
}

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  //late Future<List> fetchService;

  // late String _username;
  // late String _employeeCode;
  //
  //
  // void userInfo() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userDetails = prefs.getString('user_details');
  //   var res = jsonDecode(userDetails!);
  //
  //   setState(() {
  //     _username = res['USER_NAME'];
  //     _employeeCode = res['EMPLOYEE_CODE'];
  //   });
  //
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //fetchService = WebService.fetchPhotos();
  }

  @override
  Widget build(BuildContext context) {
    // to get size
    var size = MediaQuery.of(context).size;
    final LoginProvider loginStore = Provider.of<LoginProvider>(context);
    print(loginStore.photo);
    // style
    var cardTextStyle = TextStyle(
        fontFamily: "Montserrat Regular",
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(63, 63, 63, 1));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: size.height * .3,
            decoration: BoxDecoration(
              image: DecorationImage(
                  alignment: Alignment.topCenter,
                  image: AssetImage('assets/images/top_header_new.png')),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Container(
                    //height: 64,
                    margin: EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        CircleAvatar(
                          radius: 42,
                          backgroundImage: NetworkImage(loginStore.photo),
                        ),
                        SizedBox(
                          width: 16,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              loginStore.userName,
                              style: TextStyle(
                                  fontFamily: "Montserrat Medium",
                                  color: Colors.white,
                                  fontSize: 18),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              'Employee Code : ${loginStore.employeeCode}',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              ),
                            ),
                            //SizedBox(height: 10.0),
                            Text(
                              'Department : ${loginStore.depName}',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              'Designation : ${loginStore.designation}',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              ),
                            ),
                            //SizedBox(height: 10.0),
                            Text(
                              'Session :  ${loginStore.session}',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontFamily: "Montserrat Regular",
                                color: Colors.black,
                              ),
                            ),
                            // Text(
                            //   '4101410141',
                            //   style: TextStyle(
                            //       fontSize: 14,
                            //       color: Colors.white,
                            //       fontFamily: "Montserrat Regular"),
                            // )
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List>(
                      future: WebService.fetchDashboard(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child:
                                Text('Something went wrong please try again!'),
                          );
                        } else if (snapshot.hasData) {
                          //return Text(snapshot.data![0].MENUNAME);
                          return DashBoardList(
                              dashboards: snapshot.requireData);
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
                    // GridView.count(
                    //   mainAxisSpacing: 10,
                    //   crossAxisSpacing: 10,
                    //   primary: false,
                    //   crossAxisCount: 2,
                    //   children: <Widget>[
                    //     GestureDetector(
                    //       child: Card(
                    //         shape:RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(8)
                    //         ),
                    //         elevation: 4,
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: <Widget>[
                    //             // SvgPicture.network(
                    //             //   'https://image.flaticon.com/icons/svg/1904/1904425.svg',
                    //             //   height: 128,
                    //             // ),
                    //             //Image.('https://image.flaticon.com/icons/svg/1904/1904425.png',height: 128,),
                    //             Image(image: AssetImage('assets/images/list.png'),height: 80,),
                    //             //Icon(Icons.lock_reset,size: 80.0,color:Colors.blue,),
                    //             SizedBox(height: 10.0),
                    //             Text(
                    //               'Assignments',
                    //               style: cardTextStyle,
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //       onTap: () {
                    //         print("Click event on Container");
                    //       },
                    //     ),
                    //
                    //     Card(
                    //       shape:RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8)
                    //       ),
                    //       elevation: 4,
                    //       child: InkWell(
                    //         onTap: () {
                    //           print('test');
                    //         },
                    //         child: Column(
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: <Widget>[
                    //             Image(image: AssetImage('assets/images/comments.png'),height: 80,),
                    //             SizedBox(height: 10.0),
                    //             Text(
                    //               'Circulars',
                    //               style: cardTextStyle,
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //
                    //     Card(
                    //       shape:RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8)
                    //       ),
                    //       elevation: 4,
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: <Widget>[
                    //           Image(image: AssetImage('assets/images/online-learning.png'),height: 80,),
                    //           SizedBox(height: 10.0),
                    //           Text(
                    //             'Manage \n Online Class',
                    //             style: cardTextStyle,
                    //             textAlign: TextAlign.center,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //
                    //     Card(
                    //       shape:RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8)
                    //       ),
                    //       elevation: 4,
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: <Widget>[
                    //           Image(image: AssetImage('assets/images/immigration.png'),height: 80,),
                    //           SizedBox(height: 10.0),
                    //           Text(
                    //             'Attendance',
                    //             style: cardTextStyle,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //
                    //     Card(
                    //       shape:RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8)
                    //       ),
                    //       elevation: 4,
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: <Widget>[
                    //           Image(image: AssetImage('assets/images/exam.png'),height: 80,),
                    //           SizedBox(height: 10.0),
                    //           Text(
                    //             'Examination',
                    //             style: cardTextStyle,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //
                    //     Card(
                    //       shape:RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8)
                    //       ),
                    //       elevation: 4,
                    //       child: Column(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: <Widget>[
                    //           Image(image: AssetImage('assets/images/live-chat.png'),height: 80,),
                    //           SizedBox(height: 10.0),
                    //           Text(
                    //             'Chatting',
                    //             style: cardTextStyle,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> dashboardIcon() async {
  final prefs = await SharedPreferences.getInstance();
  final icon = prefs.getString('global_school_logo');
  return icon!;
}

//Dashboard List
class DashBoardList extends StatelessWidget {
  final List dashboards;

  final iconImage = [
    'assets/images/list.png',
    'assets/images/comments.png',
    'assets/images/online-learning.png',
    'assets/images/immigration.png',
    'assets/images/exam.png',
    'assets/images/live-chat.png'
  ];

  DashBoardList({super.key, required this.dashboards});

  @override
  Widget build(BuildContext context) {
    //final LoginProvider LoginStore =  Provider.of<LoginProvider>(context);

    //print(LoginStore.loginInStatus.name);

    // style
    var cardTextStyle = TextStyle(
        fontFamily: "Montserrat Regular",
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color.fromRGBO(63, 63, 63, 1));

    //String profileLogo  = ;

    return FutureBuilder<String>(
      future: dashboardIcon(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String? iconPath = snapshot.data;
          // Use the retrieved value in your widget
          return GridView.builder(
            primary: false,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
            padding: EdgeInsets.all(8),
            shrinkWrap: true,
            itemCount: dashboards.length,
            itemBuilder: (context, index) {
              //return Text(dashboards[index].MENUNAME);
              return GestureDetector(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // SvgPicture.network(
                      //   'https://image.flaticon.com/icons/svg/1904/1904425.svg',
                      //   height: 128,
                      // ),
                      Image.network(
                        iconPath! + dashboards[index].IMAGE,
                        height: 80,
                      ),
                      // Image(
                      //   image: AssetImage(iconImage[index]),
                      //   height: 80,
                      // ),
                      //Icon(Icons.lock_reset,size: 80.0,color:Colors.blue,),
                      SizedBox(height: 10.0),
                      Text(
                        dashboards[index].MENUNAME,
                        style: cardTextStyle,
                      )
                    ],
                  ),
                ),
                onTap: () {
                  print(iconPath! + dashboards[index].IMAGE);
                  Navigator.pushReplacementNamed(context, '/assignment');
                },
              );
            },
          );
        } else {
          // Handle the case when the value is still loading or not available
          return CircularProgressIndicator();
        }
      },
    );

    // return GridView.builder(
    //   primary: false,
    //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    //       crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
    //   padding: EdgeInsets.all(8),
    //   shrinkWrap: true,
    //   itemCount: dashboards.length,
    //   itemBuilder: (context, index) {
    //     //return Text(dashboards[index].MENUNAME);
    //     return GestureDetector(
    //       child: Card(
    //         shape:
    //             RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    //         elevation: 4,
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: <Widget>[
    //             // SvgPicture.network(
    //             //   'https://image.flaticon.com/icons/svg/1904/1904425.svg',
    //             //   height: 128,
    //             // ),
    //             //Image.('https://image.flaticon.com/icons/svg/1904/1904425.png',height: 128,),
    //             Image(
    //               image: AssetImage(iconImage[index]),
    //               height: 80,
    //             ),
    //             //Icon(Icons.lock_reset,size: 80.0,color:Colors.blue,),
    //             SizedBox(height: 10.0),
    //             Text(
    //               dashboards[index].MENUNAME,
    //               style: cardTextStyle,
    //             )
    //           ],
    //         ),
    //       ),
    //       onTap: () {
    //
    //         print(dashboards[index].IMAGE);
    //       },
    //     );
    //   },
    // );
  }
}
