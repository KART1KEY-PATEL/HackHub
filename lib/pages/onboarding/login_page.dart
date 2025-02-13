import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/controller/user_controller.dart';
import 'package:hacknow/services/backend_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class TeamLeaderPage extends StatelessWidget {
  TeamLeaderPage({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Backendservice _backendservice = Backendservice();
  final TextEditingController teamNameController = TextEditingController();
  final Box teamBox = Hive.box('teamBox'); // Open Hive Box

  @override
  Widget build(BuildContext context) {
    UserController userController =
        Provider.of<UserController>(context, listen: false);

    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: customAppBar(
        title: "Login",
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(sW * 0.04),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    txt(
                      "Team Name",
                      size: sW * 0.038,
                      weight: FontWeight.w600,
                    ),
                    txt("(Enter the exact same team name submitted on VIT Chennai Events)",
                        size: sW * 0.035, color: CustomColor.accentTextColor),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: teamNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText:
                            '(Enter the exact same team name submitted on VIT Chennai Events)',
                      ),
                    ),
                    SizedBox(height: sH * 0.02),
                  ],
                ),
              ),
            ),
            NextButton(
              title: "Start",
              onTapFunction: () async {
                String enteredTeamName = teamNameController.text.trim();

                if (enteredTeamName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a team name")),
                  );
                  return;
                }

                // Check if team name exists in Firestore
                DocumentSnapshot teamDoc = await _firestore
                    .collection("teams")
                    .doc(enteredTeamName)
                    .get();

                if (teamDoc.exists) {
                  // Store the team name in Hive
                  teamBox.put('teamName', enteredTeamName);

                  // If the team exists, proceed to the next screen
                  Navigator.pushReplacementNamed(context, '/teamRegisterPage',
                      arguments: {
                        "teamName": enteredTeamName,
                      });
                } else {
                  // If the team does not exist, show an error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Invalid team name. Please check and try again.")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
