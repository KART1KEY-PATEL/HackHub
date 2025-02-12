import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hive/hive.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        title: "Admin Home Page",
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
