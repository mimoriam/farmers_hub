import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/services/locale_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:farmers_hub/utils/custom_page_transition_builder.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/screens/splash/splash_screen.dart';

import 'package:farmers_hub/services/theme_service.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';

// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print("Handling a background message: ${message.messageId}");
// }

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print("Got a message in background!");
  print('Title: ${message.notification!.title}');
  print('Body: ${message.notification!.body}');

  final firebaseService = FirebaseService();

  if (firebaseService.auth.currentUser != null) {
    final notifId = await firebaseService.firestore
        .collection(firebaseService.userCollection)
        .doc(firebaseService.auth.currentUser!.uid)
        .collection(firebaseService.notificationCollection)
        .add({
          "title": message.notification!.title,
          "body": message.notification!.body,
          "createdAt": FieldValue.serverTimestamp(),
          "hasBeenDeleted": false,
          "userId": firebaseService.auth.currentUser!.uid,
          "read": false,
        });

    print({notifId});

    await firebaseService.firestore
        .collection(firebaseService.userCollection)
        .doc(firebaseService.auth.currentUser!.uid)
        .update({
          "notificationIds": FieldValue.arrayUnion([notifId.id]),
        });
  }
}

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // await FirebaseMessaging.instance.requestPermission(); // Request notification permissions
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final firebaseService = FirebaseService();
  await firebaseService.initNotifications();

  final localeProvider = LocaleProvider();

  // Await the loading of the locale.
  await localeProvider.loadLocale();
  // runApp(ChangeNotifierProvider(create: (_) => ThemeNotifier(), child: const MyApp()));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        // ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: MyApp(),
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
      navigatorKey: navigatorKey,
      title: AppLocalizations.of(context)?.appTitle,

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
