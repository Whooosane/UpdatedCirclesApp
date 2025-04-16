import 'dart:async';
import 'package:circleapp/controller/utils/app_colors.dart';
import 'package:circleapp/view/check_invitation.dart';
import 'package:circleapp/view/screens/athentications/login_screen.dart';
import 'package:circleapp/view/screens/bottom_navigation_screen.dart';
import 'package:flutter/material.dart';
import '../../controller/utils/preference_keys.dart';
import '../../controller/utils/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateToNextScreen();
  }

  void navigateToNextScreen() {
    Timer(const Duration(seconds: 3), () {
      final bool isLoggedIn = MySharedPreferences.getBool(isLoggedInKey);
      final bool isSignedUp = MySharedPreferences.getBool(isSignedUpKey);

      if (isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavigationScreen()),
        );
      } else if (isSignedUp) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CheckInvitationScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardFieldColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Add your app logo or loading animation here
            Image.asset(
              'assets/png/logo.png',
            ),
          ],
        ),
      ),
    );
  }
}
