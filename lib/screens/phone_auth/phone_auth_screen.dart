import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  bool isPhoneValidated = false;
  Map<String, String> phoneInfo = {};
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

                Text(
                  "We will send you a one-time password to this mobile number",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    textStyle: TextStyle(
                      color: onboardingTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: FormBuilderTextField(
                //     keyboardType: TextInputType.number,
                //     name: 'phone',
                //     maxLength: 30,
                //     autovalidateMode: AutovalidateMode.onUserInteraction,
                //     validator: FormBuilderValidators.compose([
                //       FormBuilderValidators.required(),
                //     ]),
                //     style: GoogleFonts.poppins(
                //       textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                //     ),
                //     decoration: InputDecoration(
                //       counterText: "",
                //       hintText: "Enter your Mobile Number",
                //       prefixIcon: Icon(Icons.phone, color: loginTextFieldIconColor),
                //       filled: true,
                //       fillColor: Colors.white,
                //
                //       // border: OutlineInputBorder(
                //       //   borderRadius: BorderRadius.circular(8),
                //       //   borderSide: BorderSide.none,
                //       // ),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(8),
                //         borderSide: BorderSide(color: textFieldBorderSideColor),
                //       ),
                //       enabledBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(8),
                //         borderSide: BorderSide(color: textFieldBorderSideColor),
                //       ),
                //       focusedBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(8),
                //         borderSide: BorderSide(color: textFieldBorderSideColor),
                //       ),
                //       focusedErrorBorder: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(8),
                //         borderSide: BorderSide(color: textFieldBorderSideColor),
                //       ),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: IntlPhoneField(
                    showCountryFlag: false,
                    // dropdownTextStyle: TextStyle(fontWeight: FontWeight.w500),
                    dropdownTextStyle: GoogleFonts.poppins(
                      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    style: GoogleFonts.poppins(textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    pickerDialogStyle: PickerDialogStyle(backgroundColor: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter Phone Number',
                      filled: true,
                      fillColor: Colors.white,
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: textFieldBorderSideColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: textFieldBorderSideColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: textFieldBorderSideColor),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: textFieldBorderSideColor),
                      ),
                    ),
                    initialCountryCode: 'US',
                    onChanged: (phone) {
                      try {
                        bool isValid = phone.isValidNumber();

                        setState(() {
                          isPhoneValidated = isValid;

                          if (isValid == true) {
                            phoneInfo.addAll({
                              "countryISOCode": phone.countryISOCode,
                              "countryCode": phone.countryCode,
                              "completeNumber": phone.completeNumber,
                            });
                          } else {
                            phoneInfo.clear();
                          }
                        });
                      } catch (e) {
                        setState(() {
                          isPhoneValidated = false;
                          phoneInfo.clear();
                        });
                      }
                    },
                  ),
                ),

                SizedBox(height: 16),

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
                        // if (context.mounted) {
                        //   Navigator.push(context, MaterialPageRoute(builder: (context) => PhoneAuthScreen()));
                        // }
                      },
                      child: Text(
                        "Get OTP",
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
