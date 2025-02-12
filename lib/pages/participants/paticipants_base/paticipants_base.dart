import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/pages/participants/participant_team/participant_team_page.dart';
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
    ParticipantTeamDetails(),
    ParticipantTeamDetails(),
    ParticipantTeamDetails(),
    ParticipantTeamDetails(),
    // StorePage(),
    // TrainingPage(),
    // UpdatePage(),
    // ProfilePage()
  ];
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    double sH = MediaQuery.of(context).size.height;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: new Theme(
        data: Theme.of(context).copyWith(
          // sets the background color of the `BottomNavigationBar`
          canvasColor: CustomColor.secondaryColor,
          // sets the active color of the `BottomNavigationBar` if `Brightness` is light
          // primaryColor: Colors.red,
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          // backgroundColor: CustomColor.primaryBottomNavBar,
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
              icon: Icon(Icons.abc),
              label: '',
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
      // body: BlocListener<UserBloc, UserState>(
      //   listener: (context, state) {
      //     // if (state.user != null) {
      //       print("UserBloc listener called : ${state.isCompany}");
      //       setState(() {
      //         isLoading = false;
      //         isCompany = state.isCompany;

      //       });
      //     // }
      //   },
      //   child: BlocBuilder<UserBloc, UserState>(
      //     builder: (context, state) {
      //       if (isLoading) {
      //         return Center(child: CircularProgressIndicator());
      //       } else {
      //         return PersistentTabView(
      //           tabs: [
      //             PersistentTabConfig(
      //               screen: isCompany ? CompanyHomePage() : UserHomePage(),
      //               item: ItemConfig(
      //                 icon: Icon(
      //                   Icons.home,
      //                   size: 32,
      //                 ),
      //               ),
      //             ),
      //             PersistentTabConfig(
      //               screen: isCompany ? CompanyLike() : UserLike(),
      //               item: ItemConfig(
      //                 icon: Icon(
      //                   Icons.favorite,
      //                   size: 32,
      //                 ),
      //               ),
      //             ),
      //             PersistentTabConfig(
      //               screen: isCompany ? CompanyChat() : UserChat(),
      //               item: ItemConfig(
      //                 icon: Icon(
      //                   Icons.chat_bubble,
      //                   size: 32,
      //                 ),
      //               ),
      //             ),
      //             PersistentTabConfig(
      //               screen:
      //                   isCompany ? CompanyProfilePage() : UserProfilePage(),
      //               item: ItemConfig(
      //                 icon: Icon(
      //                   Icons.person,
      //                   size: 32,
      //                 ),
      //               ),
      //             ),
      //           ],
      //           navBarBuilder: (navBarConfig) => CustomNavBar(
      //             navBarDecoration: const NavBarDecoration(
      //               borderRadius: BorderRadius.only(
      //                 topLeft: Radius.circular(20),
      //                 topRight: Radius.circular(20),
      //               ),
      //               color: CustomColor.primaryBottomNavBar,
      //               padding: EdgeInsets.only(
      //                 top: 10,
      //                 bottom: 5,
      //               ),
      //             ),
      //             navBarConfig: navBarConfig,
      //           ),
      //         );
      //       }
      //     },
      //   ),
      // ),
    );
  }
}
