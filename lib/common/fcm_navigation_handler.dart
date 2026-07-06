import 'package:flutter/material.dart';
import 'package:flexischool/common/auth_middleware.dart';
import 'package:flexischool/screens/assignment_detail_screen.dart';
import 'package:flexischool/screens/dashboard.dart';
import 'package:flexischool/screens/home.dart';
import 'package:flexischool/screens/login.dart';
import 'package:flexischool/screens/schoolurl.dart';
import 'package:flexischool/screens/student/fee_screen.dart';
import 'package:flexischool/screens/student/student_circular_detail_screen.dart';
import 'package:flexischool/screens/student/student_dashboard_screen.dart';
import 'package:flexischool/screens/student/student_notification_screen.dart';
import 'package:flexischool/screens/student/student_attendance_graph_screen.dart';
import 'package:flexischool/screens/student/academic_calender_screen.dart';
import 'package:flexischool/screens/student/student_assignment_screen.dart';
import 'package:flexischool/screens/student/student_circular.dart';

class FCMNavigationHandler {
  /// Map FCM PAGE values to screen widgets
  static final Map<String, Widget Function()> _pageToScreenMap = {
    'DASHBOARD': () => const Dashboard(),
    'STUDENT_DASHBOARD': () => const StudentDashboardScreen(),
    'HOME': () => const Home(),
    'LOGIN': () => const LoginRoute(),
    'SCHOOL_URL': () => const Schoolurl(),
    // Add more as needed
  };

  /// Map FCM PAGE values to screen widgets with parameters
  static final Map<String, Widget Function(Map<String, dynamic>)>
  _pageToWidgetMap = {
    'FEES': (data) => const FeeScreen(),
    'NOTIFICATION': (data) => const StudentNotificationScreen(),
    'ATTENDANCE': (data) => const StudentAttendanceGraphScreen(),
    'ACADEMIC': (data) => const AcademicCalenderScreen(),
    'ASSIGNMENT': (data) => _buildAssignmentScreen(data),
    'CIRCULAR': (data) => _buildCircularScreen(data),
    'ASSIGNMENTS': (data) => StudentAssignmentCalenderWithList(
      employeeId: int.tryParse(data['EMPLOYEE_ID']?.toString() ?? '0') ?? 0,
    ),
    'CIRCULARS': (data) => const StudentCircularScreen(),
    // Add more screens as needed
  };

  /// Handle FCM navigation dynamically
  static void handleFCMNavigation(Map<String, dynamic> fcmData) {
    final String? page = fcmData['PAGE']?.toString();
    final String? type = fcmData['TYPE']?.toString();

    debugPrint("=== FCM NAVIGATION HANDLER ===");
    debugPrint("PAGE: $page");
    debugPrint("TYPE: $type");
    debugPrint("FCM Data: $fcmData");
    debugPrint(
      "Navigator Context Available: ${AuthMiddleware.navigatorKey.currentContext != null}",
    );
    debugPrint(
      "Navigator State Available: ${AuthMiddleware.navigatorKey.currentState != null}",
    );

    if (page == null || page.isEmpty) {
      debugPrint("No PAGE specified, falling back to TYPE-based navigation");
      _handleLegacyNavigation(fcmData);
      return;
    }

    // First try direct screen navigation
    if (_pageToScreenMap.containsKey(page.toUpperCase())) {
      final screenBuilder = _pageToScreenMap[page.toUpperCase()]!;
      final widget = screenBuilder();
      debugPrint("Navigating to screen: ${widget.runtimeType}");

      if (AuthMiddleware.navigatorKey.currentContext != null) {
        Navigator.push(
          AuthMiddleware.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => widget),
        );
        debugPrint("=== END FCM NAVIGATION ===");
        return;
      } else {
        debugPrint("Navigator context not available, retrying in 500ms...");
        Future.delayed(const Duration(milliseconds: 500), () {
          handleFCMNavigation(fcmData);
        });
        return;
      }
    }

    // Then try widget-based navigation
    if (_pageToWidgetMap.containsKey(page.toUpperCase())) {
      final widgetBuilder = _pageToWidgetMap[page.toUpperCase()]!;
      final widget = widgetBuilder(fcmData);

      debugPrint("Navigating to widget: ${widget.runtimeType}");

      if (AuthMiddleware.navigatorKey.currentContext != null) {
        Navigator.push(
          AuthMiddleware.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => widget),
        );
        debugPrint("=== END FCM NAVIGATION ===");
        return;
      } else {
        debugPrint("Navigator context not available, retrying in 500ms...");
        Future.delayed(const Duration(milliseconds: 500), () {
          handleFCMNavigation(fcmData);
        });
        return;
      }
    }

    // Fallback to TYPE-based navigation for backward compatibility
    debugPrint("PAGE '$page' not found, falling back to TYPE-based navigation");
    _handleLegacyNavigation(fcmData);
  }

  /// Legacy navigation based on TYPE field (for backward compatibility)
  static void _handleLegacyNavigation(Map<String, dynamic> fcmData) {
    final String? type = fcmData['TYPE']?.toString();

    debugPrint("Legacy navigation for TYPE: $type");

    switch (type?.toUpperCase()) {
      case 'ASSIGNMENT':
        if (fcmData['SESSION_ID'] != null &&
            fcmData['APP_ASSIGNMENT_ID'] != null &&
            fcmData['NOTIFICATION_ID'] != null) {
          Navigator.push(
            AuthMiddleware.navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => AssignmentDetailScreen(
                sessionId: int.parse(fcmData['SESSION_ID'].toString()),
                assignmentId: int.parse(
                  fcmData['APP_ASSIGNMENT_ID'].toString(),
                ),
                notificationId: int.parse(
                  fcmData['NOTIFICATION_ID'].toString(),
                ),
              ),
            ),
          );
        }
        break;

      case 'CIRCULAR':
        if (fcmData['SESSION_ID'] != null &&
            fcmData['APP_CIRCULAR_ID'] != null &&
            fcmData['NOTIFICATION_ID'] != null) {
          Navigator.push(
            AuthMiddleware.navigatorKey.currentContext!,
            MaterialPageRoute(
              builder: (context) => StudentCircularDetailScreen(
                sessionId: int.parse(fcmData['SESSION_ID'].toString()),
                id: int.parse(fcmData['APP_CIRCULAR_ID'].toString()),
                notificationId: int.parse(
                  fcmData['NOTIFICATION_ID'].toString(),
                ),
              ),
            ),
          );
        }
        break;

      case 'ATTENDANCE':
        Navigator.push(
          AuthMiddleware.navigatorKey.currentContext!,
          MaterialPageRoute(
            builder: (context) => const StudentNotificationScreen(),
          ),
        );
        break;

      case 'FEES':
        Navigator.push(
          AuthMiddleware.navigatorKey.currentContext!,
          MaterialPageRoute(builder: (context) => const FeeScreen()),
        );
        break;

      default:
        debugPrint("Unknown TYPE: $type, no navigation performed");
        break;
    }
  }

  /// Build assignment screen with parameters
  static Widget _buildAssignmentScreen(Map<String, dynamic> data) {
    if (data['SESSION_ID'] != null &&
        data['APP_ASSIGNMENT_ID'] != null &&
        data['NOTIFICATION_ID'] != null) {
      return AssignmentDetailScreen(
        sessionId: int.parse(data['SESSION_ID'].toString()),
        assignmentId: int.parse(data['APP_ASSIGNMENT_ID'].toString()),
        notificationId: int.parse(data['NOTIFICATION_ID'].toString()),
      );
    }
    // Fallback to assignment list if no specific assignment
    return StudentAssignmentCalenderWithList(
      employeeId: int.tryParse(data['EMPLOYEE_ID']?.toString() ?? '0') ?? 0,
    );
  }

  /// Build circular screen with parameters
  static Widget _buildCircularScreen(Map<String, dynamic> data) {
    if (data['SESSION_ID'] != null &&
        data['APP_CIRCULAR_ID'] != null &&
        data['NOTIFICATION_ID'] != null) {
      return StudentCircularDetailScreen(
        sessionId: int.parse(data['SESSION_ID'].toString()),
        id: int.parse(data['APP_CIRCULAR_ID'].toString()),
        notificationId: int.parse(data['NOTIFICATION_ID'].toString()),
      );
    }
    // Fallback to circular list if no specific circular
    return const StudentCircularScreen();
  }

  /// Add new PAGE to route mapping
  static void addPageRoute(String page, String route) {
    // This would be used to dynamically add routes if needed
    debugPrint("Adding page route: $page -> $route");
  }

  /// Add new PAGE to widget mapping
  static void addPageWidget(
    String page,
    Widget Function(Map<String, dynamic>) widgetBuilder,
  ) {
    // This would be used to dynamically add widget builders if needed
    debugPrint("Adding page widget: $page -> ${widgetBuilder.runtimeType}");
  }

  /// Get available pages for debugging
  static List<String> getAvailablePages() {
    final screens = _pageToScreenMap.keys.toList();
    final widgets = _pageToWidgetMap.keys.toList();
    return [...screens, ...widgets];
  }

  /// Print navigation mapping for debugging
  static void printNavigationMapping() {
    debugPrint("=== FCM NAVIGATION MAPPING ===");
    debugPrint("Available Screens:");
    _pageToScreenMap.forEach((page, screenBuilder) {
      debugPrint("  $page -> ${screenBuilder.runtimeType}");
    });

    debugPrint("Available Widgets:");
    _pageToWidgetMap.forEach((page, builder) {
      debugPrint("  $page -> ${builder.runtimeType}");
    });
    debugPrint("=== END NAVIGATION MAPPING ===");
  }
}
