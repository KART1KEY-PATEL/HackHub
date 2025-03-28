import 'package:flutter/material.dart';
import 'package:hacknow/constants/custom_color.dart';
import 'package:hacknow/pages/admin/admin_approval/admin_approval_page.dart';
import 'package:hacknow/pages/admin/admin_home/admin_home_page.dart';
import 'package:hacknow/pages/chat_page/chat_page.dart';
import 'package:hacknow/pages/participants/paticipants_home/paticipants_home_page.dart';

class AdminBase extends StatefulWidget {
  @override
  State<AdminBase> createState() => _AdminBaseState();
}

class _AdminBaseState extends State<AdminBase> {
  bool isLoading = true;
  bool isCompany = false;
  List _screens = [
    AdminHomePage(),
    ChatPage(),
    AdminApprovalPage()
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
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check),
              label: 'Approvals',
            ),
          ],
        ),
      ),
    );
  }
}
