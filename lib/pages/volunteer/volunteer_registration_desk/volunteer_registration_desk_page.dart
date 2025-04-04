import 'dart:async';
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
  List<String> teamMemberEmails = [];
  Map<String, bool> checkboxStatesIOS = {};
  Map<String, bool> checkboxStatesAttendance = {};
  Map<String, bool> checkboxStates = {};
  String? assignedTeamName;
  Backendservice _backendservice = Backendservice();
  StreamSubscription<DocumentSnapshot>? _qrSubscription;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  @override
  void dispose() {
    _qrSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeUser() async {
    final userBox = await Hive.openBox<UserModel>('userBox');
    if (mounted) {
      setState(() {
        currentUserId = userBox.get("currentUser")?.id;
      });
    }
  }

  Future<void> generateQRCode() async {
    if (isLoading) {
      _showErrorSnackbar("Wait for the team to be updated in excel");
      return;
    }
    ;
    if (currentUserId == null) {
      _showErrorSnackbar("❌ Error: User not found!");
      return;
    }

    final newUUID = Uuid().v4();
    try {
      await _firestore.collection("registrationQR").doc(newUUID).set({
        "generatedBy": currentUserId,
        "teamName": "",
        "timestamp": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          generatedUUID = newUUID;
          assignedTeamName = null;
          teamMembers = [];
          checkboxStates = {};
        });
        _setupQRSubscription(newUUID);
      }
      _showSuccessSnackbar("✅ QR Code Generated & Stored in Firestore!");
    } catch (e) {
      print("Firestore error: $e");
      _showErrorSnackbar("❌ Error saving QR Code. Try again.");
    }
  }

  void _setupQRSubscription(String uuid) {
    _qrSubscription?.cancel();
    _qrSubscription = _firestore
        .collection("registrationQR")
        .doc(uuid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final teamName = snapshot.get("teamName") ?? "";
        if (teamName.isNotEmpty && teamName != assignedTeamName) {
          setState(() => assignedTeamName = teamName);
          _fetchTeamMembers(teamName);
        }
      }
    });
  }

  Future<void> _fetchTeamMembers(String teamName) async {
    try {
      final members = await _backendservice.fetchTeamMembers(teamName);
      if (mounted) {
        setState(() {
          teamMembers = members.keys.toList();
          teamMemberEmails = members.values.toList();
          checkboxStates = {for (var member in members.keys) member: false};
        });
      }
    } catch (e) {
      print("Team fetch error: $e");
      _showErrorSnackbar("❌ Error fetching team members.");
    }
  }

  Future<void> markTeamRegistered() async {
    if (isLoading) {
      _showErrorSnackbar("Already processing...");
      return;
    }
    ;
    if (assignedTeamName == null) return;

    try {
      setState(() {
        isLoading = true;
      });
      await _firestore.collection("teams").doc(assignedTeamName).update({
        "registered": true,
      });

      for (String email in teamMemberEmails) {
        final status = checkboxStatesAttendance[email] == true ? "P" : "A";
        await _backendservice.updateAttendance(email, status);
      }

      _showSuccessSnackbar("✅ Team Registered Successfully!");
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Registration error: $e");
      _showErrorSnackbar("❌ Error registering team.");
    }
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sH = MediaQuery.of(context).size.height;
    final sW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(title: "Volunteer Registration Desk"),
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
            if (generatedUUID != null) _buildQRContent(sW, sH),
            if (generatedUUID == null) _buildGenerateButton(sW, sH),
          ],
        ),
      ),
    );
  }

  Widget _buildQRContent(double sW, double sH) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore
          .collection("registrationQR")
          .doc(generatedUUID)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text("QR Code expired or invalid",
              style: TextStyle(color: Colors.red));
        }

        final teamName = snapshot.data!.get("teamName") ?? "";
        return teamName.isEmpty
            ? _buildQRDisplay(snapshot.data!.id)
            : _buildTeamDetails(sW, sH, teamName);
      },
    );
  }

  Widget _buildQRDisplay(String uuid) {
    return Column(
      children: [
        QrImageView(
          data: uuid,
          size: 300,
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 10),
        SelectableText(
          "UUID: $uuid",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTeamDetails(double sW, double sH, String teamName) {
    return SingleChildScrollView(
      child: Column(
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
          _buildTeamMembersList(sW, sH),
          _buildRegistrationButton(),
          SizedBox(
            height: sH * 0.03,
          ),
          _buildGenerateButton(sW, sH),
        ],
      ),
    );
  }

  Widget _buildTeamMembersList(double sW, double sH) {
    return teamMembers.isEmpty
        ? ElevatedButton(
            onPressed: () => _fetchTeamMembers(assignedTeamName!),
            child: Text("Load Team Members"),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: sW * 0.5,
                    child: Text(
                      "Team Members",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: sW * 0.17,
                    child: txt(
                      "IOS Status",
                    ),
                  ),
                  SizedBox(
                    width: sW * 0.02,
                  ),
                  SizedBox(
                    width: sW * 0.17,
                    child: txt("Attendance Status",
                        size: sW * 0.03, color: Colors.white, maxLine: 1),
                  ),
                ],
              ),
              SizedBox(
                height: sH * 0.35,
                child: ListView.separated(
                    shrinkWrap: true,
                    separatorBuilder: (_, __) => SizedBox(height: sH * 0.02),
                    itemCount: teamMembers.length,
                    itemBuilder: (context, index) {
                      return _buildMemberRow(sW, index);
                    }),
              ),
            ],
          );
  }

  Widget _buildMemberRow(double sW, int index) {
    final member = teamMembers[index];
    final email = teamMemberEmails[index];

    return Container(
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(color: CustomColor.secondaryColor),
      child: Row(
        children: [
          SizedBox(
            width: sW * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                txt(member, size: sW * 0.04, maxLine: 1),
                
                txt(email, size: sW * 0.03, color: Colors.grey, maxLine: 1),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: sW * 0.18,
            child: Checkbox(
              value: checkboxStatesIOS[email] ?? false,
              onChanged: (value) => _updateIOSStatus(email, value!),
            ),
          ),
          SizedBox(
            width: sW * 0.18,
            child: Checkbox(
              value: checkboxStatesAttendance[email] ?? false,
              onChanged: (value) => _updateAttendanceStatus(email, value!),
            ),
          ),
        ],
      ),
    );
  }

  void _updateIOSStatus(String email, bool value) {
    setState(() => checkboxStatesIOS[email] = value);
    _backendservice.updateIOSUserStatus(email, value);
  }

  void _updateAttendanceStatus(String email, bool value) {
    setState(() => checkboxStatesAttendance[email] = value);
  }

  Widget _buildRegistrationButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: markTeamRegistered,
      child: Text(isLoading ? "Processing..." : "Mark Team Registered",
          style: TextStyle(fontSize: 16, color: Colors.white)),
    );
  }

  Widget _buildGenerateButton(double sW, double sH) {
    return GestureDetector(
      onTap: generateQRCode,
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: sW * 0.08, vertical: sH * 0.01),
        margin: EdgeInsets.symmetric(horizontal: sW * 0.2),
        decoration: BoxDecoration(
          color: CustomColor.primaryButtonColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(isLoading ? "Processing..." : "Generate QR Code",
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }
}
