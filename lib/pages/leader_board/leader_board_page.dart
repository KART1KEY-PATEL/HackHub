import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({super.key});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchScores() async {
    QuerySnapshot scoresSnapshot = await _firestore.collection('scores').get();

    List<Map<String, dynamic>> teams = [];

    for (var doc in scoresSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;

      int totalScore = (data['Creativity'] ?? 0) +
          (data['Scalability'] ?? 0) +
          (data['Technical Implementation'] ?? 0) +
          (data['UI/UX'] ?? 0) +
          (data['Uniqueness'] ?? 0);

      teams.add({'name': doc.id, 'totalScore': totalScore});
    }

    teams.sort((a, b) => b['totalScore'].compareTo(a['totalScore']));

    // Assign positions
    for (int i = 0; i < teams.length; i++) {
      teams[i]['position'] = i + 1;
    }

    return teams;
  }

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(
        title: ('Leaderboard'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('settings').doc('settings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: txt('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: txt('Settings not found'));
          }

          var settings = snapshot.data!.data() as Map<String, dynamic>;
          bool showLeaderBoard = settings['leaderBoard'] ?? false;
          bool showFullLeaderBoard = settings['showFullLeaderBoard'] ?? false;
          bool showFirst = settings['first'] ?? false;
          bool showSecond = settings['second'] ?? false;
          bool showThird = settings['third'] ?? false;

          if (!showLeaderBoard) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: sH * 0.1,
                    child: LoadingIndicator(
                        indicatorType: Indicator.pacman,

                        /// Required, The loading type of the widget
                        colors: const [Colors.white],

                        /// Optional, The color collections
                        strokeWidth: 2,

                        /// Optional, The stroke of the line, only applicable to widget which contains line
                        // backgroundColor: Colors.black,

                        /// Optional, Background of the widget
                        pathBackgroundColor: Colors.black

                        /// Optional, the stroke backgroundColor
                        ),
                  ),
                  SizedBox(
                    height: sH * 0.02,
                  ),
                  txt(
                    'Wait for the result annoucemnts!!',
                    size: sW * 0.05,
                    isBold: true,
                  ),
                ],
              ),
            );
          }
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchScores(),
            builder: (context, leaderboardSnapshot) {
              if (leaderboardSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (leaderboardSnapshot.hasError) {
                return Center(
                    child: Text('Error: ${leaderboardSnapshot.error}'));
              }
              if (!leaderboardSnapshot.hasData ||
                  leaderboardSnapshot.data!.isEmpty) {
                return Center(child: txt('No teams available'));
              }

              List<Map<String, dynamic>> teams = leaderboardSnapshot.data!;

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showSecond && teams.length >= 2)
                        _buildPositionCard('2nd Place', teams[1]['name'], sW,
                            sH, teams[1]['position']),
                      if (showFirst && teams.length >= 1)
                        _buildPositionCard('1st Place', teams[0]['name'], sW,
                            sH, teams[0]['position']),
                      if (showThird && teams.length >= 3)
                        _buildPositionCard('3rd Place', teams[2]['name'], sW,
                            sH, teams[2]['position']),
                    ],
                  ),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: sH * 0.02,
                        );
                      },
                      itemCount: (teams.length <= 20) ? teams.length : 20,
                      itemBuilder: (context, index) {
                        if (index == 0 || index == 1 || index == 2) {
                          return SizedBox();
                        } else {
                          if (showFullLeaderBoard) {
                            return Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CustomColor.secondaryColor,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    child: txt(
                                      '${teams[index]['position']}', // Display position
                                      size: sW * 0.05,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(
                                    width: sW * 0.02,
                                  ),
                                  txt(
                                    teams[index]['name'],
                                    size: sW * 0.04,
                                    isBold: true,
                                  ),
                                ],
                              ),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPositionCard(
    String title,
    String teamName,
    double sW,
    double sH,
    int position,
  ) {
    return Stack(
      children: [
        Container(
          width: sW * 0.28,
          height: position == 1
              ? sH * 0.31
              : position == 2
                  ? sH * 0.27
                  : sH * 0.24,
          margin: EdgeInsets.symmetric(vertical: sH * 0.01),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: position == 3 ? Radius.circular(0) : Radius.circular(20),
              topRight:
                  position == 2 ? Radius.circular(0) : Radius.circular(20),
              bottomLeft: position == 3 || position == 1
                  ? Radius.circular(0)
                  : Radius.circular(20),
              bottomRight: position == 2 || position == 1
                  ? Radius.circular(0)
                  : Radius.circular(20),
            ),
            color: CustomColor.secondaryColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                position == 1
                    ? "assets/gold_medal.png"
                    : position == 2
                        ? "assets/second_medal.png"
                        : "assets/broze_medal.png",
                height: sH * 0.1,
              ),
              Spacer(),
              txt(
                "${title}",
                size: sW * 0.05,
                // isBold: true,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              txt(
                teamName,
                maxLine: 1,
                size: sW * 0.035,
                isBold: true,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
