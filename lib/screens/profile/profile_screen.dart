import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:farmers_hub/screens/add_post/add_post_screen.dart';
import 'package:farmers_hub/screens/chat/chat_home.dart';
import 'package:farmers_hub/screens/chat/chat_screen.dart';
import 'package:farmers_hub/screens/currency_exchange/currency_exchange_screen.dart';
import 'package:farmers_hub/screens/edit_profile/edit_profile_screen.dart';
import 'package:farmers_hub/screens/favorites/favorites_screen.dart';
import 'package:farmers_hub/screens/feedback/send_feedback_screen.dart';
import 'package:farmers_hub/screens/login/login_screen.dart';
import 'package:farmers_hub/screens/manage_post/manage_post_screen.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/services/locale_service.dart';
import 'package:farmers_hub/services/theme_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final firebaseService = FirebaseService();
  String _selectedTheme = 'Light';

  String selectedLanguage = "English";

  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _getSharedPrefsData() async {
    final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
    final lang = await asyncPrefs.getString("language");

    if (context.mounted) {
      setState(() {
        selectedLanguage = lang ?? 'English';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getSharedPrefsData().then((_) {});
  }

  void _showDeleteConfirmationDialog2() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            "Are you sure?",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  await firebaseService.deleteUserAndPosts();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                } catch (e) {
                  // Handle any errors, e.g., show a snackbar
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error deleting account: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          title: Text(
            "Delete Account",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          content: Text(
            "Are you sure you want to delete your account and all of your posts? This action cannot be undone.",
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                try {
                  Navigator.of(context).pop();
                  _showDeleteConfirmationDialog2();
                  // await firebaseService.deleteUserAndPosts();
                  // if (context.mounted) {
                  //   Navigator.of(context).pushAndRemoveUntil(
                  //     MaterialPageRoute(builder: (context) => LoginScreen()),
                  //     (Route<dynamic> route) => false,
                  //   );
                  // }
                } catch (e) {
                  // Handle any errors, e.g., show a snackbar
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error deleting account: ${e.toString()}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void showFeedbackDialog(BuildContext context) {
    int currentRating = 5; // To hold the selected star rating


    showDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder if you need to update the dialog's content (like the star rating)
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 5,
              backgroundColor: Colors.transparent, // Make Dialog's own background transparent
              child: _buildDialogContent(dialogContext, setState, currentRating, (rating) {
                setState(() {
                  currentRating = rating;
                });
              }),
            );
          },
        );
      },
    );
  }

// Separate function for the dialog content to keep it organized
  Widget _buildDialogContent(
      BuildContext context,
      StateSetter setState, // To update the rating from outside
      int currentRating,
      Function(int) onRatingUpdate,
      ) {

    final Color primaryGreen = onboardingColor;
    final Color darkTextColor = Colors.black87;
    final Color lightTextColor = Colors.grey.shade600;

    // Helper function to get the appropriate emoji based on the rating
    String getEmojiForRating(int rating) {
      switch (rating) {
        case 0: // Default or no rating yet
          return '🤔'; // Thinking face or a neutral default
        case 1:
          return '😢'; // Crying face
        case 2:
          return '😕'; // Confused/Slightly frowning
        case 3:
          return '🙂'; // Smiling face
        case 4:
          return '🥰'; // Smiling face with hearts (or similar to your "kissing face")
        case 5:
          return '😍'; // Heart eyes
        default:
          return '😊'; // Default smiling face if rating is somehow out of expected range
      }
    }

    String currentEmoji = getEmojiForRating(currentRating);

    return Stack(
      clipBehavior: Clip.none, // Allows the emoji to go outside the Stack's bounds
      alignment: Alignment.topCenter,
      children: <Widget>[
        // Card content
        Container(
          margin: EdgeInsets.only(top: 40), // Space for the emoji to stick out
          padding: EdgeInsets.only(
            top: 50, // Space inside the card, below the emoji
            bottom: 20,
            left: 10,
            right: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Important for dialogs
            children: <Widget>[
              Text(
                'Review by ${_firebaseService.currentUser!.displayName}', // Replace with dynamic data if needed
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: lightTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'How Was Your Experience with us',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkTextColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Your feedback make help us better! Tap the button below to share feedback and Get Support!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: lightTextColor,
                  height: 1.4,
                ),
              ),
              SizedBox(height: 20),
              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < currentRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 35,
                    ),
                    onPressed: () {
                      onRatingUpdate(index + 1);
                    },
                  );
                }),
              ),
              SizedBox(height: 12),
              // Share Feedback Button
              ElevatedButton.icon(
                icon: Icon(Icons.thumb_up_alt_outlined, color: Colors.white, size: 20),
                label: Text(
                  'Share feedback',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: onboardingColor,
                  minimumSize: Size(double.infinity, 50), // Full width
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  // Handle share feedback action
                  print('Feedback shared with rating: $currentRating');
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              SizedBox(height: 12),
              // Cancel Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50), // Full width
                  side: BorderSide(color: onboardingColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: primaryGreen, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        // Top Emoji - Positioned to stick out
        Positioned(
          top: -10, // Adjust this value to control how much the emoji sticks out
          child: Container(
            padding: EdgeInsets.all(0), // No padding needed if emoji itself is well-sized
            // decoration: BoxDecoration( // Optional: if you want a background behind the emoji
            //   color: Colors.white,
            //   shape: BoxShape.circle,
            //   boxShadow: [
            //     BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)
            //   ]
            // ),
            child: Text(
              // '😍', // The emoji
              currentEmoji,
              style: TextStyle(
                fontSize: 70, // Adjust size of emoji
              ),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AddPostScreen()),
            );
          }
        },
        backgroundColor: onboardingColor,
        elevation: 0,
        shape: CircleBorder(),
        child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 70,
        // shape: const UpwardNotchedAndRoundedRectangle(topCornerRadius: 12),
        notchMargin: 10,
        color: Colors.white,
        elevation: 0,
        // Shadow for the BottomAppBar
        // clipBehavior: Clip.antiAlias,
        clipBehavior: Clip.none,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // Children are the navigation items
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(semanticsLabel: 'Home Icon', "images/icons/home.svg"),
                  Text(
                    'Home',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                final user = firebaseService.currentUser;
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => ChatHome(user: user)),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(semanticsLabel: 'Chat Icon', "images/icons/chat.svg"),
                  Text(
                    'Chat',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),

            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                  ).then((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(semanticsLabel: 'Favorites Icon', "images/icons/favorites.svg"),
                  Text(
                    'Favorites',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: onboardingColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  semanticsLabel: 'Profile Icon',
                  "images/icons/profile_selected.svg",
                ),
                Text(
                  'Profile',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: onboardingColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      appBar: AppBar(
        // leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          "User Profile",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    'Profile Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // SizedBox(height: 1),
                _buildProfileInfoCard(),

                // SizedBox(height: 1),
                Padding(padding: const EdgeInsets.only(left: 4), child: _buildSettingsList()),

                _buildSettingsCard(
                  context,
                  children: [
                    _buildSettingsItem(
                      icon: Icons.chat_outlined,
                      text: 'Admin Chat Support',
                      onTap: () async {
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                receiverId: "w6A7diKRtVYo75YLKK8jdLSIdvW2",
                                receiverEmail: "devmimo420@gmail.com",
                                user: _firebaseService.currentUser,
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    _buildSettingsItem(
                      icon: Icons.currency_bitcoin,
                      text: 'Commission & Membership',
                      onTap: () {},
                      showDivider: false, // No divider for the last item in a section
                    ),

                    _buildSettingsItem(
                      icon: Icons.thumb_up_outlined,
                      text: 'Rate us',
                      onTap: () {
                        showFeedbackDialog(context);
                      },
                      showDivider: false, // No divider for the last item in a section
                    ),
                  ],
                ),

                // SizedBox(height: 1),
                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    _buildSettingsCard(
                      context,
                      children: [
                        _buildSettingsItem(
                          icon: Icons.share_outlined,
                          text: 'Share App',
                          onTap: () {
                            // Handle Share App tap
                            print('Share App tapped');
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.headset_mic_outlined,
                          text: 'Customer support',
                          onTap: () async {
                            String email = "mailto:M.mahsolek@gmail.com";

                            if (await canLaunch(email)) {
                              await launchUrlString(email);
                            } else {
                              throw 'Could not launch $email';
                            }
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.shield_outlined,
                          text: 'Privacy Policy',
                          onTap: () {
                            // Handle Privacy Policy tap
                            print('Privacy Policy tapped');
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.article_outlined,
                          text: 'Send Feedback',
                          onTap: () {
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SendFeedBackScreen()),
                              );
                            }
                          },
                          showDivider: false, // No divider for the last item in a section
                        ),
                      ],
                    ),

                    // const SizedBox(height: 3),
                    _buildSettingsCard(
                      context,
                      children: [
                        _buildSettingsItem(
                          icon: Icons.logout_outlined,
                          text: 'Logout of account',
                          onTap: () async {
                            await firebaseService.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => LoginScreen()),
                              );
                            }
                          },
                        ),
                        _buildSettingsItem(
                          icon: Icons.delete_outline,
                          text: 'Delete Account',
                          textColor: Colors.red[700],
                          // Optional: different color for destructive actions
                          iconColor: Colors.red[700],
                          onTap: _showDeleteConfirmationDialog,
                          showDivider: false, // No divider for the last item in a section
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Card(
      elevation: 3.0,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: Colors.white,
      child: Padding(
        // padding: const EdgeInsets.all(16.0),
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: FutureBuilder<DocumentSnapshot?>(
          future: _firebaseService.getCurrentUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // return const Center(child: CircularProgressIndicator(color: onboardingColor));
              return Skeletonizer(
                effect: ShimmerEffect(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                ),
                ignoreContainers: true,
                ignorePointers: true,
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: onboardingColor,
                          child: Text(
                            'A', // Placeholder Initial
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        SizedBox(width: 10),
                        Text(
                          'Profile Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        _buildInfoRow('Name', ""),
                        _buildInfoRow('Phone Number', ""),
                        _buildInfoRow('Location', ""),
                        _buildInfoRow('Language', ""),
                      ],
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("Failed to load user data."));
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>?;

            final username = userData?['username'] ?? '';
            final location = userData?["location"]["city"] ?? "";
            final phoneNumber = userData?["phoneInfo"]["completeNumber"] ?? "";
            final profileImageUrl = userData?['profileImage'];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: onboardingColor,
                      backgroundImage:
                          profileImageUrl != null && profileImageUrl != "default_pfp.jpg"
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: (profileImageUrl == null || profileImageUrl == "default_pfp.jpg")
                          ? Text(
                              'A', // Placeholder Initial
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),

                    SizedBox(width: 10),
                    Text(
                      'Profile Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                Column(
                  children: [
                    _buildInfoRow('Name', username),
                    _buildInfoRow('Phone Number', phoneNumber),
                    _buildInfoRow('Location', location),
                    _buildInfoRow('Language', selectedLanguage),
                  ],
                ),
                // SizedBox(height: 25),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Skeleton.keep(child: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 16))),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Column(
      children: [
        _buildSettingItemCard(
          icon: Icons.edit_note_outlined, // Pencil icon
          title: 'Edit Profile',
          onTap: () {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              ).then((_) {
                if (mounted) {
                  setState(() {});
                }
              });
            }
          },
        ),
        _buildSettingItemCard(
          icon: Icons.verified_user_outlined, // Shield/verified icon
          // title: 'Account Verification',
          title: AppLocalizations.of(context)!.agreeTerms,
          onTap: () {
            // Navigate to Account Verification Screen
          },
        ),

        SizedBox(height: 4),

        Container(
          // Decoration for the card-like appearance
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 2), // Subtle shadow
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Inner padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to start and end
            children: <Widget>[
              // Left side: Icon and Label
              Row(
                children: <Widget>[
                  Icon(
                    Icons.language, // Globe icon
                    color: Colors.grey[600],
                    size: 24.0,
                  ),
                  SizedBox(width: 12.0), // Spacing between icon and text
                  Text(
                    'Language',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Right side: Language Dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 100, right: 0, top: 2, bottom: 2),
                  // No explicit border for dropdown, styling via DropdownButton properties
                  child: DropdownButtonFormField2<String>(
                    items: ['English', 'Arabic']
                        .map(
                          (lang) => DropdownMenuItem<String>(
                            // onTap: () async {
                            //   final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
                            //   await asyncPrefs.setString("language", lang);
                            //   if (context.mounted) {
                            //     setState(() {
                            //       selectedLanguage = lang;
                            //     });
                            //   }
                            // },
                            value: lang,
                            child: Text(lang),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                    ),
                    iconStyleData: IconStyleData(
                      // Using IconStyleData for icon properties
                      iconEnabledColor: onboardingTextColor,
                    ),

                    dropdownStyleData: DropdownStyleData(
                      offset: const Offset(0, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white,
                      ),
                    ),
                    value: selectedLanguage,
                    onChanged: (value) async {
                      if (value != null) {
                        final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
                        await asyncPrefs.setString("language", value);

                        if (mounted) {
                          if (value == "English") {
                            Provider.of<LocaleProvider>(
                              context,
                              listen: false,
                            ).setLocale(const Locale('en'));
                          } else {
                            Provider.of<LocaleProvider>(
                              context,
                              listen: false,
                            ).setLocale(const Locale('ar'));
                          }
                        }

                        if (mounted) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 4),

        _buildSettingItemCard(
          icon: Icons.currency_exchange,
          title: 'Currency',
          onTap: () {
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CurrencyExchangeScreen()),
              );
            }
          },
        ),

        // Currecy Dropdown
        // Container(
        //   // Decoration for the card-like appearance
        //   decoration: BoxDecoration(
        //     color: Colors.white,
        //     borderRadius: BorderRadius.circular(12.0), // Rounded corners
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.grey.withOpacity(0.1),
        //         spreadRadius: 1,
        //         blurRadius: 5,
        //         offset: Offset(0, 2), // Subtle shadow
        //       ),
        //     ],
        //   ),
        //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), // Inner padding
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to start and end
        //     children: <Widget>[
        //       // Left side: Icon and Label
        //       Row(
        //         children: <Widget>[
        //           Icon(Icons.currency_exchange, color: Colors.grey[600], size: 24.0),
        //           SizedBox(width: 12.0), // Spacing between icon and text
        //           Text(
        //             'Currency',
        //             style: TextStyle(fontSize: 16.0, color: Colors.grey[700], fontWeight: FontWeight.w500),
        //           ),
        //         ],
        //       ),
        //
        //       // Right side: Language Dropdown
        //       Expanded(
        //         child: Container(
        //           padding: EdgeInsets.only(left: 90, right: 0, top: 2, bottom: 2),
        //           // No explicit border for dropdown, styling via DropdownButton properties
        //           child: DropdownButtonFormField2<String>(
        //             items:
        //                 [
        //                   'Syria',
        //                   'USDollar',
        //                 ].map((lang) => DropdownMenuItem<String>(value: lang, child: Text(lang))).toList(),
        //             decoration: InputDecoration(
        //               contentPadding: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
        //               enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
        //               focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
        //             ),
        //             iconStyleData: IconStyleData(
        //               // Using IconStyleData for icon properties
        //               iconEnabledColor: onboardingTextColor,
        //             ),
        //
        //             dropdownStyleData: DropdownStyleData(
        //               offset: const Offset(0, 0),
        //               decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
        //             ),
        //             value: "USDollar",
        //             onChanged: (value) {
        //               setState(() {});
        //             },
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        // SizedBox(height: 4),
        _buildSettingItemCard(
          icon: Icons.history_outlined, // Clock/history icon
          title: 'Post History',
          onTap: () {
            if (context.mounted) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ManagePostScreen()));
            }
          },
        ),

        // _buildThemeModeCard(), // Custom card for theme mode
      ],
    );
  }

  Widget _buildSettingItemCard({
    required IconData icon,
    required String title,
    Widget? customTrailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2.0,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.symmetric(vertical: 5.0),
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: Colors.grey[700], size: 24),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customTrailing != null) customTrailing,
            if (customTrailing != null) SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
        onTap: onTap,
        hoverColor: Colors.grey[50],
        splashColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildSettingLanguageItemCard({
    required IconData icon,
    required String title,
    Widget? customTrailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2.0,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.symmetric(vertical: 7.0),
      color: Colors.white,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Icon(icon, color: Colors.grey[700], size: 24),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (customTrailing != null) customTrailing,
            if (customTrailing != null) SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
        onTap: onTap,
        hoverColor: Colors.grey[50],
        splashColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildThemeModeCard() {
    return Card(
      elevation: 2.0,
      shadowColor: Colors.grey.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      margin: EdgeInsets.symmetric(vertical: 3.0),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(Icons.brightness_6_outlined, color: Colors.grey[700], size: 24), // Theme icon
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Theme Mode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87),
              ),
            ),
            _buildThemeChoiceButton('☀️ Light', 'Light'),
            SizedBox(width: 6),
            _buildThemeChoiceButton('🌙 Dark', 'Dark'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeChoiceButton(String label, String themeValue) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    bool isSelected = _selectedTheme == themeValue;
    // Color from image for selected button (a vibrant green)
    Color selectedColor = onboardingColor;
    Color unselectedColor = Color(0xFFF0F0F0); // Light grey for unselected
    Color selectedTextColor = Colors.white;
    Color unselectedTextColor = Colors.black87;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTheme = themeValue;
          print('Theme changed to: $_selectedTheme');
          // Here you would typically also update the app's theme globally
        });

        themeNotifier.toggleTheme();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(25.0),
          border: Border.all(color: isSelected ? selectedColor : Colors.grey[300]!, width: 0.8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedColor.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? selectedTextColor : unselectedTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 0.5, // Subtle shadow
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Rounded corners for the card
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor ?? Colors.grey[600], size: 24),
          title: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: textColor ?? Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 72.0, right: 16.0), // Align divider with text
            child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
          ),
      ],
    );
  }
}
