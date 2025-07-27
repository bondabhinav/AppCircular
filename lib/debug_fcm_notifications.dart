import 'dart:developer' as developer;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMNotificationDebugger {
  static final FCMNotificationDebugger _instance = FCMNotificationDebugger._internal();
  
  factory FCMNotificationDebugger() {
    return _instance;
  }
  
  FCMNotificationDebugger._internal();

  /// Initialize FCM debugging
  static void initialize() {
    _instance._setupDebugListeners();
  }

  void _setupDebugListeners() {
    // Listen to all FCM events and log them
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      logNotification('FOREGROUND', message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      logNotification('OPENED_APP', message);
    });

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);
  }

  /// Log notification details
  static void logNotification(String type, RemoteMessage message) {
    final logData = _formatNotificationData(type, message);
    
    // Print to console
    debugPrint(logData);
    
    // Also log to developer console for better debugging
    developer.log(logData, name: 'FCM_NOTIFICATION');
    
    // If you want to save to file or send to analytics, you can add that here
  }

  /// Format notification data for logging
  static String _formatNotificationData(String type, RemoteMessage message) {
    final buffer = StringBuffer();
    buffer.writeln('🔔 ===== FCM NOTIFICATION ($type) =====');
    buffer.writeln('📱 Timestamp: ${DateTime.now().toIso8601String()}');
    buffer.writeln('🆔 Message ID: ${message.messageId ?? 'N/A'}');
    buffer.writeln('📊 Message Type: ${message.messageType ?? 'N/A'}');
    buffer.writeln('📤 From: ${message.from ?? 'N/A'}');
    buffer.writeln('⏰ Sent Time: ${message.sentTime ?? 'N/A'}');
    buffer.writeln('⏱️ TTL: ${message.ttl ?? 'N/A'}');
    
    // Log notification payload
    if (message.notification != null) {
      buffer.writeln('📢 Notification:');
      buffer.writeln('  📝 Title: ${message.notification!.title ?? 'N/A'}');
      buffer.writeln('  📄 Body: ${message.notification!.body ?? 'N/A'}');
      
      if (message.notification!.android != null) {
        buffer.writeln('  🤖 Android:');
        buffer.writeln('    🔊 Sound: ${message.notification!.android!.sound ?? 'N/A'}');
        buffer.writeln('    🏷️ Tag: ${message.notification!.android!.tag ?? 'N/A'}');
        buffer.writeln('    🎨 Color: ${message.notification!.android!.color ?? 'N/A'}');
        buffer.writeln('    📱 Channel ID: ${message.notification!.android!.channelId ?? 'N/A'}');
        buffer.writeln('    🖼️ Image URL: ${message.notification!.android!.imageUrl ?? 'N/A'}');
      }
      
      if (message.notification!.apple != null) {
        buffer.writeln('  🍎 Apple:');
        buffer.writeln('    🔊 Sound: ${message.notification!.apple!.sound ?? 'N/A'}');
        buffer.writeln('    🏷️ Badge: ${message.notification!.apple!.badge ?? 'N/A'}');
        buffer.writeln('    🖼️ Image URL: ${message.notification!.apple!.imageUrl ?? 'N/A'}');
      }
    }
    
    // Log data payload
    if (message.data.isNotEmpty) {
      buffer.writeln('📦 Data Payload:');
      message.data.forEach((key, value) {
        buffer.writeln('  🔑 $key: $value');
      });
    } else {
      buffer.writeln('📦 Data Payload: Empty');
    }
    
    buffer.writeln('🔔 ===== END FCM NOTIFICATION =====');
    return buffer.toString();
  }

  /// Background message handler for debugging
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    logNotification('BACKGROUND', message);
  }

  /// Print all current FCM settings
  static Future<void> printFCMSettings() async {
    final buffer = StringBuffer();
    buffer.writeln('⚙️ ===== FCM SETTINGS =====');
    
    try {
      final token = await FirebaseMessaging.instance.getToken();
      buffer.writeln('🔑 FCM Token: $token');
    } catch (e) {
      buffer.writeln('🔑 FCM Token: Error getting token - $e');
    }
    
    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      buffer.writeln('📱 Authorization Status: ${settings.authorizationStatus}');
      buffer.writeln('🔔 Alert Setting: ${settings.alert}');
      buffer.writeln('🔊 Sound Setting: ${settings.sound}');
      buffer.writeln('🏷️ Badge Setting: ${settings.badge}');
      buffer.writeln('🚨 Critical Alert: ${settings.criticalAlert}');
      buffer.writeln('📢 Announcement: ${settings.announcement}');
    } catch (e) {
      buffer.writeln('📱 Settings: Error getting settings - $e');
    }
    
    buffer.writeln('⚙️ ===== END FCM SETTINGS =====');
    
    debugPrint(buffer.toString());
    developer.log(buffer.toString(), name: 'FCM_SETTINGS');
  }

  /// Get a summary of notification types received
  static void printNotificationTypesSummary() {
    // This would be enhanced with actual tracking if needed
    debugPrint('📊 ===== NOTIFICATION TYPES SUMMARY =====');
    debugPrint('📚 Expected types in this app:');
    debugPrint('  • ASSIGNMENT - Assignment notifications');
    debugPrint('  • CIRCULAR - Circular notifications');
    debugPrint('  • ATTENDANCE - Attendance notifications');
    debugPrint('  • Fees - Fee payment notifications');
    debugPrint('📊 ===== END SUMMARY =====');
  }
} 