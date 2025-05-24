import 'package:flutter/material.dart';

import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/screens/login/login_screen.dart';
import 'package:farmers_hub/screens/home/home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<User?>(
      stream: firebaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // TODO: Check if user has completed registration properly and do not return him to Home if not
          return const HomeScreen(); // User is signed in
        } else {
          return const LoginScreen(); // Not signed in
        }
      },
    );
  }
}