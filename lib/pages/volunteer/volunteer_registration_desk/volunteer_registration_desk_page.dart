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
  List<String> teamMembers = []; // Store team members
  Backendservice _backendservice = Backendservice();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  // Fetch current user ID from Hive
  Future<void> _fetchCurrentUser() async {
    var userBox = await Hive.openBox<UserModel>('userBox');
    setState(() {
      currentUserId = userBox.get("currentUser")?.id;
    });
  }

  // Function to generate and store QR Code in Firestore
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

    String newUUID = Uuid().v4(); // Generate a new UUID

    try {
      // Store in Firestore
      await _firestore.collection("registrationQR").doc(newUUID).set({
        "generatedBy": currentUserId,
        "teamName": "", // Initially empty
        "timestamp": FieldValue.serverTimestamp(),
      });

      setState(() {
        generatedUUID = newUUID;
        teamMembers = []; // Reset team members when new QR is generated
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
                  String teamName = qrData["teamName"] ?? "";

                  // Fetch team members when teamName is assigned
                  if (teamName.isNotEmpty && teamMembers.isEmpty) {
                    _backendservice.fetchTeamMembers(teamName).then((members) {
                      setState(() {
                        teamMembers = members;
                      });
                    });
                  }

                  if (teamName.isNotEmpty) {
                    return Column(
                      children: [
                        Icon(Icons.group, size: 100, color: Colors.greenAccent),
                        const SizedBox(height: 10),
                        Text(
                          "✅ Team Assigned: $teamName",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ...teamMembers
                            .map((member) => Text(
                                  "• $member",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ))
                            .toList(),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: generateQRCode,
                          child: Text(
                            "Generate New QR Code",
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
            if (generatedUUID == null)
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
