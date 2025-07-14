import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'package:farmers_hub/utils/constants.dart';

import 'package:farmers_hub/services/firebase_service.dart';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        title: Text(
          AppLocalizations.of(context)!.forgotPassword,
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
                padding: EdgeInsets.all(20),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                      if (error.isNotEmpty)
                        Text(
                          error.split(":").skip(1).join(":").trim(),
                          style: const TextStyle(color: Colors.red),
                        ),

                      SizedBox(height: 10),

                      Text(
                        // "Email Address",
                        AppLocalizations.of(context)!.emailAddress,
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
                          hintText: AppLocalizations.of(context)!.enterEmail,
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

                      SizedBox(height: 30),

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
                                firebaseService.sendForgetPasswordEmail(
                                  email: _formKey.currentState?.fields['email']?.value,
                                );

                                if (context.mounted) {
                                  Navigator.pop(context);
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
                            AppLocalizations.of(context)!.forgotPassword,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 50),
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