import 'package:flutter/material.dart';

class NavigationService {
  // استخدام GlobalKey لتحديد حالة الـ Navigator
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // دالة للتنقل إلى شاشة باستخدام اسمها
  static Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  // دالة للتنقل إلى شاشة و إزالة كل الشاشات السابقة
  static Future<dynamic> navigateAndRemoveUntil(String routeName) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(routeName, (route) => false);
  }

  // دالة للرجوع إلى الشاشة السابقة
  static Future<bool> goBack() {
    return navigatorKey.currentState!.maybePop();
  }
}
