import 'package:farmers_hub/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  RemoteMessage? message;

  NotificationsScreen({super.key, this.message});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    () async {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      print(fcmToken);
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        title: Text(
          "Notifications",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
