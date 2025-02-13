import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/pages/leader_board/leader_board_page.dart';
import 'package:hacknow/pages/participants/participant_team/participant_team_page.dart';
import 'package:hacknow/pages/participants/participants_food/participants_food.dart';
import 'package:hacknow/pages/participants/paticipants_home/paticipants_home_page.dart';

class ParticipantBase extends StatefulWidget {
  @override
  State<ParticipantBase> createState() => _ParticipantBaseState();
}

class _ParticipantBaseState extends State<ParticipantBase> {
  bool isLoading = true;
  bool isCompany = false;
  List _screens = [
    ParticipantHomePage(),
    LeaderBoardPage(),
    FoodScreen(),
    ParticipantTeamDetails(),
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
          canvasColor: CustomColor.secondaryColor,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: CustomColor.lightBlueAccentTextColor,
          unselectedItemColor: CustomColor.secondarySVGColor,
          selectedLabelStyle: TextStyle(
            color: CustomColor.lightBlueAccentTextColor,
          ),
          unselectedLabelStyle: TextStyle(
            color: CustomColor.secondarySVGColor,
          ),
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Leader Board',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: 'Food',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_alt),
              label: 'Team',
            ),
          ],
        ),
      ),
    );
  }
}
