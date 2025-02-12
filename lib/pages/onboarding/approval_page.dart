import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/pages/participants/paticipants_base/paticipants_base.dart';
import 'package:hacknow/pages/volunteer/volunteer_base/volunteer_base.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';

class ApprovalPage extends StatefulWidget {
  const ApprovalPage({super.key});

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
  String? userId; // Make it nullable

  @override
  void initState() {
    super.initState();
    _getUserId();
  }

  Future<void> _getUserId() async {
    var userBox = await Hive.openBox<UserModel>('userBox');
    if (userBox.containsKey("currentUser")) {
      setState(() {
        userId = userBox.get("currentUser")?.id;
        print("User Id: ${userId}");
      });
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      // Check for null
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Approval Status"),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId) // Safe access
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "User not found. Please contact support.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          if (userData["approved"] == true) {
            if (userData['userType'] == "volunteer") {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => VolunteerBase()),
                );
              });
            } else {
              Future.microtask(() {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ParticipantBase()),
                );
              });
            }
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, size: 80, color: Colors.blueAccent),
                SizedBox(height: 20),
                txt(
                  "Waiting for Approval...",
                ),
                SizedBox(height: 10),
                txt(
                  "Your registration is under review. Please wait until it is approved.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      ),
    );
  }
}
