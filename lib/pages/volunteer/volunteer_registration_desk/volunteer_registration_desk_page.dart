import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:hive/hive.dart';
import 'package:hacknow/model/user_model.dart'; // Ensure you have UserModel imported

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
        "teamName": "", // Leave blank for now
        "timestamp": FieldValue.serverTimestamp(),
      });

      setState(() {
        generatedUUID = newUUID;
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

            // Show QR Code only if UUID is generated
            if (generatedUUID != null)
              Column(
                children: [
                  QrImageView(
                    data: generatedUUID!,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    "UUID: $generatedUUID",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Button to Generate QR Code
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
