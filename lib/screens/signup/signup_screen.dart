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
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          "Additional Information",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 24),

                      Text(
                        "Please enter your contact details to continue",
                        style: GoogleFonts.poppins(
                          color: onboardingTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 18),

                      Divider(height: 2),

                      if (error.isNotEmpty)
                        Text(
                          error.split(":").skip(1).join(":").trim(),
                          style: const TextStyle(color: Colors.red),
                        ),

                      SizedBox(height: 16),

                      Text(
                        "Enter Your Name",
                        style: GoogleFonts.poppins(
                          color: signUpTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 12),

                      FormBuilderTextField(
                        name: 'username',
                        maxLength: 24,
                        autovalidateMode: validateMode,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.username(),
                        ]),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter Name",
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

                      SizedBox(height: 26),

                      Text(
                        "Enter Your Email",
                        style: GoogleFonts.poppins(
                          color: signUpTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 12),

                      FormBuilderTextField(
                        name: 'email',
                        maxLength: 30,
                        autovalidateMode: validateMode,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.email(),
                        ]),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter your Email",
                          prefixIcon: Icon(Icons.email_outlined, color: loginTextFieldIconColor),
                          filled: true,
                          fillColor: Colors.white,
                          // border: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(8),
                          //   borderSide: BorderSide.none,
                          // ),
                          // focusedErrorBorder: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(8),
                          //   borderSide: BorderSide.none,
                          // ),
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

                      SizedBox(height: 26),

                      // Text(
                      //   "Enter Phone Number",
                      //   style: GoogleFonts.poppins(
                      //     color: signUpTextColor,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 12),
                      //
                      // IntlPhoneField(
                      //   showCountryFlag: false,
                      //   dropdownTextStyle: GoogleFonts.poppins(
                      //     textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      //   ),
                      //   style: GoogleFonts.poppins(
                      //     textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      //   ),
                      //   pickerDialogStyle: PickerDialogStyle(backgroundColor: scaffoldBackgroundColor),
                      //   decoration: InputDecoration(
                      //     hintText: 'Enter Phone Number',
                      //     filled: true,
                      //     fillColor: Colors.white,
                      //     counterText: "",
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //     focusedErrorBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //   ),
                      //   initialCountryCode: 'US',
                      //   onChanged: (phone) {
                      //     try {
                      //       bool isValid = phone.isValidNumber();
                      //
                      //       setState(() {
                      //         isPhoneValidated = isValid;
                      //
                      //         if (isValid == true) {
                      //           phoneInfo.addAll({
                      //             "countryISOCode": phone.countryISOCode,
                      //             "countryCode": phone.countryCode,
                      //             "completeNumber": phone.completeNumber,
                      //           });
                      //         } else {
                      //           phoneInfo.clear();
                      //         }
                      //       });
                      //     } catch (e) {
                      //       setState(() {
                      //         isPhoneValidated = false;
                      //         phoneInfo.clear();
                      //       });
                      //     }
                      //   },
                      // ),
                      //
                      // SizedBox(height: 26),

                      // Text(
                      //   "Enter Your Address",
                      //   style: GoogleFonts.poppins(
                      //     color: signUpTextColor,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 12),
                      //
                      // // TODO: Address validation:
                      // FormBuilderTextField(
                      //   name: 'address',
                      //   maxLength: 60,
                      //   autovalidateMode: validateMode,
                      //   validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                      //   style: GoogleFonts.poppins(
                      //     textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      //   ),
                      //   decoration: InputDecoration(
                      //     counterText: "",
                      //     hintText: "Enter Address",
                      //     prefixIcon: Icon(Icons.location_on_outlined, color: loginTextFieldIconColor),
                      //     filled: true,
                      //     fillColor: Colors.white,
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //     focusedErrorBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 26),

                      Text(
                        "Enter Password",
                        style: GoogleFonts.poppins(
                          color: signUpTextColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      SizedBox(height: 12),

                      FormBuilderTextField(
                        name: 'password',
                        maxLength: 16,
                        obscureText: _obscureText,
                        autovalidateMode: validateMode,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                          FormBuilderValidators.minLength(
                            6,
                            errorText: "Password must not be less than 6 characters",
                          ),
                        ]),
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          hintText: "Enter Your Password",
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
                          // border: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(8),
                          //   borderSide: BorderSide.none,
                          // ),
                          // focusedErrorBorder: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(8),
                          //   borderSide: BorderSide.none,
                          // ),
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

                      // SizedBox(height: 26),
                      //
                      // Text(
                      //   "Select Mode",
                      //   style: GoogleFonts.poppins(
                      //     color: signUpTextColor,
                      //     fontSize: 14,
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 12),
                      //
                      // FormBuilderDropdown(
                      //   name: 'signUpMode',
                      //   // initialValue: 'Seller',
                      //   autovalidateMode: validateMode,
                      //   validator: FormBuilderValidators.compose([FormBuilderValidators.required()]),
                      //   hint: Text(
                      //     "Category",
                      //     style: GoogleFonts.poppins(
                      //       textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      //     ),
                      //   ),
                      //   decoration: InputDecoration(
                      //     prefixIcon: Icon(Icons.group, color: loginTextFieldIconColor),
                      //     filled: true,
                      //     fillColor: Colors.white,
                      //     border: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //     enabledBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //     focusedBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: loginTextFieldIconColor),
                      //     ),
                      //     focusedErrorBorder: OutlineInputBorder(
                      //       borderRadius: BorderRadius.circular(8),
                      //       borderSide: BorderSide(color: textFieldBorderSideColor),
                      //     ),
                      //   ),
                      //   dropdownColor: scaffoldBackgroundColor,
                      //   borderRadius: BorderRadius.circular(8),
                      //   elevation: 4,
                      //   menuMaxHeight: 300,
                      //   items: [
                      //     DropdownMenuItem(
                      //       value: 'Seller',
                      //       child: Text(
                      //         'Signup as Seller',
                      //         style: GoogleFonts.poppins(
                      //           textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      //         ),
                      //       ),
                      //     ),
                      //     DropdownMenuItem(
                      //       value: 'Buyer',
                      //       child: Text(
                      //         'Signup as Buyer',
                      //         style: GoogleFonts.poppins(
                      //           textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      const SizedBox(height: 52),

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
                                    if (_formKey.currentState!.validate()) {
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
                                          // phone: phoneInfo,
                                          // address: _formKey.currentState?.fields['address']?.value,
                                          // signUpMode: _formKey.currentState?.fields['signUpMode']?.value,
                                        );

                                        if (context.mounted) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                                  // : null,
                          child: Text(
                            "Signup",
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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
                            "Already have an account? ",
                            style: GoogleFonts.montserrat(
                              color: accountText,
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
                              "Login",
                              style: GoogleFonts.poppins(
                                color: onboardingColor,
                                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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
