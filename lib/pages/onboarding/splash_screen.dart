import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    await Future.delayed(const Duration(seconds: 3)); // Show splash for 3 sec

    var userBox = Hive.box<UserModel>('userBox');
    bool isUserLoggedIn = userBox.isNotEmpty; // Check if user exists

    if (isUserLoggedIn) {
      UserModel currentUser = userBox.get("currentUser")!;
      String userType = currentUser.userType;
      String userId = currentUser.id; // Get the User's ID

      if (userType == "participant") {
        await _fetchAndStoreTeamName(userId);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ParticipantBase()),
        );
      } else if (userType == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminBase()),
        );
      } else if (userType == "volunteer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VolunteerBase()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserTypeChoose()),
      );
    }
  }

  /// Fetch and Store Team Name in Hive
  Future<void> _fetchAndStoreTeamName(String userId) async {
    var teamBox = Hive.box('teamBox'); // Open Hive box for storing team name

    try {
      QuerySnapshot teamsSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('teamLeaderId', isEqualTo: userId)
          .get();

      if (teamsSnapshot.docs.isNotEmpty) {
        // User is a team leader
        String teamName = teamsSnapshot.docs.first.id;
        teamBox.put('teamName', teamName);
        return;
      }

      // If not a team leader, check team members array
      QuerySnapshot teamMemberSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('teamMembers', arrayContains: userId)
          .get();

      if (teamMemberSnapshot.docs.isNotEmpty) {
        // User is found in the teamMembers array
        String teamName = teamMemberSnapshot.docs.first.id;
        teamBox.put('teamName', teamName);
      }
    } catch (e) {
      print("Error fetching team name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24), // Dark background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/splash_logo.png", height: 120), // App Logo
            const SizedBox(height: 20),
            const Text(
              "Hack-N-Droid",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
                color: Color(0xFF4362FF)), // Loading Indicator
          ],
        ),
      ),
    );
  }
}
