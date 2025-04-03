import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';

class TeamMemberLoginPage extends StatefulWidget {
  const TeamMemberLoginPage({super.key});

  @override
  State<TeamMemberLoginPage> createState() => _TeamMemberLoginPageState();
}

class _TeamMemberLoginPageState extends State<TeamMemberLoginPage> {
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
    final Box teamBox = Hive.box('teamBox');

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
              teamId: userData["teamId"] ?? "",
              userType: userData["userType"] ?? "participant",
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
            if (user.userType == "participant") {
              if (user.teamId.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("No team assigned! Contact support.")),
                );
                setState(() => isLoading = false);
                return;
              }

              DocumentSnapshot teamSnapshot =
                  await firestore.collection('teams').doc(user.teamId).get();

              if (!teamSnapshot.exists) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Team not found in registry!")),
                );
                setState(() => isLoading = false);
                return;
              }

              bool isRegistered = teamSnapshot['registered'] ?? false;
              if (!isRegistered) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "Team not registered! Please have your team leader scan the QR code at registration desk."),
                    duration: Duration(seconds: 5),
                  ),
                );
                setState(() => isLoading = false);
                return;
              }
            }
            // Store in Hive
            await userBox.put("currentUser", user);

            teamBox.put('teamName', user.teamId);

            print("✅ User logged in successfully: ${user.firstName}");

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Login successful!")),
            );

            // Navigate to home page after login
            Navigator.pushReplacementNamed(context, '/participantBase');
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
        title: "Team Member Login",
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            txt("Team Member Username", size: sW * 0.035),
            const SizedBox(height: 8.0),
            TextField(
              controller: userNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(hintText: 'Enter Username'),
            ),
            SizedBox(height: sH * 0.02),
            txt("Team Member Password", size: sW * 0.035),
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
