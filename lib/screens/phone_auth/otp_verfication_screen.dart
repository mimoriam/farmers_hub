import 'package:farmers_hub/screens/phone_auth/account_verified_screen.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';

class OtpVerficationScreen extends StatefulWidget {
  const OtpVerficationScreen({super.key});

  @override
  State<OtpVerficationScreen> createState() => _OtpVerficationScreenState();
}

class _OtpVerficationScreenState extends State<OtpVerficationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,

        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "images/icons/splash_green.svg",
                  semanticsLabel: 'Your Crop icon',
                  width: 152,
                  height: 152,
                ),

                const SizedBox(height: 24),

                Text(
                  "OTP Verification",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(color: onboardingColor, fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 24),

                // Make dynamic text here "Enter OTP sent to ${mobile_num}"
                Text(
                  "Enter the OTP sent to your mobile number",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: onboardingTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Pinput(length: 4, onCompleted: (pin) => print(pin)),

                SizedBox(height: 65),

                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Resend OTP",
                    style: TextStyle(color: onboardingColor, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: onboardingColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => AccountVerifiedScreen()),
                          );
                        }
                      },
                      child: Text(
                        "Verify",
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 52),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
