import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
      body: Padding(
        padding: EdgeInsets.symmetric(
            // horizontal: sW * 0.02,
            // vertical: sH * 0.04,
            ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: sH * 0.22,
            ),
            Center(
                child: Image.asset("assets/splash_logo.png",
                    height: 120)), // App Logo
            SizedBox(
              height: sH * 0.02,
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 30,
              ),
              width: sW,
              height: sH * 0.45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: CustomColor.secondaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  txt(
                    "Welcome To",
                    size: sH * 0.045,
                    weight: FontWeight.w500,
                  ),
                  txt(
                    "Hack-N-Droid",
                    size: sH * 0.045,
                    color: CustomColor.primaryButtonColor,
                    weight: FontWeight.w700,
                  ),
                  SizedBox(
                    height: sH * 0.01,
                  ),
                  txt(
                    "A place to hack and win the glory of the hackathon hehe hehe hehe",
                    size: sH * 0.018,
                    // color: CustomColor.,
                    // weight: FontWeight.w500,
                  ),
                  SizedBox(
                    height: sH * 0.03,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: CustomColor.primaryButtonColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(30)),
                    // height:,
                    child: Row(
                      children: [
                        InkWell(
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
                            decoration: BoxDecoration(
                              color: CustomColor.primaryButtonColor,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: sW * 0.07, vertical: sH * 0.012),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/leader.svg', // Path to your SVG
                                  width: sW * 0.07, // Adjust size
                                  height: sW * 0.07,
                                  fit: BoxFit.contain, // Ensure proper scaling
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: sW * 0.02,
                                ),
                                txt(
                                  "Team Leader",
                                  size: sW * 0.04,
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
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
                            Navigator.pushNamed(
                                context, '/teamMemberLoginPage');
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/member.svg', // Path to your SVG
                                  width: sW * 0.07, // Adjust size
                                  height: sW * 0.07,
                                  fit: BoxFit.contain, // Ensure proper scaling
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: sW * 0.02,
                                ),
                                txt(
                                  "Team Member",
                                  size: sW * 0.04,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: sH * 0.054,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      txt(
                        "Are you a member of organizing committee? ",
                        size: sW * 0.03,
                      ),
                      InkWell(
                        onTap: () {
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
                        child: txt("OC SignUp",
                            size: sW * 0.035,
                            color: CustomColor.primaryButtonColor,
                            isBold: true),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      txt(
                        "Are you the admin? ",
                        size: sW * 0.03,
                      ),
                      InkWell(
                        onTap: () {
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
                        child: txt("Admin SignUp",
                            size: sW * 0.035,
                            color: CustomColor.primaryButtonColor,
                            isBold: true),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
