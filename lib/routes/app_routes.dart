import 'package:flutter/material.dart';
import 'package:asas/pages/login_page.dart';
import 'package:asas/pages/register_page.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(),
    register: (context) => RegisterPage(),
  };
}
