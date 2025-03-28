import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class VolunteerSignupPage extends StatefulWidget {
  const VolunteerSignupPage({super.key});

  @override
  State<VolunteerSignupPage> createState() => _VolunteerSignupPageState();
}

class _VolunteerSignupPageState extends State<VolunteerSignupPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController collegeNameController = TextEditingController();
  String selectedGender = 'Male';
  String selectedExternal = 'False';

  Future<void> signUpVolunteer() async {
    setState(() {
      isLoading = true;
    });

    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    String collegeName = collegeNameController.text.trim();
    String username = userNameController.text.trim();
    String password = passwordController.text.trim();

    // if (firstName.isEmpty ||
    //     lastName.isEmpty ||
    //     phoneNumber.isEmpty ||
    //     username.isEmpty ||
    //     password.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("Please fill in all fields.")),
    //   );
    //   setState(() {
    //     isLoading = false;
    //   });
    //   return;
    // }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var userBox = await Hive.openBox<UserModel>('userBox');
    String userId = Uuid().v4(); // Generate a unique ID

    try {
      // Create a new volunteer entry in Firestore
      await firestore.collection("users").doc(userId).set({
        "id": userId,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "collegeName": "VIT, Chennai",
        "gender": selectedGender,
        "external": selectedExternal == "True",
        "userType": "volunteer",
        "username": username,
        "password": password,
        "approved": false,
      });

      // Store in Hive for session management
      UserModel user = UserModel(
        teamId: "",
        approved: false,
        id: userId,
        userType: "volunteer",
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        collegeName: "VIT, Chennai",
        external: selectedExternal == "True",
        gender: selectedGender,
        username: username,
        password: password,
      );
      await userBox.put("currentUser", user);

      print("✅ Volunteer signed up successfully: ${user.firstName}");
      print("✅ User stored in Hive:");
      print("First Name: ${userBox.get('currentUser')?.firstName}");
      print("Last Name: ${userBox.get('currentUser')?.lastName}");
      print("Phone Number: ${userBox.get('currentUser')?.phoneNumber}");
      print("College: ${userBox.get('currentUser')?.collegeName}");
      print("Username: ${userBox.get('currentUser')?.username}");
      print("Password: ${userBox.get('currentUser')?.password}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Volunteer Sign-Up Successful!")),
      );

      // Navigate to home page or dashboard
      Navigator.pushReplacementNamed(context, '/approvalPage');
    } catch (e) {
      print("🔥 Error signing up: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing up. Please try again.")),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: customAppBar(
        title: "Volunteer Sign Up Page",
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              txt("First Name", size: sW * 0.035),
              const SizedBox(height: 8.0),
              TextField(
                controller: firstNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Enter First Name'),
              ),
              SizedBox(height: sH * 0.02),
              txt("Last Name", size: sW * 0.035),
              const SizedBox(height: 8.0),
              TextField(
                controller: lastNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Enter Last Name'),
              ),
              SizedBox(height: sH * 0.02),
              txt("Phone Number", size: sW * 0.035),
              const SizedBox(height: 8.0),
              TextField(
                controller: phoneNumberController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Enter Phone Number'),
              ),
              SizedBox(height: sH * 0.02),
              txt("Username", size: sW * 0.035),
              const SizedBox(height: 8.0),
              TextField(
                controller: userNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Enter Username'),
              ),
              SizedBox(height: sH * 0.02),
              txt("Password", size: sW * 0.035),
              const SizedBox(height: 8.0),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(hintText: 'Enter Password'),
              ),
              SizedBox(height: sH * 0.02),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/volunteerLoginPage');
                  },
                  child: Text("Volunteer Login")),
              NextButton(
                title: isLoading ? "Signing Up..." : "Sign Up",
                onTapFunction: signUpVolunteer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
