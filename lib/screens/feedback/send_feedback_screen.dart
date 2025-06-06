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
          "Send Feedback",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 8),
                    child: Container(
                      // color: onboardingColor,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: onboardingColor,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Send Us Your Feedback!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Do you have a suggestion or found a bug? Let us know in the field below.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 8),

                  Card(
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

                          Text("How was your experience?"),

                          SizedBox(height: 10),

                          RatingBar.builder(
                            initialRating: 0,
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

                          Text("Describe your experience here... "),

                          SizedBox(height: 6),

                          FormBuilderTextField(
                            name: 'post_title',
                            maxLength: 240,
                            maxLines: 6,
                            buildCounter:
                                (context, {required currentLength, required isFocused, maxLength}) => null,
                            // Hide default counter
                            decoration: InputDecoration(
                              hintText: 'Type here',
                              border: _inputBorder,
                              enabledBorder: _inputBorder,
                              focusedBorder: _focusedInputBorder,
                              errorBorder: _errorInputBorder,
                              focusedErrorBorder: _focusedInputBorder,
                              contentPadding: _contentPadding,
                              helperText: 'Max 120 Characters',
                              helperStyle: TextStyle(color: Colors.grey[600]),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'Feedback is required.'),
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
                                  const Text('Bug'),
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
                                  const Text('Suggestion'),
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
                                    const Text('Others'),
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
                                "Send Feedback",
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
