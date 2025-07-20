import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class NotificationsScreen extends StatefulWidget {
  RemoteMessage? message;

  NotificationsScreen({super.key, this.message});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _firebaseService = FirebaseService();

  @override
  void initState() {
    // () async {
    //   final fcmToken = await FirebaseMessaging.instance.getToken();
    //   print(fcmToken);
    // }();
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
          AppLocalizations.of(context)!.notifications,
          // "Notifications",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: SafeArea(
        child: StreamBuilder(
          stream: _firebaseService.getUserNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Skeletonizer(child: Center(child: CircularProgressIndicator()));
            }

            if (snapshot.hasError) {
              return Center(child: Text(AppLocalizations.of(context)!.somethingWrong));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return  Center(child: Text(AppLocalizations.of(context)!.noNotifications));
            }

            final notifications = snapshot.data!.docs;

            // TODO: Update all notifications to read = true

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

                // child: Column(
                //   children: [
                //     RequestInfoCard(
                //       icon: Icons.workspace_premium_outlined,
                //       title: 'Leave Request Submitted',
                //       subtitle: 'Your feedback make help us better!',
                //       timestamp: '1:17 pm, 2/7/25',
                //       iconColor: Colors.green.shade600,
                //     ),
                //   ],
                // ),
                child: ListView.separated(
                  itemCount: notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 2),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final notification = notifications[index].data() as Map<String, dynamic>;

                    final timestamp = notification['createdAt'] as Timestamp;
                    final formattedDate = DateFormat('h:mm a, M/d/yy').format(timestamp.toDate());

                    return RequestInfoCard(
                      icon: Icons.workspace_premium_outlined,
                      title: notification['title'] as String? ?? 'No Title',
                      subtitle: notification['body'] as String? ?? '',
                      timestamp: formattedDate,
                      iconColor: Colors.green.shade600,
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class RequestInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String timestamp;
  final Color iconColor;

  const RequestInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.iconColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0, // No shadow for a flatter look
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center, // Center the icon vertically
          children: [
            // Icon on the left
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 16),
            // Title, Subtitle, and Timestamp in a column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          subtitle,
                          style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                        ),
                      ),
                      Text(
                        timestamp,
                        style: GoogleFonts.poppins(
                          fontSize: 11, // Smaller font size
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
