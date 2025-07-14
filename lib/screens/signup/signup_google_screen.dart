import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/screens/home/home_screen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class SignupGoogleScreen extends StatefulWidget {
  final User user;

  const SignupGoogleScreen({super.key, required this.user});

  @override
  State<SignupGoogleScreen> createState() => _SignupGoogleScreenState();
}

class _SignupGoogleScreenState extends State<SignupGoogleScreen> {
  final firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;
  String error = '';
  bool isPhoneValidated = false;
  Map<String, String> phoneInfo = {};

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          // If the route is popped, exit the app
        } else {
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: scaffoldBackgroundColor,
                title: Text(AppLocalizations.of(context)!.warning),
                content: Text(AppLocalizations.of(context)!.finishRegisteration),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Don't exit
                    },
                    child: Text(AppLocalizations.of(context)!.ok),
                  ),
                ],
              );
            },
          );
        }
        // Show a confirmation dialog before allowing the pop
      },
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: onboardingColor,
          automaticallyImplyLeading: false,
          title: Text(
            AppLocalizations.of(context)!.additionalInfo,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 10),

                        Text(
                          AppLocalizations.of(context)!.enterDetails,
                          style: GoogleFonts.poppins(
                            color: onboardingTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 16),

                        Divider(height: 2),

                        if (error.isNotEmpty)
                          Text(
                            error.split(":").skip(1).join(":").trim(),
                            style: const TextStyle(color: Colors.red),
                          ),

                        SizedBox(height: 14),

                        Text(
                          AppLocalizations.of(context)!.enterName,
                          style: GoogleFonts.poppins(
                            color: signUpTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 8),

                        FormBuilderTextField(
                          name: 'username',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          initialValue: widget.user.displayName,
                          enabled: false,
                          autovalidateMode: validateMode,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterUsername,
                            prefixIcon: Icon(Icons.person_outline, color: loginTextFieldIconColor),
                            filled: true,
                            fillColor: Colors.white,
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
                        ),

                        SizedBox(height: 18),

                        Text(
                          AppLocalizations.of(context)!.enterUserMail,
                          style: GoogleFonts.poppins(
                            color: signUpTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 8),

                        FormBuilderTextField(
                          name: 'email',
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          initialValue: widget.user.email,
                          enabled: false,
                          autovalidateMode: validateMode,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterEmail,
                            prefixIcon: Icon(Icons.email_outlined, color: loginTextFieldIconColor),
                            filled: true,
                            fillColor: Colors.white,
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
                        ),

                        SizedBox(height: 14),

                        Text(
                          AppLocalizations.of(context)!.enterPhoneNumber,
                          style: GoogleFonts.poppins(
                            color: signUpTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 8),

                        IntlPhoneField(
                          showCountryFlag: false,
                          dropdownTextStyle: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          pickerDialogStyle: PickerDialogStyle(backgroundColor: Colors.white),
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterPhoneNumber,
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

                        SizedBox(height: 10),
                        const SizedBox(height: 14),

                        TapDebouncer(
                          cooldown: const Duration(milliseconds: 2000),
                          onTap:
                          isPhoneValidated
                              ? () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                error = '';
                              });
                              try {
                                await firebaseService.saveUserDataOnRegister(
                                  user: widget.user,
                                  username: _formKey.currentState?.fields['username']?.value,
                                  phone: phoneInfo,
                                );

                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  debugPrint(e.toString());
                                  error = e.toString();
                                });
                              }
                            }
                          }
                              : null,

                          builder: (BuildContext context, TapDebouncerFunc? onTap) {
                            return SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: onboardingColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: onTap,
                                child: Text(
                                  AppLocalizations.of(context)!.signup,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 34),
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