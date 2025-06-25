import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/screens/onboarding/onboarding_screen.dart';
import 'package:farmers_hub/auth_gate.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.fadeIn(
      backgroundColor: splashBackgroundColor,
      // useImmersiveMode: true,
      asyncNavigationCallback: () async {
        // Get shared-prefs data here
        await Future.delayed(const Duration(seconds: 2));

        final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
        final String? lang = await asyncPrefs.getString('language');
        if (context.mounted) {
          if (lang != null) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AuthGate()));
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const OnboardingScreen()),
            );
          }
        }
      },
      childWidget: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
                "images/icons/splash_white.svg",
              semanticsLabel: 'Your Crop icon',
              width: 90,
              height: 104,
            ),
            const SizedBox(height: 20),
            Text(
              "YOUR CROP",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                textStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Buy & Sell Securely Online.",
              style: GoogleFonts.poppins(
                textStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
