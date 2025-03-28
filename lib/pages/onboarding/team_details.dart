import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/pages/onboarding/team_approval_page.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
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

      // Fetch team details after setting teamName
      fetchTeamDetails();
    } else {
      print("Error: teamName argument is missing.");
      setState(() => isLoading = false);
    }
  }

  Future<void> fetchTeamDetails() async {
    try {
      if (!mounted) return; // 🔥 Ensure widget is still in the tree

      DocumentSnapshot teamSnapshot =
          await firestore.collection("teams").doc(teamName).get();

      if (teamSnapshot.exists) {
        var teamData = teamSnapshot.data() as Map<String, dynamic>;
        List<dynamic> teamMemberIds = teamData['teamMembers'] ?? [];

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

        if (mounted) {
          setState(() {
            teamMembersDetails = membersList;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching team details: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Function to check camera permission and open scanner
  Future<void> scanQRCode(BuildContext context) async {
    var status = await Permission.camera.status;

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      String? scannedUUID = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => QRScannerScreen()),
      );
      if (scannedUUID == null || scannedUUID.isEmpty) {
        print("Error: Scanned QR code is empty or null.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Invalid QR Code."),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (scannedUUID != null) {
        try {
          print("Scanned QR Code: $scannedUUID"); // Debugging
          DocumentSnapshot qrDoc = await firestore
              .collection("registrationQR")
              .doc(scannedUUID)
              .get();
          if (!qrDoc.exists) {
            print("Error: QR Code does not exist in Firestore.");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ QR Code not found in the database."),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }

          if (qrDoc.exists) {
            await firestore
                .collection("registrationQR")
                .doc(scannedUUID)
                .update({
              "teamName": teamName,
            });

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("✅ Team name updated successfully!"),
                  backgroundColor: Colors.greenAccent,
                ),
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TeamApprovalPage(teamName: teamName),
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("❌ QR Code not registered!"),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }
        } catch (e) {
          print("Error updating QR Code: $e");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("❌ Error processing QR Code."),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
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
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(title: "$teamName Details"),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : teamMembersDetails.isEmpty
              ? Center(child: Text("No team members found."))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: sH * 0.01,
                            );
                          },
                          itemCount: teamMembersDetails.length,
                          itemBuilder: (context, index) {
                            var member = teamMembersDetails[index];

                            return Stack(
                              children: [
                                Container(
                                  // height: sH * 0.,
                                  padding: EdgeInsets.all(10),
                                  width: sW,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: CustomColor.secondaryColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // SizedBox(
                                          //   height: sH * 0.02,
                                          // ),
                                          txt("Name: ${member["name"]}",
                                              size: sW * 0.05, isBold: true),
                                          txt(
                                            "Username: ${member["username"]}",
                                            size: sW * 0.04,
                                          ),
                                          txt(
                                            "Password: ${member["password"]}",
                                            size: sW * 0.04,
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: sH * 0.02,
                                          ),
                                          Icon(
                                            Icons.person,
                                            size: sW * 0.2,
                                            color:
                                                CustomColor.primaryButtonColor,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? Colors.red
                                          : CustomColor.secondaryButtonColor,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: sW * 0.03,
                                      vertical: sH * 0.004,
                                    ),
                                    child: txt(
                                      index == 0
                                          ? "Team Leader"
                                          : "Team Members",
                                      size: sH * 0.018,
                                      color: index == 0
                                          ? Colors.white
                                          : Colors.black,
                                      isBold: true,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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

  bool isScanning = false; // Prevent multiple scans

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      checkCameraPermission();
    });
  }

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
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: ("Scan QR Code"),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (!isScanning) {
                isScanning = true; // Prevent multiple scans
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  String scannedData = barcodes.first.rawValue ?? "";
                  print("Scanned Data: $scannedData"); // Debugging
                  Navigator.pop(context, scannedData);
                } else {
                  print("Error: No QR code data found.");
                }
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
