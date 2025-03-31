import 'package:flutter/material.dart';
import 'package:hacknow/controller/user_controller.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Add this import

class NewParticipantFood extends StatefulWidget {
  const NewParticipantFood({super.key});

  @override
  State<NewParticipantFood> createState() => _NewParticipantFoodState();
}

class _NewParticipantFoodState extends State<NewParticipantFood> {
  UserModel? currentUser;
  var userBox = Hive.box<UserModel>('userBox');

  @override
  void initState() {
    super.initState();
    currentUser = userBox.get("currentUser");
  }

  @override
  Widget build(BuildContext context) {
    final sH = MediaQuery.of(context).size.height;
    final sW = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(
        title: "Participant Food Page",
      ),
      body: Center(
        child: currentUser == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: currentUser!.id,
                    version: QrVersions.auto,
                    size: 300.0,
                    backgroundColor: Colors.white,
                  ),
                  SizedBox(
                    height: sH * 0.02,
                  ),
                  txt(
                    "Participant Team Name: ${currentUser!.teamId}",
                    textAlign: TextAlign.center,
                    size: sW * 0.05,
                  ),
                  txt(
                    "Participant Name: ${currentUser!.firstName} ${currentUser!.lastName}",
                    textAlign: TextAlign.center,
                    size: sW * 0.05,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
