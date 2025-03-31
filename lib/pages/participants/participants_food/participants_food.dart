// import 'package:flutter/material.dart';
// import 'package:hacknow/pages/volunteer/volunteer_food/qr_results_page.dart';
// import 'package:hacknow/services/backend_service.dart';
// import 'package:hacknow/utils/custom_app_bar.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
// import 'package:permission_handler/permission_handler.dart';

// class FoodScreen extends StatefulWidget {
//   const FoodScreen({super.key});

//   @override
//   _FoodScreenState createState() => _FoodScreenState();
// }

// class _FoodScreenState extends State<FoodScreen> {
//   MobileScannerController cameraController = MobileScannerController(
//     detectionSpeed: DetectionSpeed.normal,
//     torchEnabled: false,
//   );

//   @override
//   void initState() {
//     super.initState();
//     checkCameraPermission();
//   }

//   // Check if camera permission is granted, else request
//   Future<void> checkCameraPermission() async {
//     var status = await Permission.camera.status;

//     if (status.isDenied) {
//       status = await Permission.camera.request();
//     }

//     if (!status.isGranted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("❌ Camera permission is required to scan QR codes."),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: customAppBar(
//         title: "Scan QR Code for Food",
//       ),
//       body: Stack(
//         alignment: Alignment.center,
//         children: [
//           MobileScanner(
//             controller: cameraController,
//             onDetect: (capture) async {
//               final List<Barcode> barcodes = capture.barcodes;
//               if (barcodes.isNotEmpty) {
//                 String scannedData = barcodes.first.rawValue ?? "";
//                 cameraController.stop();
//                 String errorMessage = await processScannedData(scannedData);
//                 if (mounted) {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                         builder: (context) => QrResultsPage(errorMessage)),
//                   );
//                 }
//               }
//             },
//           ),
//           Positioned(
//             bottom: 20,
//             child: ElevatedButton(
//               onPressed: () => cameraController.toggleTorch(),
//               child: Text("Toggle Flash"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<String> processScannedData(String scannedData) async {
//     //logic to handle the scanned qr

//     Backendservice backend = Backendservice();
//     return await backend.giveFoodToUser(scannedData);

//     // // Optionally, close the scanner after processing the data
//     // Navigator.pop(context, scannedData);
//   }
// }
