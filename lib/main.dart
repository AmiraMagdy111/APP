//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/permission_request_screen.dart';
import 'screens/auth_screen.dart';
//import 'screens/register_screen.dart';
import 'screens/home_page.dart';
//import 'screens/owner_dashboard_screen.dart';
import 'screens/alert_fire_screen.dart';
import 'core/firebase_messaging_service.dart';
import 'utils/navigation_service.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    await FirebaseMessagingService.initialize();
    await FirebaseMessagingService.checkInitialMessage();
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted =
          prefs.getBool('onboarding_completed') ?? false;
      final permissionsGranted = prefs.getBool('permissions_granted') ?? false;
      final isLoggedIn = prefs.getBool('logged_in') ?? false;

      if (!onboardingCompleted) {
        return const OnboardingScreen();
      } else if (!permissionsGranted) {
        return const PermissionRequestScreen();
      } else if (!isLoggedIn) {
        return const AuthScreen();
      } else {
        return const HomePage();
      }
    } catch (e) {
      print('Error getting initial screen: $e');
      return const SplashScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fire Alert App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: NavigationService.navigatorKey,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading app'));
          } else {
            return snapshot.data!;
          }
        },
      ),
      routes: {
        '/alert_fire': (context) => const FireAlertScreen(),
        '/home': (context) => const HomePage(),
        '/auth': (context) => const AuthScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/permissions': (context) => const PermissionRequestScreen(),
      },
    );
  }
}
