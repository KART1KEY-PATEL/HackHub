import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/services/backend_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hive/hive.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  Backendservice backendservice = Backendservice();
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
              Navigator.pushNamed(context, '/spash');
            },
            child: Text("Logout"),
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await backendservice.updateTeamsInFirestore();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Teams updated successfully!")),
              );
            },
            child: Text("Update Teams in Backend"),
          ),
          SizedBox(
            height: 10,
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // await backendservice.backupUsersToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Users backed up successfully!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error backing up users: $e")),
                );
              }
            },
            child: Text("Backup users"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // await backendservice.backupTeamsToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Users backed up successfully!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error backing up users: $e")),
                );
              }
            },
            child: Text("Teams backup"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // await backendservice.backupFoodToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Users backed up successfully!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error backing up users: $e")),
                );
              }
            },
            child: Text("food backup"),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // await backendservice.backupFoodToFirestore();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Generate qr")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error backing up users: $e")),
                );
              }
            },
            child: Text("Generate qr"),
          ),
          ElevatedButton(
            onPressed: () async {
              await backendservice.deleteDuplicateUsers();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text("Duplicate users deleted successfully!")),
              );
            },
            child: Text("Clean Duplicate Users"),
          ),
        ],
      ),
    );
  }
}
