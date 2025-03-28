import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

class VolunteerFood extends StatefulWidget {
  const VolunteerFood({super.key});

  @override
  State<VolunteerFood> createState() => _VolunteerFoodState();
}

class _VolunteerFoodState extends State<VolunteerFood> {
  String volunteerUuid = "";
  Future<String> getID() async {
    Box box = await Hive.openBox<UserModel>('userBox');
    volunteerUuid = box.get("currentUser")!.id;
    return volunteerUuid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(title: "Scan to Authenticate participant for food"),
      body: FutureBuilder(
        future: getID(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: QrImageView(
                data: volunteerUuid,
                version: QrVersions.auto,
                size: 350.0,
                backgroundColor: Colors.white,
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
