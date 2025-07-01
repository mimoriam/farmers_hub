import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/auth_gate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String selectedLanguage = 'English';
  bool isAgreed = false;

  @override
  Widget build(BuildContext context) {
    // Status bar color:
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: onboardingColor));
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "images/icons/splash_green.svg",
                semanticsLabel: AppLocalizations.of(context)!.yourCropIcon,
                width: 152,
                height: 152,
              ),

              const SizedBox(height: 14),

              Text(
                AppLocalizations.of(context)!.yourCrop,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  textStyle: TextStyle(color: onboardingColor, fontSize: 20, fontWeight: FontWeight.w500),
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Text(
                  // 'Welcome to Farmers Hub! Buy & Sell Fruits, Vegetables, Livestock, & More – All Securely Online.',
                  AppLocalizations.of(context)!.welcome,
                  textAlign: TextAlign.center,
                  // style: TextStyle(fontSize: 14, color: Colors.black54),
                  style: GoogleFonts.poppins(
                    textStyle: TextStyle(
                      color: onboardingTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 24.0, top: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(child: Icon(Icons.volume_up, size: 18, color: Colors.blue)),
                        TextSpan(
                          // text: ' Choose Preferred Language',
                          text: AppLocalizations.of(context)!.chooseLanguage,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
              //   child: DropdownButtonFormField<String>(
              //     menuMaxHeight: 100,
              //     decoration: InputDecoration(
              //       enabledBorder: OutlineInputBorder(
              //         borderSide: const BorderSide(color: onboardingTextColor, width: 1.0),
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderSide: BorderSide(color: onboardingTextColor, width: 1.0),
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     iconEnabledColor: onboardingTextColor,
              //     value: selectedLanguage,
              //     items:
              //         [
              //           'English',
              //           'Arabic'
              //         ].map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
              //     onChanged: (value) {
              //       setState(() {
              //         selectedLanguage = value!;
              //       });
              //     },
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6),
                child: DropdownButtonFormField2<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 2),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: onboardingTextColor, width: 1.0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: onboardingTextColor, width: 1.0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  iconStyleData: IconStyleData(
                    // Using IconStyleData for icon properties
                    iconEnabledColor: onboardingTextColor,
                  ),

                  dropdownStyleData: DropdownStyleData(
                    offset: const Offset(0, -12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                  ),
                  value: selectedLanguage,

                  items:
                      [
                        'English',
                        'Arabic',
                      ].map((lang) => DropdownMenuItem<String>(value: lang, child: Text(lang))).toList(),

                  onChanged: (value) {
                    setState(() {
                      selectedLanguage = value!;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Checkbox(
                        value: isAgreed,
                        onChanged: (value) {
                          setState(() {
                            isAgreed = value!;
                          });
                        },
                        checkColor: splashBackgroundColor,
                        activeColor: Colors.white,
                        // side: const BorderSide(color: Colors.black),
                        side: WidgetStateBorderSide.resolveWith(
                          (states) => BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 14),
                            child: Text.rich(
                              TextSpan(
                                // text: 'By continuing, you agree to ',
                                text: AppLocalizations.of(context)!.continueAgree,
                                style: GoogleFonts.poppins(
                                  color: onboardingTextColor,
                                  textStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Farmers Hub',
                                    // style: const TextStyle(fontWeight: FontWeight.bold),
                                    style: GoogleFonts.poppins(
                                      color: onboardingTextColor,
                                      textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              // 'Terms of Use Policy.',
                              AppLocalizations.of(context)!.terms,
                              style: GoogleFonts.poppins(
                                color: onboardingColor,
                                textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        isAgreed
                            ? () async {
                              final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();

                              await asyncPrefs.setBool("isAgreed", isAgreed);
                              await asyncPrefs.setString("language", selectedLanguage);

                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const AuthGate()),
                                );
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onboardingColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    child: Text(
                      // 'Agree Terms & Conditions',
                      AppLocalizations.of(context)!.agreeTerms,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
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
