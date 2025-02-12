import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/services/backend_service.dart';
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
    print("QR Geneated");
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
        List<String> members =
            await _backendservice.fetchTeamMembers(assignedTeamName!);
        setState(() {
          teamMembers = members;
          checkboxStates = {for (var member in members) member: false};
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Volunteer Registration Desk"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
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
                        Icon(Icons.group, size: 100, color: Colors.greenAccent),
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
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.3,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: teamMembers.length,
                              itemBuilder: (context, index) {
                                String member = teamMembers[index];
                                return ListTile(
                                  title: Text(
                                    member,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  trailing: Checkbox(
                                    value: checkboxStates[member] ?? false,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkboxStates[member] = value!;
                                      });
                                      _updateRegistrationStatus();
                                    },
                                  ),
                                );
                              },
                            ),
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
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: generateQRCode,
              child: Text("Generate QR Code",
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
