import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SendFeedBackScreen extends StatefulWidget {
  const SendFeedBackScreen({super.key});

  @override
  State<SendFeedBackScreen> createState() => _SendFeedBackScreenState();
}

enum FeedbackType { bug, suggestion, others }

class _SendFeedBackScreenState extends State<SendFeedBackScreen> {
  final OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: Colors.grey.shade400),
  );
  final OutlineInputBorder _focusedInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: onboardingColor, width: 2.0),
  );
  final OutlineInputBorder _errorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: Colors.red, width: 1.0),
  );

  // Common style for labels
  final EdgeInsets _contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  FeedbackType _selectedFeedbackType = FeedbackType.bug;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,

      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.sendFeedback,
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8, top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.sendYourFeedback,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 23),
                        child: Text(
                          AppLocalizations.of(context)!.suggestions,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      // side: BorderSide(color: categoriesBorderColor, width: 1),
                    ),
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 4),

                          Text(AppLocalizations.of(context)!.yourExperience),

                          SizedBox(height: 10),

                          RatingBar.builder(
                            initialRating: 3,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              switch (index) {
                                case 0:
                                  return Icon(Icons.sentiment_dissatisfied, color: Colors.redAccent);

                                case 1:
                                  return Icon(Icons.sentiment_neutral, color: Colors.amber);

                                case 2:
                                  return Icon(Icons.sentiment_very_satisfied, color: Colors.lightGreen);

                                default: // This handles any other index value
                                  return Icon(Icons.star);
                              }
                            },
                            onRatingUpdate: (rating) {
                              print(rating);
                            },
                          ),

                          SizedBox(height: 20),

                          Text(AppLocalizations.of(context)!.describeExperience),

                          SizedBox(height: 6),

                          FormBuilderTextField(
                            name: 'post_title',
                            maxLength: 240,
                            maxLines: 6,
                            buildCounter:
                                (context, {required currentLength, required isFocused, maxLength}) => null,
                            // Hide default counter
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.typeHere,
                              border: _inputBorder,
                              enabledBorder: _inputBorder,
                              focusedBorder: _focusedInputBorder,
                              errorBorder: _errorInputBorder,
                              focusedErrorBorder: _focusedInputBorder,
                              contentPadding: _contentPadding,
                              // helperText: 'Max 120 Characters',
                              counterText: "",
                              counter:  Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  AppLocalizations.of(context)!.maxChars,
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ),
                              helperStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: AppLocalizations.of(context)!.feedbackRequires),
                              FormBuilderValidators.maxLength(120),
                            ]),
                          ),

                          SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Radio<FeedbackType>(
                                    value: FeedbackType.bug,
                                    groupValue: _selectedFeedbackType,
                                    activeColor: onboardingColor,
                                    onChanged: (FeedbackType? value) {
                                      setState(() {
                                        _selectedFeedbackType = value!;
                                      });
                                    },
                                  ),
                                  Text(AppLocalizations.of(context)!.bug),
                                ],
                              ),

                              Row(
                                children: [
                                  Radio<FeedbackType>(
                                    value: FeedbackType.suggestion,
                                    groupValue: _selectedFeedbackType,
                                    activeColor: onboardingColor,
                                    onChanged: (FeedbackType? value) {
                                      setState(() {
                                        _selectedFeedbackType = value!;
                                      });
                                    },
                                  ),
                                  Text(AppLocalizations.of(context)!.suggestion),
                                ],
                              ),

                              Expanded(
                                child: Row(
                                  children: [
                                    Radio<FeedbackType>(
                                      value: FeedbackType.others,
                                      activeColor: onboardingColor,
                                      groupValue: _selectedFeedbackType,
                                      onChanged: (FeedbackType? value) {
                                        setState(() {
                                          _selectedFeedbackType = value!;
                                        });
                                      },
                                    ),
                                    Text(AppLocalizations.of(context)!.others),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: onboardingColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {},
                              child: Text(
                                AppLocalizations.of(context)!.submitFeedback,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}