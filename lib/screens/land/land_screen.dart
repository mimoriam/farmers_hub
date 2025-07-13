import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandScreen extends StatefulWidget {
  const LandScreen({super.key});

  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen> {
  final firebaseService = FirebaseService();

  int _selectedTabIndex = 0;

  // Future<List<QueryDocumentSnapshot<Object?>>> _getFutureForSelectedTab() {
  //   switch (_selectedTabIndex) {
  //     case 0:
  //       return firebaseService.getAllPostsByCurrentUser();
  //     case 1:
  //       return firebaseService.getSoldPostsByCurrentUser();
  //     case 2:
  //       return firebaseService.getFavoritedPosts();
  //     default:
  //       return firebaseService.getAllPostsByCurrentUser();
  //   }
  // }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildTabItem(0, "All"),
          SizedBox(width: 10),
          _buildTabItem(1, "Rent"),
          SizedBox(width: 10),
          _buildTabItem(2, "Sell"),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? onboardingColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
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
          "Land",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: Column(children: [Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 10),
        child: _buildTabBar(),
      )]),
    );
  }
}
