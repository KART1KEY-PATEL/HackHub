import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:hive/hive.dart';

class ParticipantTeamDetails extends StatefulWidget {
  const ParticipantTeamDetails({super.key});

  @override
  State<ParticipantTeamDetails> createState() => _ParticipantTeamDetailsState();
}

class _ParticipantTeamDetailsState extends State<ParticipantTeamDetails> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> teamMembersDetails = [];
  bool isLoading = true;
  String? teamName;

  @override
  void initState() {
    super.initState();
    _fetchTeamName();
  }

  Future<void> _fetchTeamName() async {
    var teamBox = Hive.box('teamBox');

    // Fetch team name from Hive
    String? fetchedTeamName = teamBox.get('teamName');

    if (fetchedTeamName != null) {
      setState(() {
        teamName = fetchedTeamName;
      });

      await fetchParticipantTeamDetails(); // Fetch team details only after team name is available
    } else {
      print("Error: Team name not found in Hive.");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchParticipantTeamDetails() async {
    if (teamName == null) {
      print("Error: Team name is null.");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      // Get the team document from Firestore
      DocumentSnapshot teamSnapshot =
          await firestore.collection("teams").doc(teamName).get();

      if (teamSnapshot.exists) {
        var teamData = teamSnapshot.data() as Map<String, dynamic>;
        List<dynamic> teamMemberIds = teamData['teamMembers'] ?? [];

        List<Map<String, dynamic>> membersList = [];

        // Fetch user details for each member
        for (var memberId in teamMemberIds) {
          DocumentSnapshot userSnapshot =
              await firestore.collection("users").doc(memberId).get();

          if (userSnapshot.exists) {
            var userData = userSnapshot.data() as Map<String, dynamic>;

            membersList.add({
              "name": "${userData["firstName"]} ${userData["lastName"]}",
              "username": userData["username"],
              "password": userData["password"],
            });
          }
        }

        setState(() {
          teamMembersDetails = membersList;
          isLoading = false;
        });
      } else {
        print("Error: Team document does not exist.");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching team details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: customAppBar(
          title: teamName != null ? "$teamName Details" : "Team Details",
          actions: [
            IconButton(
              onPressed: () async {
                var userBox = Hive.box<UserModel>('userBox');
                await userBox.clear();
                Navigator.pushNamed(context, '/');
              },
              icon: Icon(
                Icons.logout,
              ),
            ),
          ]),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : teamMembersDetails.isEmpty
              ? const Center(child: Text("No team members found."))
              : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: sH * 0.01,
                            );
                          },
                          itemCount: teamMembersDetails.length,
                          itemBuilder: (context, index) {
                            var member = teamMembersDetails[index];

                            return Stack(
                              children: [
                                Container(
                                  // height: sH * 0.,
                                  padding: EdgeInsets.all(10),
                                  width: sW,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: CustomColor.secondaryColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // SizedBox(
                                          //   height: sH * 0.02,
                                          // ),
                                          txt("Name: ${member["name"]}",
                                              size: sW * 0.05, isBold: true),
                                          txt(
                                            "Username: ${member["username"]}",
                                            size: sW * 0.04,
                                          ),
                                          txt(
                                            "Password: ${member["password"]}",
                                            size: sW * 0.04,
                                          ),
                                        ],
                                      ),
                                      Spacer(),
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: sH * 0.02,
                                          ),
                                          Icon(
                                            Icons.person,
                                            size: sW * 0.2,
                                            color:
                                                CustomColor.primaryButtonColor,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? Colors.red
                                          : CustomColor.secondaryButtonColor,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: sW * 0.03,
                                      vertical: sH * 0.004,
                                    ),
                                    child: txt(
                                      index == 0
                                          ? "Team Leader"
                                          : "Team Members",
                                      size: sH * 0.018,
                                      color: index == 0
                                          ? Colors.white
                                          : Colors.black,
                                      isBold: true,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
