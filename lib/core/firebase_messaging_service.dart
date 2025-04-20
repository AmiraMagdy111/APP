import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/navigation_service.dart';

class FirebaseMessagingService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // تهيئة الإشعارات
  static Future<void> initialize() async {
    try {
      // Request notification permissions
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        print('User declined or has not accepted notification permissions');
        return;
      }

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        ),
      );

      // Initialize notifications
      await _notificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) async {
          if (response.payload != null) {
            _handleNotificationNavigation(response.payload!);
          }
        },
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (message.notification != null) {
          _showNotification(
            message.notification!.title ?? 'ALERT',
            message.notification!.body ?? 'Fire!!!',
            payload: message.data['route'] ?? '/alert_fire',
          );
        }
      });

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (message.notification != null) {
          _handleNotificationNavigation(message.data['route'] ?? '/alert_fire');
        }
      });

      // Get FCM token
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

    } catch (e) {
      print('Error initializing Firebase Messaging: $e');
    }
  }

  // Handle notification navigation
  static void _handleNotificationNavigation(String route) {
    try {
      NavigationService.navigateTo(route);
    } catch (e) {
      print('Error navigating to route $route: $e');
    }
  }

  // Show local notification
  static Future<void> _showNotification(
    String title,
    String body, {
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'fire_alerts_channel',
        'Fire Alerts',
        channelDescription: 'تنبيهات الطوارئ والحرائق',
        importance: Importance.max,
        priority: Priority.high,
        color: Colors.red,
        playSound: true,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notificationsPlugin.show(
        0,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Check initial message
  static Future<void> checkInitialMessage() async {
    try {
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null && initialMessage.notification != null) {
        _handleNotificationNavigation(
            initialMessage.data['route'] ?? '/alert_fire');
      }
    } catch (e) {
      print('Error checking initial message: $e');
    }
  }
}