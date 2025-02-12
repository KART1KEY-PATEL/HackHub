import 'package:flutter/material.dart';
import 'package:hacknow/controller/user_controller.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:provider/provider.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';

class UserTypeChoose extends StatelessWidget {
  const UserTypeChoose({super.key});

  @override
  Widget build(BuildContext context) {
    var sW = MediaQuery.of(context).size.width;
    var sH = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: customAppBar(title: "Hack-N-Droid", actions: [
        TextButton(
          onPressed: () {
            context.read<UserController>().setUser(
                  UserModel(
                    id: '',
                    password: "",
                    username: "",
                    userType: "volunteer",
                    firstName: "",
                    lastName: "",
                    phoneNumber: "",
                    collegeName: "",
                    external: false,
                    gender: "",
                    approved: false,
                  ),
                );
            Navigator.pushNamed(context, '/volunteerSignupPage');
          },
          child: Text(
            "OC Team",
          ),
        ),
        TextButton(
          onPressed: () {
            context.read<UserController>().setUser(
                  UserModel(
                    id: '',
                    password: "",
                    username: "",
                    userType: "admin",
                    firstName: "",
                    lastName: "",
                    phoneNumber: "",
                    collegeName: "",
                    external: false,
                    gender: "",
                    approved: false,
                  ),
                );
            Navigator.pushNamed(context, '/adminRegisterPage');
          },
          child: Text(
            "admin",
          ),
        ),
      ]),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: sW * 0.02,
          vertical: sH * 0.04,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            txt(
              "Welcome",
              size: sW * 0.1,
            ),
            SizedBox(
              height: sH * 0.02,
            ),
            GestureDetector(
              onTap: () {
                context.read<UserController>().setUser(
                      UserModel(
                        id: '',
                        password: "",
                        username: "",
                        userType: "participant",
                        firstName: "",
                        lastName: "",
                        phoneNumber: "",
                        collegeName: "",
                        external: false,
                        approved: true,
                        gender: "",
                      ),
                    );
                Navigator.pushNamed(context, '/teamLeaderPage');
              },
              child: Container(
                height: sH * 0.2,
                width: sW,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: CustomColor.secondaryColor,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: CustomColor.primarySVGColor,
                      size: sW * 0.3,
                    ),
                    SizedBox(
                      width: sW * 0.04,
                    ),
                    txt(
                      "Team Leader",
                      size: sW * 0.05,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: sH * 0.02,
            ),
            GestureDetector(
              onTap: () {
                // context.read<UserController>().setUserTypeAsParticipant();
                context.read<UserController>().setUser(
                      UserModel(
                        id: '',
                        password: "",
                        username: "",
                        userType: "participant",
                        firstName: "",
                        approved: true,
                        lastName: "",
                        phoneNumber: "",
                        collegeName: "",
                        external: false,
                        gender: "",
                      ),
                    );
                Navigator.pushNamed(context, '/teamMemberLoginPage');
              },
              child: Container(
                height: sH * 0.2,
                width: sW,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: CustomColor.secondaryColor,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: CustomColor.primarySVGColor,
                      size: sW * 0.3,
                    ),
                    SizedBox(
                      width: sW * 0.04,
                    ),
                    txt(
                      "Team Members",
                      size: sW * 0.05,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
