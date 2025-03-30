import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/controller/team_controller.dart';
import 'package:hacknow/controller/user_controller.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/services/backend_service.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
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

  final _formKey = GlobalKey<FormState>();

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

    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    teamName = arguments['teamName'];
    Provider.of<TeamController>(context, listen: false).setTeamName(teamName);
  }

  bool isPhoneNumberValid(String phoneNumber) {
    return RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber);
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    UserController userController =
        Provider.of<UserController>(context, listen: false);
    TeamController teamController =
        Provider.of<TeamController>(context, listen: false);

    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: customAppBar(
        title: "Team Leader Details",
        elevation: 0,
        leading: IconButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(sW * 0.04),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      txt("Team Leader First Name", size: sW * 0.035),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: firstNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(hintText: 'Kartikey'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "First Name cannot be empty";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: sH * 0.02),
                      txt("Team Leader Last Name", size: sW * 0.035),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: lastNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(hintText: 'Patel'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Last Name cannot be empty";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: sH * 0.02),
                      txt("Team Leader Phone Number", size: sW * 0.035),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        maxLength: 10,
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(hintText: '9876543210'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Phone number cannot be empty";
                          }
                          if (!isPhoneNumberValid(value)) {
                            return "Enter a valid 10-digit phone number";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: sH * 0.02),
                      txt("Team Leader College Name", size: sW * 0.035),
                      const SizedBox(height: 8.0),
                      TextFormField(
                        controller: collegeNameController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(hintText: 'VIT, Chennai'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "College Name cannot be empty";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: sH * 0.02),
                      txt("Team Leader Gender", size: sW * 0.035),
                      const SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
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
                            selectedGender = value!;
                          });
                        },
                      ),
                      SizedBox(height: sH * 0.02),
                      txt("External Participant", size: sW * 0.035),
                      const SizedBox(height: 8.0),
                      DropdownButtonFormField<String>(
                        value: selectedExternal,
                        dropdownColor: Colors.grey[900],
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
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
                        decoration:
                            InputDecoration(border: OutlineInputBorder()),
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
                          teamController.setTeamSize(int.parse(value!));
                        },
                      ),
                      SizedBox(height: sH * 0.05),
                    ],
                  ),
                ),
              ),
              NextButton(
                title: "Submit",
                isLoading: isLoading,
                onTapFunction: () async {
                  if (isLoading) return;

                  setState(() => isLoading = true);

                  try {
                    if (_formKey.currentState!.validate()) {
                      String userId = Uuid().v4();
                      String username = UserModel.generateUsername(
                          firstNameController.text, phoneNumberController.text);
                      String password =
                          UserModel.generatePassword(firstNameController.text);

                      // Store user data in UserController
                      userController.setUserData(
                        id: userId,
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        phoneNumber: phoneNumberController.text,
                        collegeName: collegeNameController.text,
                        gender: selectedGender,
                        external: selectedExternal == "True",
                        teamId: teamName,
                        userType: "participant",
                        username: username,
                        password: password,
                      );

                      // Store team data in TeamController
                      teamController.setTeamLeaderId(userId);
                      teamController.addTeamMember(userId);
                      teamController.addTeamMemberDetails(userController.user!);
                      teamController.setTeamSize(int.parse(teamSize));

                      Navigator.pushNamed(
                        context,
                        '/teamMemberPage',
                        arguments: {
                          'teamName': teamName,
                          'teamSize': teamSize,
                        },
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  } finally {
                    if (mounted) {
                      setState(() => isLoading = false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
