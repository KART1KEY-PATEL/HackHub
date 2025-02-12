import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  State<AdminRegisterPage> createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController collegeNameController = TextEditingController();
  TextEditingController adminKeyController = TextEditingController();
  String selectedGender = 'Male';
  String selectedExternal = 'False';

  Future<void> signUpVolunteer() async {
    setState(() {
      isLoading = true;
    });

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var userBox = await Hive.openBox<UserModel>('userBox');

    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String phoneNumber = phoneNumberController.text.trim();
    String username = userNameController.text.trim();
    String password = passwordController.text.trim();
    String enteredAdminKey = adminKeyController.text.trim();

    // Fetch Admin Key from Firestore settings collection
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection("settings").get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception("Admin Key not found in Firestore");
      }

      // Assume only one document exists, retrieve the first one
      var adminDoc = querySnapshot.docs.first;
      String storedAdminKey = adminDoc["adminKey"];
      print("Stored Admin Key: ${storedAdminKey}");
      // Compare the entered key with the stored key
      if (enteredAdminKey != storedAdminKey) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Invalid Admin Key!")),
        );
        setState(() {
          isLoading = false;
        });
        return;
      }

      String userId = Uuid().v4(); // Generate a unique ID

      // Create a new admin entry in Firestore
      await firestore.collection("users").doc(userId).set({
        "id": userId,
        "firstName": firstName,
        "lastName": lastName,
        "phoneNumber": phoneNumber,
        "collegeName": "VIT, Chennai",
        "gender": selectedGender,
        "external": selectedExternal == "True",
        "userType": "admin",
        "username": username,
        "password": password,
        "approved": true,
      });

      // Store in Hive for session management
      UserModel user = UserModel(
        approved: true,
        id: userId,
        userType: "admin",
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

      print("✅ Admin signed up successfully: ${user.firstName}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Admin Sign-Up Successful!")),
      );

      // Navigate to home page or dashboard
      Navigator.pushReplacementNamed(context, '/approvalPage');
    } catch (e) {
      print("🔥 Error: $e");
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
        title: "Admin Sign Up Page",
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
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
            txt("Admin Key", size: sW * 0.035),
            const SizedBox(height: 8.0),
            TextField(
              controller: adminKeyController,
              obscureText: true,
              style: TextStyle(color: Colors.white),
              decoration:
                  InputDecoration(hintText: 'Enter admin shared by Kartikey'),
            ),
            SizedBox(height: sH * 0.02),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/adminLoginPage');
                },
                child: Text("Admin Login")),
            NextButton(
              title: isLoading ? "Signing Up..." : "Sign Up",
              onTapFunction: signUpVolunteer,
            ),
          ],
        ),
      ),
    );
  }
}
