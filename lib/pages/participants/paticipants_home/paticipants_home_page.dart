import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flip_panel_plus/flip_panel_plus.dart';
import 'package:flutter/services.dart';
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
            icon: const Icon(Icons.qr_code),
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            txt(
              "Remaining Time",
              size: sW * 0.05,
              isBold: true,
            ),
            SizedBox(height: sH * 0.01),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : _timeRemaining.isNegative
                      ? const Text(
                          "Hackathon has ended!",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : FlipClockPlus.reverseCountdown(
                          separator: SizedBox(width: sW * 0.01),
                          duration: _timeRemaining,
                          digitColor: Colors.black,
                          backgroundColor: Colors.white,
                          digitSize: 40.0,
                          height: 80,
                          spacing: EdgeInsets.all(2),
                          width: sW * 0.09,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(3.0)),
                          onDone: () {
                            print("Hackathon is over!");
                          },
                        ),
            ),
            SizedBox(height: sH * 0.02),
            txt("Announcements", size: sW * 0.05, isBold: true),

            /// Announcements StreamBuilder
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('annoucements')
                    .doc('rr1eEn9498nuIcJaKqAe')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<dynamic> messages = snapshot.data!['messages'] ?? [];

                  if (messages.isEmpty) {
                    return const Center(
                      child: Text("No Announcements Yet",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    );
                  }

                  return ListView.builder(
                    itemCount: messages.length,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      var message = messages[index];

                      return Card(
                        color: CustomColor.secondaryColor,
                        margin: const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// Created By & Time
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Send By: ${message['createdBy']}",
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent),
                                  ),
                                  Text(
                                    _formatDate(message['createdAt']),
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              /// Message Text
                              Text(
                                message['message'],
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                              const SizedBox(height: 8),

                              /// If link exists, allow copying
                              if (message['link'] != null &&
                                  message['link'].toString().isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: message['link']));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text("Link copied to clipboard"),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    message['link'],
                                    style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),

                              /// If photoUrl exists, show image
                              if (message['photoUrl'] != null &&
                                  message['photoUrl'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      message['photoUrl'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper function to format timestamp
  String _formatDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.day} ${_monthName(date.month)} ${date.year}, ${date.hour}:${date.minute}";
  }

  /// Converts month number to name
  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[month - 1];
  }
}
