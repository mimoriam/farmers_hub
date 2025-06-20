import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/screens/home/home_screen.dart';
import 'package:farmers_hub/screens/signup/signup_screen.dart';
import 'package:farmers_hub/screens/signup/signup_google_screen.dart';
import 'package:farmers_hub/screens/forgot_password/forgot_password_screen.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_button/sign_button.dart';

import '../phone_auth/phone_auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;
  bool _obscureText = true;
  String error = '';

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final systemUiOverlayStyle = SystemUiOverlayStyle(statusBarColor: onboardingColor);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        backgroundColor: scaffoldBackgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  child: FormBuilder(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: 10),

                        Text(
                          "Login to YOUR CROP",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: onboardingTextColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          // style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),

                        SizedBox(height: 10),

                        Divider(height: 2),

                        if (error.isNotEmpty)
                          Text(
                            error.split(":").skip(1).join(":").trim(),
                            style: const TextStyle(color: Colors.red),
                          ),

                        SizedBox(height: 20),

                        Text(
                          "Email Address",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),

                        SizedBox(height: 10),

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

                        SizedBox(height: 16),

                        Text(
                          "Password",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),

                        SizedBox(height: 10),

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
                            //   borderRadius: BorderRadius.circular(10),
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

                        SizedBox(height: 10),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                            );
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: onboardingTextColor,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 32),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: onboardingColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                setState(() {
                                  error = '';
                                });
                                try {
                                  // final user = await firebaseService.loginWithEmail(
                                  await firebaseService.loginWithEmail(
                                    email: _formKey.currentState?.fields['email']?.value,
                                    password: _formKey.currentState?.fields['password']?.value,
                                  );

                                  if (context.mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                                    );
                                  }
                                } catch (e) {
                                  setState(() {
                                    error = e.toString();
                                  });
                                }
                              }
                            },
                            child: Text(
                              "Login",
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

                        SizedBox(height: 12),

                        // SizedBox(
                        //   width: double.infinity,
                        //   height: 50,
                        //   child: ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: onboardingColor,
                        //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        //     ),
                        //     onPressed: () {
                        //       if (context.mounted) {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(builder: (context) => PhoneAuthScreen()),
                        //         );
                        //       }
                        //     },
                        //     child: Text(
                        //       "Phone Authentication",
                        //       style: GoogleFonts.montserrat(
                        //         textStyle: TextStyle(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.w500,
                        //           color: Colors.white,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account? ",
                              style: GoogleFonts.montserrat(
                                color: accountText,
                                textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SignUpScreen()),
                                );
                              },
                              child: Text(
                                "Signup",
                                style: GoogleFonts.montserrat(
                                  color: onboardingColor,
                                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "or continue with",
                                style: GoogleFonts.montserrat(
                                  color: onboardingTextColor,
                                  textStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SignInButton.mini(
                              buttonType: ButtonType.apple,
                              onPressed: () {},
                              elevation: 1,
                              btnColor: scaffoldBackgroundColor,
                            ),

                            SignInButton.mini(
                              buttonType: ButtonType.google,
                              onPressed: () async {
                                try {
                                  final user = await firebaseService.signInWithGoogle();
                                  if (user.additionalUserInfo?.isNewUser ?? false) {
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignupGoogleScreen(user: user),
                                        ),
                                      );
                                    }
                                  } else {
                                    // Feat: Check if user has completed registration properly
                                    final userExists = await firebaseService
                                        .checkIfUserDataExistsForSocialLogin(user: user.user!);

                                    if (userExists) {
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SignupGoogleScreen(user: user),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                } catch (e) {
                                  debugPrint(e.toString());
                                }
                              },
                              elevation: 1,
                              btnColor: scaffoldBackgroundColor,
                            ),

                            SignInButton.mini(
                              buttonType: ButtonType.facebook,
                              onPressed: () {},
                              elevation: 1,
                              btnColor: scaffoldBackgroundColor,
                            ),
                          ],
                        ),

                        SizedBox(height: 30),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       "Don't have an account? ",
                        //       style: GoogleFonts.montserrat(
                        //         color: accountText,
                        //         textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                        //       ),
                        //     ),
                        //     GestureDetector(
                        //       onTap: () {
                        //         Navigator.push(
                        //           context,
                        //           MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        //         );
                        //       },
                        //       child: Text(
                        //         "Signup",
                        //         style: GoogleFonts.montserrat(
                        //           color: onboardingColor,
                        //           textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),

              // MediaQuery.of(context).viewInsets.bottom == 0.0
              //     ? Align(
              //       alignment: Alignment.bottomCenter,
              //       child: Padding(
              //         padding: const EdgeInsets.only(bottom: 12.0),
              //         child: Container(
              //           // margin: const EdgeInsets.only(bottom: 8.0),
              //           width: 105,
              //           height: 5,
              //           decoration: BoxDecoration(
              //             // color: Colors.white.withValues(alpha: 0.5),
              //             color: Colors.black12,
              //             borderRadius: BorderRadius.circular(2.5),
              //           ),
              //         ),
              //       ),
              //     )
              //     : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
