import 'package:flutter/material.dart';

import 'package:farmers_hub/screens/splash/splash_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmers Hub',
      theme: ThemeData(
        // fontFamily: 'SF Pro Display',
      ),
      home: const SplashScreen(),
    );
  }
}
