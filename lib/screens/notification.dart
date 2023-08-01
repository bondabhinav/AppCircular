import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
class NotificationModel {
  final int id;
  final String title;
  final String subtitle;
  final DateTime date;
  final String description;
  bool isRead;

  NotificationModel({required this.id, required this.title, required this.subtitle, required this.date, required this.description,this.isRead = false});
}

class CalendarPage extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  CalendarPage({required this.onDateSelected});

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Date'),
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: DateTime.now(),
        calendarFormat: _calendarFormat,
        headerStyle: HeaderStyle(
          formatButtonVisible : false,
          titleCentered: true,
        ),
        onDaySelected: (date, _) {
          onDateSelected(date);
          Navigator.pop(context); // Navigate back to the previous screen
        },
      ),
    );
  }
}

class NotificationAssignment extends StatefulWidget {
  const NotificationAssignment({Key? key}) : super(key: key);

  @override
  State<NotificationAssignment> createState() => _NotificationAssignmentState();
}

class _NotificationAssignmentState extends State<NotificationAssignment> {
  DateTime? selectedDate; // Newly added
  List<NotificationModel> filteredNotifications = []; // Newly added

  List<NotificationModel> notifications = [
    NotificationModel(id: 1, title: 'Notification 1', subtitle: 'Subtitle 1', date: DateTime.now(),description:'Notification 1'),
    //NotificationModel(id: 2, title: 'Notification 2', subtitle: 'Subtitle 2', date: DateTime.now(),description:'Notification 2'),
    NotificationModel(id: 3, title: 'Notification 3', subtitle: 'Subtitle 3', date: DateTime.now(),description:'Notification 3'),
    NotificationModel(id: 3, title: 'Notification 4', subtitle: 'Subtitle 4', date: (DateTime.now()).add(const Duration(days: 1)),description:'Notification 3', isRead: true),

  ];
  int? hoveredNotificationId;
  @override
  void initState() {
    super.initState();
    print(notifications);
    //fetchNotifications();
  }

  void fetchNotifications() async {
    final url = 'https://example.com/api/notifications'; // Replace with your API endpoint
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        notifications = List<NotificationModel>.from(data.map((notification) => NotificationModel(
          id: notification['id'],
          title: notification['title'],
          subtitle: notification['subtitle'],
          date: DateTime.parse(notification['date']),
          description: notification['description'],
        )));
      });
    } else {
      // Handle error
      print('Failed to fetch notifications');
    }
  }

  void onDateSelected(DateTime date) {


    setState(() {
      selectedDate =DateTime(date.year, date.month, date.day);
    });
  }

  List<NotificationModel> getFilteredNotifications() {
    if (selectedDate == null) {
      return notifications;
    }

    return notifications.where((notification) {
      final notificationDate = DateTime(
        notification.date.year,
        notification.date.month,
        notification.date.day,
      );

      return notificationDate == selectedDate;
    }).toList();
  }


  // void onDateSelected(DateTime date) {
  //   print(date);
  //
  //   print(notifications);
  //
  //   setState(() {
  //     selectedDate = date;
  //     filteredNotifications = notifications.where((notification) {
  //       final notificationDate = DateTime(
  //         notification.date.year,
  //         notification.date.month,
  //         notification.date.day,
  //       );
  //       return notificationDate == selectedDate;
  //     }).toList();
  //   });
  // }


  @override
  Widget build(BuildContext context) {

    final notifications = getFilteredNotifications();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/dashboard');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Notifications'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarPage(
                      onDateSelected: onDateSelected,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body:  notifications.isNotEmpty
            ? ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            final isHovered = notification.id == hoveredNotificationId;

            final color = notification.isRead ? Colors.grey[300] : Colors.white;

            return MouseRegion(
              onEnter: (_) {
                setState(() {
                  hoveredNotificationId = notification.id;
                });
              },
              onExit: (_) {
                setState(() {
                  hoveredNotificationId = null;
                });
              },
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailedPage(notification: notification),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: isHovered ? 4.0 : 2.0,
                    //color: isHovered ? Colors.blue[50] : null,
                    color: color,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(notification.subtitle),
                                SizedBox(height: 4.0),
                                Text(DateFormat('dd/MM/yyyy').format(notification.date!)),
                              ],
                            ),
                          ),
                          Text(notification.date.toString()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        )
              : Center(
          child: Text('No notifications found for the selected date.'),
    ),
      ),
    );
  }
}

class DetailedPage extends StatelessWidget {
  final NotificationModel notification;

  DetailedPage({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              notification.subtitle,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${notification.date.toString()}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),
            Text(
              notification.description,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
