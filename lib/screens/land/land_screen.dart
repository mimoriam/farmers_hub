import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LandScreen extends StatefulWidget {
  String categoryOption;
  LandScreen({super.key, required this.categoryOption});

  @override
  State<LandScreen> createState() => _LandScreenState();
}

class _LandScreenState extends State<LandScreen> {
  final firebaseService = FirebaseService();

  int _selectedTabIndex = 0;

  List<QueryDocumentSnapshot> _searchResults = [];

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          // _buildTabItem(0, "All"),
          _buildTabItem(0, AppLocalizations.of(context)!.all),
          SizedBox(width: 10),
          // _buildTabItem(1, "Rent"),
          _buildTabItem(1, AppLocalizations.of(context)!.rent),
          SizedBox(width: 10),
          // _buildTabItem(2, "Sell"),
          _buildTabItem(2, AppLocalizations.of(context)!.sale),
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
          widget.categoryOption == "Land"
              // ? "Land"
              ? AppLocalizations.of(context)!.landServices
              : widget.categoryOption == "Equipments"
              // ? "Equipments"
              ? AppLocalizations.of(context)!.equipments
              : widget.categoryOption == "Delivery"
              // ? "Delivery
              ? AppLocalizations.of(context)!.delivery
              : widget.categoryOption,
          // "Land",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 6, top: 10),
            child: _buildTabBar(),
          ),

          _searchResults.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(),
                        child: Icon(
                          Icons.landscape, // An icon that fits the context
                          color: Colors.grey[700],
                          size: 36.0,
                        ),
                      ),

                      // const SizedBox(height: 10.0),
                      Text(
                        // 'No results',
                        AppLocalizations.of(context)!.noResults,
                        style: TextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : Container(),

          SingleChildScrollView(child: Container()),
        ],
      ),
    );
  }
}
