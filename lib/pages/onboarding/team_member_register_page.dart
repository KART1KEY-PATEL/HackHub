import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:uuid/uuid.dart';

class TeamMemberPage extends StatefulWidget {
  const TeamMemberPage({super.key});

  @override
  State<TeamMemberPage> createState() => _TeamMemberPageState();
}

class _TeamMemberPageState extends State<TeamMemberPage> {
  late int teamSize;
  late String teamName;
  late List<Map<String, dynamic>> memberControllers;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve arguments safely here
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    teamSize = int.parse(arguments['teamSize']) - 1;
    teamName = arguments['teamName'];

    // Initialize controllers
    memberControllers = List.generate(
      teamSize,
      (index) => {
        "firstName": TextEditingController(),
        "phoneNumber": TextEditingController(),
        "gender": "Male",
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var sW = MediaQuery.of(context).size.width;
    String selectedGender = 'Male';

    var sH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: customAppBar(title: "Team Details"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemBuilder: (context, index) {
                  return Container(
                    // height: sH * 0.36,
                    width: sW,
                    color: CustomColor.secondaryColor,
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        txt("Member Name ${index + 1}", size: sW * 0.03),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: memberControllers[index]['firstName'],
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(hintText: 'Enter Name'),
                        ),
                        SizedBox(height: sH * 0.02),
                        txt("Member Contact Number ${index + 1}",
                            size: sW * 0.03),
                        const SizedBox(height: 8.0),
                        TextField(
                          controller: memberControllers[index]['phoneNumber'],
                          style: TextStyle(color: Colors.white),
                          decoration:
                              InputDecoration(hintText: 'Enter Phone Number'),
                        ),
                        SizedBox(height: sH * 0.02),
                        txt("Member Gender ${index + 1}", size: sW * 0.035),
                        const SizedBox(height: 8.0),
                        DropdownButtonFormField<String>(
                          value: memberControllers[index]['gender'],
                          dropdownColor: Colors.grey[900],
                          decoration:
                              InputDecoration(border: OutlineInputBorder()),
                          items: ['Male', 'Female']
                              .map((label) => DropdownMenuItem(
                                    child: Text(label,
                                        style: TextStyle(color: Colors.white)),
                                    value: label,
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              memberControllers[index]['gender'] = value!;
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return SizedBox(
                    height: sH * 0.02,
                  );
                },
                itemCount: teamSize,
              ),
            ),
            NextButton(
                title: "Submit",
                onTapFunction: () async {
                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  DocumentReference teamRef =
                      firestore.collection("teams").doc(teamName);

                  for (int i = 0; i < teamSize; i++) {
                    String firstName = memberControllers[i]['firstName'].text;
                    String phoneNumber =
                        memberControllers[i]['phoneNumber'].text;
                    String gender = memberControllers[i]['gender'];

                    String userId = Uuid().v4();

                    String username =
                        UserModel.generateUsername(firstName, phoneNumber);
                    String password = UserModel.generatePassword(firstName);

                    UserModel user = UserModel(
                      userType: "participant",
                      firstName: firstName,
                      lastName: "", // Modify if needed
                      phoneNumber: phoneNumber,
                      collegeName: "VIT Chennai", // Modify if needed
                      external: false,
                      approved: true,
                      gender: gender,
                      username: username,
                      password: password,
                      id: userId,
                    );

                    // Save to Firestore (Users Collection)
                    await firestore.collection("users").doc(userId).set({
                      "id": userId,
                      "userType": user.userType,
                      "firstName": user.firstName,
                      "lastName": user.lastName,
                      "phoneNumber": user.phoneNumber,
                      "collegeName": user.collegeName,
                      "external": user.external,
                      "gender": user.gender,
                      "username": user.username,
                      "password": user.password,
                      "approved": true,
                    });

                    // Update Team Members List in Firestore
                    await teamRef.update({
                      "teamMembers": FieldValue.arrayUnion([userId])
                    }).catchError((error) async {
                      // If the team does not exist, create it and add the first member
                      await teamRef.set({
                        "name": teamName,
                        "registered": false,
                        "teamLeaderId":
                            userId, // Ensure the first user is set as leader
                        "teamMembers": [userId],
                        "teamSize": teamSize
                      });
                    });
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Team members added successfully!")),
                  );

                  Navigator.pushNamed(context, '/teamDetails', arguments: {
                    "teamName": teamName,
                  });
                })
          ],
        ),
      ),
    );
  }
}
