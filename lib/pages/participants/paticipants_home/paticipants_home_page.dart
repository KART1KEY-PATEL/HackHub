import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';

class ParticipantHomePage extends StatefulWidget {
  const ParticipantHomePage({super.key});

  @override
  State<ParticipantHomePage> createState() => _ParticipantHomePageState();
}

class _ParticipantHomePageState extends State<ParticipantHomePage> {
  Duration _timeRemaining = Duration.zero;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHackEndTime();
  }

  Future<void> _fetchHackEndTime() async {
    try {
      DocumentSnapshot settingsSnapshot = await FirebaseFirestore.instance
          .collection('settings')
          .doc('settings')
          .get();

      if (settingsSnapshot.exists) {
        Timestamp hackEndTimestamp = settingsSnapshot['hackEnd'];
        DateTime hackEndTime = hackEndTimestamp.toDate();
        setState(() {
          _timeRemaining = hackEndTime.difference(DateTime.now());
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching hackEnd time: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: customAppBar(
        title: "Home Page",
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/participantQrPage',
              );
            },
            icon: Icon(Icons.qr_code),
            color: CustomColor.primaryButtonColor,
          ),
          TextButton(
            onPressed: () async {
              var userBox = Hive.box<UserModel>('userBox');
              await userBox.clear();
              Navigator.pushNamed(context, '/');
            },
            child: const Text("Logout"),
          ),
        ],
      ),
      body: Column(
        children: [
          txt("Remaining Time", size: sW * 0.07),
          Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : _timeRemaining.isNegative
                    ? const Text(
                        "Hackathon has ended!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      )
                    : FlipClockPlus.reverseCountdown(
                        duration: _timeRemaining,
                        digitColor: Colors.black,
                        backgroundColor: Colors.white,
                        digitSize: 40.0,
                        height: 80,
                        spacing: EdgeInsets.all(2),
                        width: 35,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(3.0)),
                        onDone: () {
                          print("Hackathon is over!");
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
