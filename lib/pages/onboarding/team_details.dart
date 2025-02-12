import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/pages/onboarding/team_approval_page.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class TeamDetails extends StatefulWidget {
  const TeamDetails({super.key});

  @override
  State<TeamDetails> createState() => _TeamDetailsState();
}

class _TeamDetailsState extends State<TeamDetails> {
  late String teamName;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> teamMembersDetails = [];
  bool isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (arguments != null && arguments.containsKey('teamName')) {
      teamName = arguments['teamName'];
      print("Team name: $teamName");

      // Fetch team details after setting teamName
      fetchTeamDetails();
    } else {
      print("Error: teamName argument is missing.");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchTeamDetails() async {
    try {
      // Get the team document from Firestore
      DocumentSnapshot teamSnapshot =
          await firestore.collection("teams").doc(teamName).get();

      if (teamSnapshot.exists) {
        var teamData = teamSnapshot.data() as Map<String, dynamic>;
        List<dynamic> teamMemberIds = teamData['teamMembers'] ?? [];

        // Fetch user details for each member
        List<Map<String, dynamic>> membersList = [];

        for (String memberId in teamMemberIds) {
          DocumentSnapshot userSnapshot =
              await firestore.collection("users").doc(memberId).get();

          if (userSnapshot.exists) {
            var userData = userSnapshot.data() as Map<String, dynamic>;

            membersList.add({
              "name": "${userData["firstName"]} ${userData["lastName"]}",
              "username": userData["username"],
              "password": userData["password"],
            });
          }
        }

        setState(() {
          teamMembersDetails = membersList;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching team details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to check camera permission and open scanner
  Future<void> scanQRCode(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      // Open Scanner after permission is granted
      String? scannedUUID = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(),
        ),
      );
      if (scannedUUID != null) {
        try {
          DocumentSnapshot qrDoc = await firestore
              .collection("registrationQR")
              .doc(scannedUUID)
              .get();

          if (qrDoc.exists) {
            // Update the document with the team name
            await firestore
                .collection("registrationQR")
                .doc(scannedUUID)
                .update({
              "teamName": teamName,
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("✅ Team name updated successfully!"),
                backgroundColor: Colors.greenAccent,
              ),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => TeamApprovalPage(
                  teamName: teamName,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ QR Code not registered!"),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        } catch (e) {
          print("Error updating QR Code: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("❌ Error processing QR Code."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Camera permission is required to scan QR codes."),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "$teamName Details"),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : teamMembersDetails.isEmpty
              ? Center(child: Text("No team members found."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: teamMembersDetails.length,
                        itemBuilder: (context, index) {
                          var member = teamMembersDetails[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: ListTile(
                              title: Text(member["name"]),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Username: ${member["username"]}"),
                                  Text("Password: ${member["password"]}"),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => scanQRCode(context),
                      child: Text(
                        "Scan QR Code",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
    );
  }
}

// QR Scanner Screen with Camera Permission Handling
class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      checkCameraPermission();
    });
  }

  // Check if camera permission is granted, else request
  Future<void> checkCameraPermission() async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Camera permission is required to scan QR codes."),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context); // Close Scanner if permission is denied
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Scan QR Code"), backgroundColor: Colors.blueAccent),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                String scannedData = barcodes.first.rawValue ?? "";
                Navigator.pop(context, scannedData); // Return scanned UUID
              }
            },
          ),
          Positioned(
            bottom: 20,
            child: ElevatedButton(
              onPressed: () => cameraController.toggleTorch(),
              child: Text("Toggle Flash"),
            ),
          ),
        ],
      ),
    );
  }
}
