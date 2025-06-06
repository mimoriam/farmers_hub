import 'package:farmers_hub/screens/chat/chat_home.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencyExchangeScreen extends StatefulWidget {
  const CurrencyExchangeScreen({super.key});

  @override
  State<CurrencyExchangeScreen> createState() => _CurrencyExchangeScreenState();
}

class _CurrencyExchangeScreenState extends State<CurrencyExchangeScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   backgroundColor: onboardingColor,
      //   elevation: 4,
      //   shape: CircleBorder(),
      //   child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 24),
      // ),

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // bottomNavigationBar: BottomAppBar(
      //   height: 70,
      //   // shape: const UpwardNotchedAndRoundedRectangle(topCornerRadius: 12),
      //   notchMargin: 10,
      //   color: Colors.white,
      //   elevation: 0,
      //   // Shadow for the BottomAppBar
      //   clipBehavior: Clip.antiAlias,
      //
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceAround,
      //     // Children are the navigation items
      //     children: <Widget>[
      //       GestureDetector(
      //         onTap: () {
      //           if (context.mounted) {
      //             Navigator.pop(context);
      //           }
      //         },
      //         child: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             SvgPicture.asset(semanticsLabel: 'Home Icon', "images/icons/home.svg"),
      //             Text(
      //               'Home',
      //               style: GoogleFonts.montserrat(
      //                 fontSize: 11,
      //                 fontWeight: FontWeight.w500,
      //                 color: onboardingColor,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       GestureDetector(
      //         onTap: () {
      //           if (context.mounted) {
      //             Navigator.pushReplacement(
      //               context,
      //               MaterialPageRoute(builder: (context) => const ChatHome()),
      //             );
      //           }
      //         },
      //         child: Column(
      //           mainAxisSize: MainAxisSize.min,
      //           mainAxisAlignment: MainAxisAlignment.center,
      //           children: [
      //             SvgPicture.asset(semanticsLabel: 'Chat Icon', "images/icons/chat.svg"),
      //             Text(
      //               'Chat',
      //               style: GoogleFonts.montserrat(
      //                 fontSize: 11,
      //                 fontWeight: FontWeight.w500,
      //                 color: onboardingColor,
      //               ),
      //             ),
      //           ],
      //         ),
      //       ),
      //       const SizedBox(width: 6),
      //       Column(
      //         mainAxisSize: MainAxisSize.min,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           SvgPicture.asset(semanticsLabel: 'Favorites Icon', "images/icons/favorites.svg"),
      //           Text(
      //             'Favorites',
      //             style: GoogleFonts.montserrat(
      //               fontSize: 11,
      //               fontWeight: FontWeight.w500,
      //               color: onboardingColor,
      //             ),
      //           ),
      //         ],
      //       ),
      //       Column(
      //         mainAxisSize: MainAxisSize.min,
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           SvgPicture.asset(semanticsLabel: 'Profile Icon', "images/icons/profile_selected.svg"),
      //           Text(
      //             'Profile',
      //             style: GoogleFonts.montserrat(
      //               fontSize: 11,
      //               fontWeight: FontWeight.w500,
      //               color: onboardingColor,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          "Currency Exchange",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selected = 1;
                  });
                },
                child: Card(
                  elevation: 1.0,
                  // Elevation for an unselected card
                  margin: const EdgeInsets.symmetric(vertical: 1.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: Colors.grey.shade300, // Border color for an unselected card
                      width: 1,
                    ),
                  ),
                  color: Colors.white,
                  // Background color for an unselected card
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Icon part for US Dollar
                        Icon(
                          Icons.payments, // The dollar icon
                          color: Colors.grey.shade600, // Icon color when not selected
                          size: 24,
                        ),
                        const SizedBox(width: 16.0),

                        // Text part
                        Expanded(
                          child: Text(
                            'Syria (SY)', // Title and subtitle
                            style: TextStyle(
                              color: Colors.grey.shade600, // Text color when not selected
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),

                        // Radio button part (custom look for unselected state)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected == 1 ? onboardingColor : Colors.transparent, // Fill color for
                            // unselected radio
                            border: Border.all(
                              color: Colors.grey.shade400, // Border color for unselected radio
                              width: 2,
                            ),
                          ),
                          child: null, // No inner icon when not selected
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: () {
                  setState(() {
                    selected = 2;
                  });
                },
                child: Card(
                  elevation: 1.0,
                  // Elevation for an unselected card
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    side: BorderSide(
                      color: Colors.grey.shade300, // Border color for an unselected card
                      width: 1,
                    ),
                  ),
                  color: Colors.white,
                  // Background color for an unselected card
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Icon part for US Dollar
                        Icon(
                          Icons.attach_money, // The dollar icon
                          color: Colors.grey.shade600, // Icon color when not selected
                          size: 24,
                        ),
                        const SizedBox(width: 16.0),

                        // Text part
                        Expanded(
                          child: Text(
                            'US Dollar (USD)', // Title and subtitle
                            style: TextStyle(
                              color: Colors.grey.shade600, // Text color when not selected
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),

                        // Radio button part (custom look for unselected state)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected == 2 ? onboardingColor : Colors.transparent, // Fill color for
                            // unselected radio
                            border: Border.all(
                              color: Colors.grey.shade400, // Border color for unselected radio
                              width: 2,
                            ),
                          ),
                          child: null, // No inner icon when not selected
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
