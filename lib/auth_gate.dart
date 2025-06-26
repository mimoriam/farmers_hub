import 'package:farmers_hub/screens/signup/signup_google_screen.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/screens/login/login_screen.dart';
import 'package:farmers_hub/screens/home/home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<User?>(
      stream: firebaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // return const Scaffold(body: Center(child: CircularProgressIndicator(color: onboardingColor)));

          // return const Scaffold(
          //   body: Center(
          //     child: Skeletonizer(
          //       ignorePointers: true,
          //       child: Column(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           // CircularProgressIndicator(),
          //           SizedBox(height: 10), Text("Loading...")],
          //       ),
          //     ),
          //   ),
          // );

          return Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(width: 20.0, height: 100.0),
                  const Text(
                    'Your',
                    style: TextStyle(fontSize: 43.0),
                  ),
                  const SizedBox(width: 20.0, height: 100.0),
                  DefaultTextStyle(
                    style: const TextStyle(
                      fontSize: 40.0,
                      fontFamily: 'Horizon',
                    ),
                    child: AnimatedTextKit(
                      animatedTexts: [
                        RotateAnimatedText('CROP'),
                        RotateAnimatedText('HUB'),
                      ],
                      totalRepeatCount: 4,
                      pause: const Duration(milliseconds: 4000),
                      displayFullTextOnTap: true,
                      stopPauseOnTap: true,
                      onTap: () {
                        print("Tap Event");
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          // TODO: Check if user has completed registration properly and do not return him to Home if not
          return FutureBuilder<bool>(
            future: firebaseService.checkIfUserDataExistsForSocialLogin(user: snapshot.data!),
            builder: (context, userExistsSnapshot) {
              if (userExistsSnapshot.connectionState == ConnectionState.waiting) {
                // return const Scaffold(body: Center(child: CircularProgressIndicator(color: onboardingColor)));
                // return const Scaffold(
                //   body: Center(
                //     child: Skeletonizer(
                //       ignorePointers: true,
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         children: [
                //           // CircularProgressIndicator(),
                //           SizedBox(height: 10), Text("Loading... "),
                //          ],
                //       ),
                //     ),
                //   ),
                // );

                return Scaffold(
                  body: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(width: 20.0, height: 100.0),
                        const Text(
                          'Your',
                          style: TextStyle(fontSize: 43.0),
                        ),
                        const SizedBox(width: 20.0, height: 100.0),
                        DefaultTextStyle(
                          style: const TextStyle(
                            fontSize: 40.0,
                            color: Colors.black,
                          ),
                          child: AnimatedTextKit(
                            animatedTexts: [
                              RotateAnimatedText('CROP'),
                              RotateAnimatedText('HUB'),
                            ],
                            totalRepeatCount: 4,
                            pause: const Duration(milliseconds: 4000),
                            displayFullTextOnTap: true,
                            stopPauseOnTap: true,
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (userExistsSnapshot.hasData && userExistsSnapshot.data == true) {
                // User data exists in Firestore, proceed to home screen.
                return const HomeScreen();
              } else {
                // User is authenticated but profile data is not in Firestore.
                // Redirect to complete the profile.
                return SignupGoogleScreen(user: snapshot.data!);
              }
            },
          );
          // return const HomeScreen(); // User is signed in
        } else {
          return const LoginScreen(); // Not signed in
        }
      },
    );
  }
}
