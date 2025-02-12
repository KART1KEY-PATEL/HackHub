import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hacknow/controller/base_controller.dart';
import 'package:hacknow/controller/user_controller.dart';
import 'package:hacknow/firebase_options.dart';
import 'package:hacknow/model/user_model.dart';
import 'package:hacknow/pages/admin/admin_base/admin_base.dart';
import 'package:hacknow/pages/onboarding/admin_login_page.dart';
import 'package:hacknow/pages/onboarding/admin_register_page.dart';
import 'package:hacknow/pages/onboarding/approval_page.dart';
import 'package:hacknow/pages/onboarding/team_approval_page.dart';
import 'package:hacknow/pages/onboarding/volunteer_login_page.dart';
import 'package:hacknow/pages/onboarding/volunteer_signup_page.dart';
import 'package:hacknow/pages/participants/participants_food/participants_food.dart';
import 'package:hacknow/pages/participants/participants_food/qr_results_page.dart';
import 'package:hacknow/pages/participants/paticipants_base/paticipants_base.dart';
import 'package:hacknow/pages/onboarding/login_page.dart';
import 'package:hacknow/pages/onboarding/splash_screen.dart';
import 'package:hacknow/pages/onboarding/team_details.dart';
import 'package:hacknow/pages/onboarding/team_member_login.dart';
import 'package:hacknow/pages/onboarding/team_member_register_page.dart';
import 'package:hacknow/pages/onboarding/team_leader_register_page.dart';
import 'package:hacknow/pages/onboarding/user_type.dart';
import 'package:hacknow/pages/participants/paticipants_home/paticipants_home_page.dart';
import 'package:hacknow/pages/volunteer/volunteer_base/volunteer_base.dart';
import 'package:hacknow/widgets/participant_qr_page.dart';
import 'package:hacknow/pages/volunteer/volunteer_food/volunteer_food.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter()); // Register adapter
  await Hive.openBox<UserModel>('userBox'); // Open user box
  await Hive.openBox('teamBox');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => SelectedIndexNotifier()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1A1A24),
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
          primary: const Color(0xFF4362FF),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF4362FF),
          textTheme: ButtonTextTheme.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF282932),
          hintStyle: const TextStyle(
            color: Color(0xFF5A5A5A),
            fontSize: 18.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
                color: Color(0xff64666F)), // Default border color
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
                color: Color(0xff64666F)), // Enabled border color
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Color(0xff64666F),
            ),
          ),
          labelStyle: const TextStyle(color: Color(0xFFFFFFFF)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A24),
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFFFFFFF),
          selectionColor: Color(0xFF4362FF),
          selectionHandleColor: Color(0xFF4362FF),
        ),
        fontFamily: 'PlusJakartaSans',
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/': (context) => UserTypeChoose(),
        '/teamLeaderPage': (context) => TeamLeaderPage(),
        '/teamRegisterPage': (context) => TeamRegisterPage(),
        '/teamMemberPage': (context) => TeamMemberPage(),
        '/teamDetails': (context) => TeamDetails(),
        '/teamMemberLoginPage': (context) => TeamMemberLoginPage(),
        '/participantBase': (context) => ParticipantBase(),
        '/volunteerSignupPage': (context) => VolunteerSignupPage(),
        '/approvalPage': (context) => ApprovalPage(),
        '/adminRegisterPage': (context) => AdminRegisterPage(),
        '/adminBase': (context) => AdminBase(),
        '/adminLoginPage': (context) => AdminLoginPage(),
        '/volunteerLoginPage': (context) => VolunteerLoginPage(),
        '/volunteerBase': (context) => VolunteerBase(),
        '/participantQrPage': (context) => ParticipantQrPage(),
        '/participantFood': (context) => FoodScreen(),
        "/participantHomePage": (context)=>ParticipantHomePage(),
        "/volunteer_food_qr": (context)=>VolunteerFood()
      },
    );
  }
}
