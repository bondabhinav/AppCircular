import 'package:flutter/material.dart';

/// AuthMiddleware provides a global navigator key for navigation outside of widget context
/// This is primarily used for FCM navigation and API error handling
class AuthMiddleware {
  /// Global navigator key for navigation outside of widget context
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Private constructor to prevent instantiation
  AuthMiddleware._();
}
