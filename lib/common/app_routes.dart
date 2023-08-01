import 'package:flexischool/screens/assignment.dart';
import 'package:flexischool/screens/assignmentform.dart';
import 'package:flexischool/screens/calendarassignment.dart';
import 'package:flexischool/screens/notification.dart';
import 'package:flutter/material.dart';
import '../screens/home.dart';
import '../screens/loader.dart';
import '../screens/login.dart';
import '../main.dart';
import '../screens/schoolurl.dart';
import '../screens/dashboard.dart';
import '../screens/check_internet.dart';

Map<String, WidgetBuilder> routes = {
  "/": (context) => const LoaderRoute(),
  "/checkInternet": (context) => const CheckInternet(),
  "/home": (context) => const Home(),
  "/schoolUrl": (context) => const Schoolurl(),
  "/login": (context) => const LoginRoute(),
  "/dashboard": (context) => const Dashboard(),
  "/assignment1": (context) => const Assignment(),
  "/assignment":(context) => AssignmentForm(),
  "/notificationAssignment":(context) => NotificationAssignment(),
  //"/calendarAssignment":(context) => CalendarAssignment(onDateSelected: (DateTime ) {  },),

};