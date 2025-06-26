import 'package:farmers_hub/utils/constants.dart';
import 'package:farmers_hub/utils/custom_page_transition_builder.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/screens/splash/splash_screen.dart';

import 'package:farmers_hub/services/theme_service.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(ChangeNotifierProvider(create: (_) => ThemeNotifier(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Farmers Hub',

          theme: ThemeData(
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: CustomPageTransitionsBuilder(),
                TargetPlatform.iOS: CustomPageTransitionsBuilder(),
              },
            ),
            brightness: Brightness.light,
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: onboardingColor,
              selectionHandleColor: onboardingColor,
              selectionColor: onboardingColor,
            ),
          ),
          darkTheme: ThemeData(brightness: Brightness.dark),

          themeMode: themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const SplashScreen(),
        );
      },
    );
  }
}
