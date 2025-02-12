import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/controller/user_controller.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/services/backend_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TeamRegisterPage extends StatefulWidget {
  TeamRegisterPage({super.key});

  @override
  _TeamRegisterPageState createState() => _TeamRegisterPageState();
}

class _TeamRegisterPageState extends State<TeamRegisterPage> {
  Backendservice _backendservice = Backendservice();
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String teamName;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController collegeNameController = TextEditingController();
  String selectedGender = 'Male';
  String selectedExternal = 'False';
  String teamSize = '2';
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments safely here
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    teamName = arguments['teamName'];

    // Initialize controllers
  }

  @override
  Widget build(BuildContext context) {
    UserController userController =
        Provider.of<UserController>(context, listen: false);

    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: customAppBar(
        title: "Team Leader Details",
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(sW * 0.04),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    txt("Team Leader First Name", size: sW * 0.035),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: firstNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: 'Kartikey'),
                    ),
                    SizedBox(height: sH * 0.02),

                    txt("Team Leader Last Name", size: sW * 0.035),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: lastNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: 'Patel'),
                    ),
                    SizedBox(height: sH * 0.02),

                    txt("Team Leader Phone Number", size: sW * 0.035),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: phoneNumberController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: '9876543210'),
                    ),
                    SizedBox(height: sH * 0.02),

                    txt("Team Leader College Name", size: sW * 0.035),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: collegeNameController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(hintText: 'VIT, Chennai'),
                    ),
                    SizedBox(height: sH * 0.02),

                    // Gender Dropdown
                    txt("Team Leader Gender", size: sW * 0.035),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      dropdownColor: Colors.grey[900],
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      items: ['Male', 'Female']
                          .map((label) => DropdownMenuItem(
                                child: Text(label,
                                    style: TextStyle(color: Colors.white)),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                    ),
                    SizedBox(height: sH * 0.02),

                    // External Participant Dropdown
                    txt("External Participant", size: sW * 0.035),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: selectedExternal,
                      dropdownColor: Colors.grey[900],
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      items: ['True', 'False']
                          .map((label) => DropdownMenuItem(
                                child: Text(label,
                                    style: TextStyle(color: Colors.white)),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedExternal = value!;
                        });
                      },
                    ),
                    SizedBox(height: sH * 0.02),
                    txt("Team Size", size: sW * 0.035),
                    const SizedBox(height: 8.0),
                    DropdownButtonFormField<String>(
                      value: teamSize,
                      dropdownColor: Colors.grey[900],
                      decoration: InputDecoration(border: OutlineInputBorder()),
                      items: ['2', '3', '4']
                          .map((label) => DropdownMenuItem(
                                child: Text(label,
                                    style: TextStyle(color: Colors.white)),
                                value: label,
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          teamSize = value!;
                        });
                      },
                    ),
                    SizedBox(height: sH * 0.05),
                  ],
                ),
              ),
            ),
            NextButton(
                title: "Submit",
                onTapFunction: () async {
                  String username = UserModel.generateUsername(
                      firstNameController.text, phoneNumberController.text);
                  String password =
                      UserModel.generatePassword(firstNameController.text);
                  if (teamName.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Team name is missing. Please go back and enter a team.")),
                    );
                    return;
                  }

                  String userId = Uuid().v4();

                  // Create user in Firestore
                  await _firestore.collection("users").doc(userId).set({
                    "id": userId,
                    "firstName": firstNameController.text,
                    "lastName": lastNameController.text,
                    "phoneNumber": phoneNumberController.text,
                    "collegeName": collegeNameController.text,
                    "gender": selectedGender,
                    "external": selectedExternal == "True",
                    "teamId": teamName,
                    "userType": "participant",
                    "username": username,
                    "password": password,
                  });

                  DocumentReference teamRef =
                      _firestore.collection("teams").doc(teamName);

                  await teamRef.update({
                    "teamLeaderId": userId,
                    "teamMembers": FieldValue.arrayUnion([userId]),
                    "teamSize": int.parse(teamSize),
                  }).catchError((error) async {
                    await teamRef.set({
                      "name": teamName,
                      "registered": false,
                      "teamLeaderId": userId,
                      "teamMembers": [userId],
                    });
                  });

                  // Store user data in Hive
                  var userBox = Hive.box<UserModel>('userBox');
                  UserModel user = UserModel(
                    id: userId,
                    approved: true,
                    userType: "participany",
                    firstName: firstNameController.text,
                    lastName: lastNameController.text,
                    phoneNumber: phoneNumberController.text,
                    collegeName: collegeNameController.text,
                    external: selectedExternal == "True",
                    gender: selectedGender,
                    username: username,
                    password: password,
                  );
                  userBox.put("currentUser", user);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text("User and team updated successfully!")),
                  );

                  Navigator.pushNamed(
                    context,
                    '/teamMemberPage',
                    arguments: {
                      'teamName': teamName,
                      'teamSize': teamSize,
                    },
                  );
                }),
          ],
        ),
      ),
    );
  }
}
