import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/services/backend_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hacknow/model/user_model.dart';

class VolunteerRegistrationDeskPage extends StatefulWidget {
  const VolunteerRegistrationDeskPage({super.key});

  @override
  State<VolunteerRegistrationDeskPage> createState() =>
      _VolunteerRegistrationDeskPageState();
}

class _VolunteerRegistrationDeskPageState
    extends State<VolunteerRegistrationDeskPage> {
  String? generatedUUID;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? currentUserId;
  List<String> teamMembers = [];
  List<String> teamMemberEmails = []; // Store email addresses
  Map<String, bool> checkboxStatesIOS = {}; // Stores IOS User Checkbox states
  Map<String, bool> checkboxStatesAttendance = {};

  String? assignedTeamName;
  Backendservice _backendservice = Backendservice();
  Map<String, bool> checkboxStates = {}; // Store checkbox states

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    var userBox = await Hive.openBox<UserModel>('userBox');
    setState(() {
      currentUserId = userBox.get("currentUser")?.id;
    });
  }

  Future<void> generateQRCode() async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error: User not found!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    String newUUID = Uuid().v4();

    try {
      await _firestore.collection("registrationQR").doc(newUUID).set({
        "generatedBy": currentUserId,
        "teamName": "",
        "timestamp": FieldValue.serverTimestamp(),
      });

      setState(() {
        generatedUUID = newUUID;
        assignedTeamName = null;
        teamMembers = [];
        checkboxStates = {};
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ QR Code Generated & Stored in Firestore!"),
          backgroundColor: Colors.greenAccent,
        ),
      );
    } catch (e) {
      print("🔥 Error storing QR Code in Firestore: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Error saving QR Code. Try again."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> fetchTeamMembers() async {
    if (assignedTeamName != null && assignedTeamName!.isNotEmpty) {
      try {
        Map<String, String> members =
            await _backendservice.fetchTeamMembers(assignedTeamName!);

        setState(() {
          teamMembers = members.keys.toList(); // Store Names
          teamMemberEmails = members.values.toList(); // Store Emails
          checkboxStates = {for (var member in members.keys) member: false};
        });
      } catch (e) {
        print("Error fetching team members: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Error fetching team members."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _updateRegistrationStatus() async {
    if (checkboxStates.values.every((isChecked) => isChecked)) {
      await _firestore.collection("teams").doc(assignedTeamName).update({
        "registered": true,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✅ Team Registered Successfully!"),
          backgroundColor: Colors.greenAccent,
        ),
      );
    }
  }

  Future<void> markTeamRegistered() async {
    if (assignedTeamName == null) return;

    await _firestore.collection("teams").doc(assignedTeamName).update({
      "registered": true,
    });

    // Mark Attendance
    for (String email in teamMemberEmails) {
      String status = checkboxStatesAttendance[email] == true ? "P" : "A";
      await _backendservice.updateAttendance(email, status);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Team Registered Successfully!"),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(
        title: ("Volunteer Registration Desk"),
        // backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Generate a QR Code for Registration",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (generatedUUID != null)
                StreamBuilder<DocumentSnapshot>(
                  stream: _firestore
                      .collection("registrationQR")
                      .doc(generatedUUID)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return CircularProgressIndicator();
                    }

                    var qrData = snapshot.data!;

                    // Ensure we update assignedTeamName only after the build cycle
                    if (qrData.exists && qrData.data() != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          assignedTeamName = qrData["teamName"];
                        });
                      });
                    }

                    if (assignedTeamName != null &&
                        assignedTeamName!.isNotEmpty) {
                      return Column(
                        children: [
                          Icon(Icons.group,
                              size: 100, color: Colors.greenAccent),
                          const SizedBox(height: 10),
                          Text(
                            "✅ Team Assigned: $assignedTeamName",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          if (teamMembers.isNotEmpty)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    txt("Details"),
                                    Spacer(),
                                    txt(
                                      "IOS",
                                    ),
                                    SizedBox(
                                      width: sW * 0.08,
                                    ),
                                    txt("P"),
                                    SizedBox(
                                      width: sW * 0.06,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.35,
                                  child: ListView.separated(
                                    separatorBuilder: (context, index) =>
                                        SizedBox(height: sH * 0.02),
                                    shrinkWrap: true,
                                    itemCount: teamMembers.length,
                                    itemBuilder: (context, index) {
                                      String member = teamMembers[index];
                                      String email = teamMemberEmails[index];

                                      return Container(
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: CustomColor.secondaryColor,
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: sW * 0.5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  txt(member,
                                                      size: sW * 0.04,
                                                      maxLine: 1), // Name
                                                  txt(email,
                                                      size: sW * 0.03,
                                                      color: Colors.grey,
                                                      maxLine: 1), // Email
                                                ],
                                              ),
                                            ),
                                            Spacer(),

                                            // ✅ First Checkbox - IOS Users
                                            Checkbox(
                                              value: checkboxStatesIOS[email] ??
                                                  false,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  checkboxStatesIOS[email] =
                                                      value!;
                                                });
                                                _backendservice
                                                    .updateIOSUserStatus(
                                                        email, value!);
                                              },
                                            ),

                                            // ✅ Second Checkbox - Attendance
                                            Checkbox(
                                              value: checkboxStatesAttendance[
                                                      email] ??
                                                  false,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  checkboxStatesAttendance[
                                                      email] = value!;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await markTeamRegistered();
                                  },
                                  child: Text(
                                    "Mark Team Registered",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: fetchTeamMembers,
                            child: Text(
                              teamMembers.isEmpty
                                  ? "Fetch Team Members"
                                  : "Refresh Team Members",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        QrImageView(
                          data: generatedUUID!,
                          size: 200,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        SelectableText(
                          "UUID: $generatedUUID",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 20),
              // if (generatedUUID == null)
              GestureDetector(
                onTap: generateQRCode,
                child: Container(
                  decoration: BoxDecoration(
                    color: CustomColor.primaryButtonColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: sW * 0.08,
                    vertical: sH * 0.01,
                  ),
                  margin: EdgeInsets.symmetric(
                    horizontal: sW * 0.2,
                  ),
                  child: Text("Generate QR Code",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
