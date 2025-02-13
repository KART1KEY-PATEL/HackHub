import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/pages/admin/admin_base/admin_base.dart';
import 'package:hacknow/pages/onboarding/approval_page.dart';
import 'package:hacknow/pages/participants/paticipants_base/paticipants_base.dart';
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
  UserModel? currentUser;
  String? teamName;
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load user data from Hive storage
  Future<void> _loadUserData() async {
    var userBox = Hive.box<UserModel>('userBox');

    if (userBox.isNotEmpty) {
      currentUser = userBox.get("currentUser");

      if (currentUser != null) {
        print("User Type: ${currentUser!.userType}");

        if (currentUser!.userType == "participant") {
          print("Fetching team for: ${currentUser!.id}");
          await _fetchTeamName(currentUser!.id);
        }
      }
    }

    setState(() => isLoading = false); // Update state after fetching data
  }

  /// Fetch the participant's team name
  Future<void> _fetchTeamName(String userId) async {
    try {
      print("Fetching team name for User ID: $userId");

      // Check if the user is a Team Leader
      QuerySnapshot teamLeaderSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('teamLeaderId', isEqualTo: userId)
          .get();

      if (teamLeaderSnapshot.docs.isNotEmpty) {
        setState(() {
          teamName = teamLeaderSnapshot.docs.first.id;
        });
        return;
      }

      // Check if the user is a Team Member
      QuerySnapshot teamMemberSnapshot = await FirebaseFirestore.instance
          .collection('teams')
          .where('teamMembers', arrayContains: userId)
          .get();

      if (teamMemberSnapshot.docs.isNotEmpty) {
        setState(() {
          teamName = teamMemberSnapshot.docs.first.id;
        });
      }
    } catch (e) {
      print("Error fetching team name: $e");
    }
  }

  /// Navigate user to the correct page based on user type
  void _navigateToUserDashboard() {
    if (currentUser == null) return;

    Future.microtask(() {
      if (currentUser!.userType == "admin") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminBase()),
        );
      } else if (currentUser!.userType == "volunteer") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VolunteerBase()),
        );
      } else if (currentUser!.userType == "participant" && teamName == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserTypeChoose()),
        );
      }
    });
  }

  /// Navigate user to login page
  void _navigateToLogin() {
    Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UserTypeChoose()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1️⃣ Show loading screen while data is being fetched
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A24),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4362FF)),
        ),
      );
    }

    // 2️⃣ If no user is found, navigate to login
    if (currentUser == null) {
      Future.microtask(() => _navigateToLogin());
      return Scaffold(backgroundColor: const Color(0xFF1A1A24));
    }

    // 3️⃣ If the user is NOT a participant OR has no team, navigate accordingly
    if (currentUser!.userType != "participant" || teamName == null) {
      Future.microtask(() => _navigateToUserDashboard());
      return Scaffold(backgroundColor: const Color(0xFF1A1A24));
    }

    // 4️⃣ Show StreamBuilder only for participants with a team
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A24),
      body: Center(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('teams')
              .doc(teamName)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(color: Color(0xFF4362FF));
            }

            if (snapshot.hasError) {
              return Text("Error loading team data",
                  style: TextStyle(color: Colors.white));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Text("Team data not found",
                  style: TextStyle(color: Colors.white));
            }

            bool isRegistered = snapshot.data!['registered'] ?? false;

            // Navigate based on the team's registration status
            Future.microtask(() {
              if (!isRegistered) {
                Navigator.pushReplacementNamed(
                  context,
                  '/teamDetails',
                  arguments: {"teamName": teamName},
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ParticipantBase()),
                );
              }
            });

            return SizedBox(); // UI placeholder before navigation
          },
        ),
      ),
    );
  }
}
