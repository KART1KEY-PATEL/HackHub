import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    setState(() {
      isLoading = true;
    });

    String enteredUsername = userNameController.text.trim();
    String enteredPassword = passwordController.text.trim();

    if (enteredUsername.isEmpty || enteredPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter both username and password.")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    var userBox = await Hive.openBox<UserModel>('userBox');

    try {
      QuerySnapshot usersSnapshot = await firestore.collection("users").get();

      // Searching for the user inside the collection
      for (var doc in usersSnapshot.docs) {
        var userData = doc.data() as Map<String, dynamic>;

        if (userData["username"] == enteredUsername) {
          // Found user, now check password
          if (userData["password"] == enteredPassword) {
            // Successful login, save user data in Hive
            UserModel user = UserModel(
              teamId: "",
              userType: userData["userType"] ?? "admin",
              firstName: userData["firstName"] ?? "",
              lastName: userData["lastName"] ?? "",
              phoneNumber: userData["phoneNumber"] ?? "",
              collegeName: userData["collegeName"] ?? "",
              external: userData["external"] ?? false,
              gender: userData["gender"] ?? "Male",
              username: userData["username"] ?? "",
              password: userData["password"] ?? "",
              approved: true,
              id: userData['id'] ?? "",
            );

            // Store in Hive
            await userBox.put("currentUser", user);

            print("✅ User logged in successfully: ${user.firstName}");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Login successful!")),
            );

            // Navigate to home page after login
            Navigator.pushReplacementNamed(context, '/adminBase');
            return;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Incorrect password!")),
            );
            setState(() {
              isLoading = false;
            });
            return;
          }
        }
      }

      // If loop finishes and no username was found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not found! Please check your username.")),
      );
    } catch (e) {
      print("🔥 Error logging in: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while logging in.")),
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
        title: "Admin Login",
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              obscureText: true, // Hide password
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Enter Password'),
            ),
            SizedBox(height: sH * 0.02),
            NextButton(
              title: isLoading ? "Logging in..." : "Login",
              onTapFunction: loginUser,
            ),
          ],
        ),
      ),
    );
  }
}
