import 'package:farmers_hub/services/local_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:farmers_hub/utils/custom_page_transition_builder.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/screens/splash/splash_screen.dart';

import 'package:farmers_hub/services/theme_service.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // runApp(ChangeNotifierProvider(create: (_) => ThemeNotifier(), child: const MyApp()));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch for changes in both ThemeNotifier and LocaleProvider
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Farmers Hub',

      // Get the locale from your LocaleProvider
      locale: localeProvider.locale,

      // Change locale like this:
      // Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('ar'));

      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

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
  }
}
