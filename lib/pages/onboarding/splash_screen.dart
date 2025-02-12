import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hacknow/pages/admin/admin_base/admin_base.dart';
import 'package:hacknow/pages/onboarding/approval_page.dart';
import 'package:hacknow/pages/volunteer/volunteer_base/volunteer_base.dart';
import 'package:hive/hive.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/pages/onboarding/user_type.dart';
import 'package:hacknow/pages/participants/paticipants_base/paticipants_base.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(Duration(seconds: 3)); // Show splash for 3 seconds

    var userBox = Hive.box<UserModel>('userBox');
    bool isUserLoggedIn = userBox.isNotEmpty; // Check if user data exists
    if (isUserLoggedIn) {
      String userType = userBox.get("currentUser")!.userType;
      if (userType == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminBase(),
          ),
        ); // Home Page
      }
      if (userType == "volunteer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VolunteerBase(),
          ),
        ); // Home Page
      }
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => UserTypeChoose())); // Login Page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A24), // Dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/splash_logo.png", height: 120), // App Logo
            SizedBox(height: 20),
            Text(
              "Hack-N-Droid",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
                color: Color(0xFF4362FF)), // Loading Indicator
          ],
        ),
      ),
    );
  }
}
