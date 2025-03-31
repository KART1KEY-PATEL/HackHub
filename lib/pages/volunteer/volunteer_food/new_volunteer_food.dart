import 'package:flutter/material.dart';
import 'package:hacknow/pages/volunteer/volunteer_food/qr_results_page.dart';
import 'package:hacknow/services/backend_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class NewVolunteerFood extends StatefulWidget {
  const NewVolunteerFood({super.key});

  @override
  _NewVolunteerFoodState createState() => _NewVolunteerFoodState();
}

class _NewVolunteerFoodState extends State<NewVolunteerFood>
    with WidgetsBindingObserver {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
  );
  bool isCameraOn = false; // Add camera state tracker

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkCameraPermission();
  }

  void toggleCamera() {
    setState(() {
      isCameraOn = !isCameraOn;
    });

    if (isCameraOn) {
      cameraController.start();
    } else {
      cameraController.stop();
    }
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
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Restart camera when app returns to foreground
      if (isCameraOn) {
        cameraController.start();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Scan QR Code for Food",
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          !isCameraOn
              ? Center(
                  child: txt(""),
                )
              : SizedBox(),
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (!isCameraOn) return; // Prevent processing when camera is off

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                String scannedData = barcodes.first.rawValue ?? "";
                setState(() => isCameraOn = false); // Add this line

                cameraController.stop();
                print("Hello the scanned ${scannedData}");
                // String errorMessage = await processScannedData(scannedData);
                String errorMessage = "hello";
                if (mounted) {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => QrResultsPage(userId: scannedData),
                    ),
                  )
                      .then((_) {
                    // Restart camera when returning from results page
                    if (mounted) {
                      setState(() => isCameraOn = true);
                      cameraController.start();
                    }
                  });
                }
              }
            },
          ),
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Toggle Camera Button
                ElevatedButton.icon(
                  onPressed: toggleCamera,
                  icon: Icon(
                    isCameraOn ? Icons.videocam_off : Icons.videocam,
                    size: 24,
                  ),
                  label: Text(isCameraOn ? "Stop Camera" : "Start Camera"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                SizedBox(width: 16),
                // Existing Flash Toggle
                ElevatedButton.icon(
                  onPressed: () => cameraController.toggleTorch(),
                  icon: Icon(Icons.flash_on, size: 24),
                  label: Text("Toggle Flash"),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Future<String> processScannedData(String scannedData) async {
  //   //logic to handle the scanned qr

  //   Backendservice backend = Backendservice();
  //   return await backend.giveFoodToUser(scannedData);

  //   // // Optionally, close the scanner after processing the data
  //   // Navigator.pop(context, scannedData);
  // }
}
