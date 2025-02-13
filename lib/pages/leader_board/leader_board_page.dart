import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/utils/custom_app_bar.dart';
import 'package:hacknow/utils/text_util.dart';

class LeaderBoardPage extends StatefulWidget {
  const LeaderBoardPage({super.key});

  @override
  State<LeaderBoardPage> createState() => _LeaderBoardPageState();
}

class _LeaderBoardPageState extends State<LeaderBoardPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchScores() async {
    QuerySnapshot scoresSnapshot = await _firestore.collection('Scores').get();

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

    return teams;
  }

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;
    double sW = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: customAppBar(
        title: ('Leaderboard'),
        // centerTitle: true,s
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchScores(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No teams available'));
            }

            List<Map<String, dynamic>> teams = snapshot.data!;

            return ListView.separated(
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: sH * 0.02,
                );
              },
              itemCount: teams.length,
              itemBuilder: (context, index) {
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
                          '${index + 1}',
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
              },
            );
          },
        ),
      ),
    );
  }
}
