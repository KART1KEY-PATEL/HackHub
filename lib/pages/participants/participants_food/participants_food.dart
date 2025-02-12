import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    torchEnabled: false,
  );

  @override
  void initState() {
    super.initState();
    checkCameraPermission();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code for Food"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                String scannedData = barcodes.first.rawValue ?? "";
                // Handle the scanned qr

                processScannedData(scannedData);
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

  void processScannedData(String scannedData) {
    //logic to handle the scanned qr
    //
    //

    // Optionally, close the scanner after processing the data
    Navigator.pop(context, scannedData);
  }
}
