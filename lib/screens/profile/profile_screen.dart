import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:farmers_hub/screens/add_post/add_post_screen.dart';
import 'package:farmers_hub/screens/chat/chat_home.dart';
import 'package:farmers_hub/screens/currency_exchange/currency_exchange_screen.dart';
import 'package:farmers_hub/screens/edit_profile/edit_profile_screen.dart';
import 'package:farmers_hub/screens/feedback/send_feedback_screen.dart';
import 'package:farmers_hub/screens/login/login_screen.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/services/theme_service.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter_svg/svg.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  final List<String> _languages = ['English', 'Español', 'Français', 'Deutsch', '日本語', '中文', '한국어'];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: homebackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AddPostScreen()),
            );
          }
        },
        backgroundColor: onboardingColor,
        elevation: 4,
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
        clipBehavior: Clip.antiAlias,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // Children are the navigation items
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (context.mounted) {
                  Navigator.pop(context);
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
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatHome()),
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
            Column(
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
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(semanticsLabel: 'Profile Icon', "images/icons/profile_selected.svg"),
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
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
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
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'Profile Settings',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),

                // SizedBox(height: 1),
                _buildProfileInfoCard(),

                // SizedBox(height: 1),
                _buildSettingsList(),

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
                          onTap: () {
                            // Handle Delete Account tap
                            print('Delete Account tapped');
                          },
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: Colors.white,
      child: Padding(
        // padding: const EdgeInsets.all(16.0),
        padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey.shade400,
                  child: Text(
                    'J', // Placeholder Initial
                    style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Profile Information',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            // SizedBox(height: 25),
            _buildInfoRow('Name', 'John Doe'),
            _buildInfoRow('Phone Number', '1234567890'),
            _buildInfoRow('Location', 'New York'),
            _buildInfoRow('Language', 'English'),
          ],
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
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
            }
          },
        ),
        _buildSettingItemCard(
          icon: Icons.verified_user_outlined, // Shield/verified icon
          title: 'Account Verification Information',
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
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              // Right side: Language Dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 100, right: 0, top: 2, bottom: 2),
                  // No explicit border for dropdown, styling via DropdownButton properties
                  child: DropdownButtonFormField2<String>(
                    items:
                        [
                          'English',
                          'Arabic',
                        ].map((lang) => DropdownMenuItem<String>(value: lang, child: Text(lang))).toList(),
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
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                    ),
                    value: "English",
                    onChanged: (value) {
                      setState(() {});
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
                  Icon(Icons.currency_exchange, color: Colors.grey[600], size: 24.0),
                  SizedBox(width: 12.0), // Spacing between icon and text
                  Text(
                    'Currency',
                    style: TextStyle(fontSize: 16.0, color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              // Right side: Language Dropdown
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 50, right: 0, top: 2, bottom: 2),
                  // No explicit border for dropdown, styling via DropdownButton properties
                  child: DropdownButtonFormField2<String>(
                    items:
                        [
                          'Syria (SY)',
                          'US Dollar (USD)',
                        ].map((lang) => DropdownMenuItem<String>(value: lang, child: Text(lang))).toList(),
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
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                    ),
                    value: "US Dollar (USD)",
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        _buildSettingItemCard(
          icon: Icons.history_outlined, // Clock/history icon
          title: 'Post History',
          onTap: () {
            print('Post History tapped');
            // Navigate to Post History Screen
          },
        ),

        _buildThemeModeCard(), // Custom card for theme mode
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
          boxShadow:
              isSelected
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
            style: TextStyle(fontSize: 16, color: textColor ?? Colors.grey[800], fontWeight: FontWeight.w500),
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
