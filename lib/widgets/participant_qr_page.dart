import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hive/hive.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ParticipantQrPage extends StatefulWidget {
  const ParticipantQrPage({super.key});

  @override
  State<ParticipantQrPage> createState() => _ParticipantQrPageState();
}

class _ParticipantQrPageState extends State<ParticipantQrPage> {
  String? teamName;

  @override
  void initState() {
    super.initState();
    _fetchTeamName();
  }

  void _fetchTeamName() {
    var teamBox = Hive.box('teamBox');
    setState(() {
      teamName = teamBox.get('teamName');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Team QR Code",
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: CustomColor.whiteTextColor,
          ),
        ),
      ),
      body: Center(
        child: teamName == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Team: $teamName",
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  QrImageView(
                    data: teamName!.toUpperCase(),
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Scan to get Team Name",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
      ),
    );
  }
}
