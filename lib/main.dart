import 'package:flutter/material.dart';
import 'package:intern_app/pages/home.dart';
import 'package:intern_app/pages/login.dart';
import 'package:intern_app/pages/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashScreen(),
    },
  ));
}
