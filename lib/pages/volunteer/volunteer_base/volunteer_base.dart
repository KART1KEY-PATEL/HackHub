import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/pages/admin/admin_approval/admin_approval_page.dart';
import 'package:hacknow/pages/admin/admin_home/admin_home_page.dart';
import 'package:hacknow/pages/participants/paticipants_home/paticipants_home_page.dart';
import 'package:hacknow/pages/volunteer/volunteer_home/volunteer_home_page.dart';
import 'package:hacknow/pages/volunteer/volunteer_registration_desk/volunteer_registration_desk_page.dart';

class VolunteerBase extends StatefulWidget {
  @override
  State<VolunteerBase> createState() => _VolunteerBaseState();
}

class _VolunteerBaseState extends State<VolunteerBase> {
  bool isLoading = true;
  bool isCompany = false;
  List _screens = [
    VolunteerHomePage(),
    VolunteerRegistrationDeskPage()
    // StorePage(),
    // TrainingPage(),
    // UpdatePage(),
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
              icon: Icon(Icons.person),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check),
              label: 'Approvals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.abc),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.abc),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.abc),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
