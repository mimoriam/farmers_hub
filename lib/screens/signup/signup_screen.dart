import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/screens/login/login_screen.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;
  bool _obscureText = true;
  String error = '';
  bool isPhoneValidated = false;
  Map<String, String> phoneInfo = {};

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextDirection currentDirection = Directionality.of(context);

    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.additionalInfo,
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
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

                      SizedBox(height: 14),

                      Divider(height: 2),

                      if (error.isNotEmpty)
                        Text(
                          error.split(":").skip(1).join(":").trim(),
                          style: const TextStyle(color: Colors.red),
                        ),

                      SizedBox(height: 12),

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
                        maxLength: 24,
                        autovalidateMode: validateMode,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: AppLocalizations.of(context)!.requiredField,
                          ),
                          FormBuilderValidators.username(
                            errorText: AppLocalizations.of(context)!.error,
                          ),
                        ]),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        decoration: InputDecoration(
                          counterText: "",
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
                        maxLength: 30,
                        autovalidateMode: validateMode,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: AppLocalizations.of(context)!.requiredField,
                          ),
                          FormBuilderValidators.email(
                            errorText: AppLocalizations.of(context)!.validEmail,
                          ),
                        ]),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        decoration: InputDecoration(
                          counterText: "",
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
                      //
                      SizedBox(height: 8),

                      IntlPhoneField(
                        invalidNumberMessage: AppLocalizations.of(context)!.invalidNumber,
                        textAlign: currentDirection == TextDirection.rtl
                            ? TextAlign.right
                            : TextAlign.left,
                        showCountryFlag: false,
                        dropdownTextStyle: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        pickerDialogStyle: PickerDialogStyle(
                          backgroundColor: Colors.white,
                          searchFieldInputDecoration: InputDecoration(
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: const BorderSide(color: onboardingColor),
                            ),
                          ),
                        ),
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
                      Text(
                        AppLocalizations.of(context)!.enterpassword,
                        style: GoogleFonts.poppins(
                          color: signUpTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 8),

                      FormBuilderTextField(
                        name: 'password',
                        maxLength: 16,
                        obscureText: _obscureText,
                        autovalidateMode: validateMode,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: AppLocalizations.of(context)!.requiredField,
                          ),
                          FormBuilderValidators.minLength(
                            6,
                            errorText: AppLocalizations.of(context)!.passwordCondition,
                          ),
                        ]),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: AppLocalizations.of(context)!.enterPassword,
                          prefixIcon: Icon(Icons.lock_outline, color: loginTextFieldIconColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: loginTextFieldIconColor,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
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
                        AppLocalizations.of(context)!.confirmPassword,
                        style: GoogleFonts.poppins(
                          color: signUpTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 8),

                      FormBuilderTextField(
                        name: 'password_confirm',
                        maxLength: 16,
                        obscureText: _obscureText,
                        autovalidateMode: validateMode,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: AppLocalizations.of(context)!.requiredField,
                          ),
                          FormBuilderValidators.minLength(
                            6,
                            errorText: AppLocalizations.of(context)!.passwordCondition,
                          ),

                          (val) {
                            if (_formKey.currentState?.fields['password']?.value != val) {
                              return AppLocalizations.of(context)!.wrongPassword;
                            }
                            return null; // Return null if validation passes
                          },
                        ]),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: AppLocalizations.of(context)!.confirmYourPassword,
                          prefixIcon: Icon(Icons.lock_outline, color: loginTextFieldIconColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility_off : Icons.visibility,
                              color: loginTextFieldIconColor,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
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
                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: onboardingColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed:
                              // isPhoneValidated ?
                              () async {
                                if (_formKey.currentState!.validate() && isPhoneValidated) {
                                  setState(() {
                                    error = '';
                                  });
                                  try {
                                    final user = await firebaseService.registerWithEmail(
                                      email: _formKey.currentState?.fields['email']?.value,
                                      password: _formKey.currentState?.fields['password']?.value,
                                    );

                                    await firebaseService.saveUserDataOnRegister(
                                      user: user.user!,
                                      username: _formKey.currentState?.fields['username']?.value,
                                      phone: phoneInfo,
                                    );

                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginScreen(),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      debugPrint(e.toString());
                                      error = e.toString();
                                    });
                                  }
                                }
                              },
                          child: Text(
                            AppLocalizations.of(context)!.signup,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.alreadyAccount,
                            style: GoogleFonts.montserrat(
                              color: accountText,
                              decoration: TextDecoration.underline, //* Underline the text
                              decorationColor: accountText,
                              textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: Text(
                              AppLocalizations.of(context)!.login,
                              style: GoogleFonts.poppins(
                                color: onboardingColor,
                                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
