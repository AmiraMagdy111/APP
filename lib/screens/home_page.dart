import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _fcmToken;

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      setState(() {
        _fcmToken = token;
      });

     // print("🔑 FCM Token: $token");

      // لو عايزة تخزنيه في Firestore مثلاً، ممكن هنا.
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     // print("🔔 Foreground notification: ${message.notification?.title}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الرئيسية")),
      body: Center(
        child: Text(_fcmToken != null
            ? "Your FCM token:\n$_fcmToken"
            : "جاري الحصول على رمز FCM..."),
      ),
    );
  }
}
