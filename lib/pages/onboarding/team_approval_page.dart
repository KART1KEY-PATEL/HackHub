import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/utils/text_util.dart';

class TeamApprovalPage extends StatefulWidget {
  final String teamName;

  const TeamApprovalPage({super.key, required this.teamName});

  @override
  State<TeamApprovalPage> createState() => _TeamApprovalPageState();
}

class _TeamApprovalPageState extends State<TeamApprovalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Approval Pending")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("teams")
            .doc(widget.teamName)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("Team not found."));
          }

          var teamData = snapshot.data!;
          bool isRegistered = teamData["registered"] ?? false;

          if (isRegistered) {
            Future.microtask(() {
              Navigator.pushReplacementNamed(context, '/participantBase');
            });
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hourglass_empty, size: 80, color: Colors.orange),
                SizedBox(height: 20),
                txt(
                  "Waiting for approval...",
                  // style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                txt(
                  "Your team is awaiting registration approval. Please wait.",
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
