import 'package:flexischool/screens/student/student_dashboard_screen.dart';
import 'package:flutter/material.dart';

import '../screens/check_internet.dart';
import '../screens/dashboard.dart';
import '../screens/home.dart';
import '../screens/loader.dart';
import '../screens/login.dart';
import '../screens/schoolurl.dart';

Map<String, WidgetBuilder> routes = {
  "/": (context) => const LoaderRoute(),
  "/checkInternet": (context) => const CheckInternet(),
  "/home": (context) => const Home(),
  "/schoolUrl": (context) => const Schoolurl(),
  "/login": (context) => const LoginRoute(),
  "/dashboard": (context) => const Dashboard(),
  "/studentDashboard": (context) => const StudentDashboardScreen()
};
