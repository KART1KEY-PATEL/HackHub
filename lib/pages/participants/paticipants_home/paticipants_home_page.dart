import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hive/hive.dart';

class ParticipantHomePage extends StatefulWidget {
  const ParticipantHomePage({super.key});

  @override
  State<ParticipantHomePage> createState() => _ParticipantHomePageState();
}

class _ParticipantHomePageState extends State<ParticipantHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "ParticipantHomePage",
        actions: [
          TextButton(
            onPressed: () async {
              var userBox = Hive.box<UserModel>('userBox');
              await userBox.clear();
              Navigator.pushNamed(context, '/');
            },
            child: Text("Logout"),
          ),
        ],
      ),
    );
  }
}
