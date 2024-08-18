import 'package:flutter/material.dart';
import 'package:intern_app/pages/home.dart';
import 'package:intern_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay for the splash screen
    Future.delayed(const Duration(seconds: 3), () {
      checkIsAuth();
    });
  }

  Future<void> checkIsAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isAuth = prefs.getBool("isAuth");
    var token = prefs.getString("token");

    if (isAuth == true && token != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 237, 238, 240), // Customize the background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your splash screen image or widget here
            Image.asset(
              'assets/logoo.png', // Replace with your image asset
              height: 200.0,
              width: 200.0,
            ),
            const SizedBox(height: 20.0),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
            const SizedBox(height: 20.0),
            const Text(
              "Loading...",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
