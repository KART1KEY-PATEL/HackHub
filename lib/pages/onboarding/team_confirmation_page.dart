import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/controller/team_controller.dart';
import 'package:hacknow/controller/user_controller.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/services/login_service.dart';
import 'package:hacknow/utils/constant_text_field.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/next_button.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

class TeamConfirmationPage extends StatefulWidget {
  const TeamConfirmationPage({super.key});

  @override
  State<TeamConfirmationPage> createState() => _TeamConfirmationPageState();
}

class _TeamConfirmationPageState extends State<TeamConfirmationPage> {
  LoginService _service = LoginService();
  bool isLoading = false;

  Future<void> _handleConfirmation() async {
    if (isLoading) return;

    UserController userController =
        Provider.of<UserController>(context, listen: false);
    TeamController teamController =
        Provider.of<TeamController>(context, listen: false);

    setState(() => isLoading = true);

    try {
      // Create user document
      var userBox = Hive.box<UserModel>('userBox');
      userBox.put("currentUser", userController.user!);

      // Create/update team document
      await _service.createOrUpdateTeam(
        teamName: teamController.teamName!,
        teamLeaderId:
            userController.user!.id, // Assuming user ID is the leader ID
        teamMembers: teamController.teamMembers,
        teamSize: teamController.teamSize,
      );

      // Create food records for all team members
      for (int i = 0; i < teamController.teamSize; i++) {
        await _service.createUser(user: teamController.teamMemberDetails[i]);
        await _service.createFoodRecord(teamController.teamMembers[i]);
      }

      // Navigate to next screen on success
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/teamDetails',
        (route) => false,
        arguments: {"teamName": teamController.teamName},
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserController userController =
        Provider.of<UserController>(context, listen: false);
    TeamController teamController =
        Provider.of<TeamController>(context, listen: false);
    var sW = MediaQuery.of(context).size.width;

    var sH = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: customAppBar(title: "Team Confirmation Page"),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: sW * 0.02,
            vertical: sH * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  txt(
                    "Team name: ",
                    size: sW * 0.04,
                    weight: FontWeight.w500,
                  ),
                  txt(
                    "${teamController.teamName}",
                    size: sW * 0.045,
                    weight: FontWeight.w700,
                  ),
                ],
              ),
              SizedBox(
                height: sH * 0.02,
              ),
              Container(
                // height: sH * 0.36,
                decoration: BoxDecoration(
                  color: CustomColor.secondaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: sW * 0.02,
                  vertical: sH * 0.02,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: sW * 0.02,
                    vertical: sH * 0.0,
                  ),
                  // decoration: BoxDecoration(
                  //   color: CustomColor.primaryColor,
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ContantTextField(
                          showTitle: true,
                          title: "Leader's Name",
                          defaultText:
                              "${userController.user!.firstName} ${userController.user!.lastName}",
                        ),
                        SizedBox(
                          height: sH * 0.01,
                        ),
                        ContantTextField(
                          showTitle: true,
                          title: "Leader's Phone Number",
                          defaultText: "${userController.user!.phoneNumber}",
                        ),
                        SizedBox(
                          height: sH * 0.01,
                        ),
                        ContantTextField(
                          showTitle: true,
                          title: "Leader's Gender",
                          defaultText: "${userController.user!.gender}",
                        ),
                        SizedBox(
                          height: sH * 0.01,
                        ),
                        ContantTextField(
                          showTitle: true,
                          title: "Leader's College Name",
                          defaultText: "${userController.user!.collegeName}",
                        ),
                      ]),
                ),
              ),
              SizedBox(
                height: sH * 0.02,
              ),
              ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return index != 0
                        ? Container(
                            // height: sH * 0.36,
                            decoration: BoxDecoration(
                              color: CustomColor.secondaryColor,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: sW * 0.02,
                              vertical: sH * 0.02,
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: sW * 0.02,
                                vertical: sH * 0.0,
                              ),
                              // decoration: BoxDecoration(
                              //   color: CustomColor.primaryColor,
                              //   borderRadius: BorderRadius.circular(12),
                              // ),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ContantTextField(
                                      showTitle: true,
                                      title: "Member's Name ${index}",
                                      defaultText:
                                          "${teamController.teamMemberDetails[index].firstName}",
                                    ),
                                    SizedBox(
                                      height: sH * 0.01,
                                    ),
                                    ContantTextField(
                                      showTitle: true,
                                      title: "Member's Phone Number ${index}",
                                      defaultText:
                                          "${teamController.teamMemberDetails[index].phoneNumber}",
                                    ),
                                    SizedBox(
                                      height: sH * 0.01,
                                    ),
                                    ContantTextField(
                                      showTitle: true,
                                      title: "Member's Gender ${index + 1}",
                                      defaultText:
                                          "${teamController.teamMemberDetails[index].gender}",
                                    ),
                                  ]),
                            ),
                          )
                        : SizedBox();
                  },
                  separatorBuilder: (context, index) {
                    return SizedBox(
                      height: sH * 0.02,
                    );
                  },
                  itemCount: teamController.teamSize),
              SizedBox(
                height: sH * 0.02,
              ),
              // NextButton(
              //   title: "Confirm",
              //   onTapFunction: () {
              //     _service.createUser(user: userController.user!);
              //     _service.createOrUpdateTeam(
              //       teamName: teamController.teamName!,
              //       teamLeaderId: teamController.teamName!,
              //       teamMembers: teamController.teamMembers,
              //       teamSize: teamController.teamSize,
              //     );
              //     for (int i = 0; i < teamController.teamSize; i++) {
              //       _service.createFoodRecord(teamController.teamMembers[i]);
              //     }
              //     // Navigator.pushNamedAndRemoveUntil(
              //     //   context,
              //     //   '/teamDetails',
              //     //   (route) => false, // This removes all previous routes
              //     //   arguments: {"teamName": teamController.teamName},
              //     // );
              //   },
              // )
              NextButton(
                  title: isLoading ? "Processing..." : "Confirm",
                  onTapFunction: () async {
                    if (isLoading) {
                      print("Fall back ");
                      return;
                    }
                    await _handleConfirmation();
                  })
            ],
          ),
        ),
      ),
    );
  }
}
