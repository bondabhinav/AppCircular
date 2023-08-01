import 'package:flutter/material.dart';
import '../widgets/card-widget.dart';


class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
           UserAccountsDrawerHeader(
              accountName: Text('Vijay Chakaravarthy'),
              accountEmail: Text('vijay@demo.com'),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQD5-iT2qq-hExKNkJmcZKaKJmpZGZAgLH7eUKF_PAT0g&usqp=CAU&ec=48600112'),
                radius: 50.0,
              ),
              /*
                otherAccountsPictures: <Widget>[
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text('Xyz'),
                  )
                ],
                */
            ),
            /*
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.pink,
                ),
                child: Text('Flexi School',style: TextStyle(color: Colors.white),),
              ),*/
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
                Navigator.pushNamed(context, "/",arguments: " Login");
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

  // void handleButton1Press() {
  //   print('Button 1 pressed!');
  // }
  //
  // void handleButton2Press() {
  //   print('Button 2 pressed!');
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //CardWidget(name:'Swetha',color:Colors.red,btnColor: Colors.blue,onPressed: handleButton1Press),
        //CardWidget(name:'Dharshini',color:Colors.green,btnColor: Colors.red,onPressed: handleButton2Press),

        Card(
          elevation: 4.0,
          color: Colors.amber,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: <Widget>[
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQD5-iT2qq-hExKNkJmcZKaKJmpZGZAgLH7eUKF_PAT0g&usqp=CAU&ec=48600112'),
                      radius: 50.0,
                    ),
                    SizedBox(height: 10.0),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Vijay Chakaravarthy',
                                style: TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Employee Code : 5032',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Designation : PPRT',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 10.0),
                              Text(
                                'Session : 2022 - 2023',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(30),
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            crossAxisCount: 2,
            children: <Widget>[
              InkWell(
                child: Container(
              //width: 100.0,
               //height: 100.0,
                  //padding: const EdgeInsets.all(10),

                  child: SizedBox.fromSize(
                    size: Size(56, 56), // button width and height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Material(
                        color: Colors.blue, // button color
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.bus_alert_outlined,
                              color: Colors.white,
                              size: 64,
                            ), // icon
                            SizedBox(height: 10),
                            Text(
                              "Assignments",
                              style: TextStyle(color: Colors.white),
                            ), // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  print("Tapped on container");
                },
              ),
              InkWell(
                child: Container(
                  //width:160,
                  //height:160,
                  //padding: const EdgeInsets.all(10),
                  child: SizedBox.fromSize(
                    size: Size(56, 56), // button width and height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Material(
                        color: Colors.green, // button color
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 64,
                            ),
                            // icon
                            SizedBox(height: 10),
                            Text(
                              "Circulars",
                              style: TextStyle(color: Colors.white),
                            ),
                            // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  print("Tapped on container");
                },
              ),
              InkWell(
                child: Container(
                  //width:160,
                  //height:160,
                  //padding: const EdgeInsets.all(10),
                  child: SizedBox.fromSize(
                    size: Size(56, 56), // button width and height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Material(
                        color: Colors.deepPurple, // button color
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 64,
                            ),
                            // icon
                            SizedBox(height: 10),
                            Text(
                              "Manage Online Class",
                              style: TextStyle(color: Colors.white),
                            ),
                            // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  print("Tapped on container");
                },
              ),
              InkWell(
                child: Container(
                  //width:160,
                  //height:160,
                  //padding: const EdgeInsets.all(10),
                  child: SizedBox.fromSize(
                    size: Size(56, 56), // button width and height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Material(
                        color: Colors.deepOrange, // button color
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 64,
                            ),
                            // icon
                            SizedBox(height: 10),
                            Text(
                              "Attendance",
                              style: TextStyle(color: Colors.white),
                            ),
                            // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  print("Tapped on container");
                },
              ),
              InkWell(
                child: Container(
                  //width:160,
                  //height:160,
                  //padding: const EdgeInsets.all(10),
                  child: SizedBox.fromSize(
                    size: Size(56, 56), // button width and height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Material(
                        color: Colors.pinkAccent, // button color
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 64,
                            ),
                            // icon
                            SizedBox(height: 10),
                            Text(
                              "Examination",
                              style: TextStyle(color: Colors.white),
                            ),
                            // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  print("Tapped on container");
                },
              ),
              InkWell(
                child: Container(
                  //width:160,
                  //height:160,
                  //padding: const EdgeInsets.all(10),
                  child: SizedBox.fromSize(
                    size: Size(56, 56), // button width and height
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.0),
                      child: Material(
                        color: Colors.lightGreen, // button color
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 64,
                            ),
                            // icon
                            SizedBox(height: 10),
                            Text(
                              "Chatting",
                              style: TextStyle(color: Colors.white),
                            ),
                            // text
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                onTap: () {
                  print("Tapped on container");
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
