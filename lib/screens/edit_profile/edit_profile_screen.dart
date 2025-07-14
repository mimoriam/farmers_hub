import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  final FirebaseService _firebaseService = FirebaseService();

  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  InputDecoration _buildInputDecoration(String hintText, {IconData? prefixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.grey) : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: onboardingColor, width: 2.0),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: const BorderSide(color: Colors.red, width: 2.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,

      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.editProfile,
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: FutureBuilder<DocumentSnapshot?>(
        future: _firebaseService.getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return const Center(
            //   child: CircularProgressIndicator(color: onboardingColor),
            // );

            return Skeletonizer(
              ignoreContainers: true,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Stack(
                                children: [
                                  const CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.deepOrange,
                                    child: Text('A', style: TextStyle(fontSize: 40, color: Colors.white)),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.camera_alt, color: onboardingColor, size: 24),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            Center(
                              child: Text(
                                AppLocalizations.of(context)!.changePhoto,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- DISPLAY NAME ---
                          Text(
                            AppLocalizations.of(context)!.changeDisplayName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextField(decoration: _buildInputDecoration(AppLocalizations.of(context)!.enterName)),
                          const SizedBox(height: 14),

                          // --- PHONE NUMBER ---
                          Text(
                            AppLocalizations.of(context)!.enterPhoneNumber,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextField(decoration: _buildInputDecoration(AppLocalizations.of(context)!.enterName)),
                          const SizedBox(height: 14),

                          // --- ADDRESS ---
                          Text(
                            AppLocalizations.of(context)!.changeAddress,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          TextField(decoration: _buildInputDecoration(AppLocalizations.of(context)!.enterAddress)),
                          const SizedBox(height: 14),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.cancel,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // --- SAVE CHANGES BUTTON ---
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: onboardingColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.saveChanges,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(child: Text(AppLocalizations.of(context)!.failedToLoad));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          final initialName = userData?['username'] ?? '';
          final location = userData?["location"] ?? "";
          final phoneNumber = userData?["phoneInfo"] ?? "";

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: onboardingColor,
                                  backgroundImage:
                                  _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (userData?['profileImage'] != "default_pfp.jpg"
                                      ? NetworkImage(userData?['profileImage'])
                                      : null)
                                  as ImageProvider?,
                                  child:
                                  _imageFile == null && (userData?['profileImage'] == "default_pfp.jpg")
                                      ? Text('A', style: TextStyle(fontSize: 40, color: Colors.white))
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 1)),
                                      ],
                                    ),
                                    child: const Icon(Icons.camera_alt, color: onboardingColor, size: 24),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.changePhoto,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    FormBuilder(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- DISPLAY NAME ---
                          Text(
                            AppLocalizations.of(context)!.changeDisplayName,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          FormBuilderTextField(
                            name: 'username',
                            decoration: _buildInputDecoration(AppLocalizations.of(context)!.enterName),
                            initialValue: initialName,
                            // readOnly: true,
                            // enabled: false,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: AppLocalizations.of(context)!.nameRequires),
                              FormBuilderValidators.minLength(
                                3,
                                errorText: AppLocalizations.of(context)!.nameMustHaveThreeLetters,
                              ),
                            ]),
                          ),
                          const SizedBox(height: 14),

                          // --- PHONE NUMBER ---
                          Text(
                            AppLocalizations.of(context)!.enterPhoneNumber,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          FormBuilderTextField(
                            name: 'phone',
                            enabled: false,
                            decoration: _buildInputDecoration(AppLocalizations.of(context)!.enterPhoneNumber),
                            initialValue:
                            phoneNumber["completeNumber"].isEmpty
                                ? ""
                                : "${phoneNumber["completeNumber"]}",
                            keyboardType: TextInputType.phone,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: AppLocalizations.of(context)!.phoneNumberRequires),
                              FormBuilderValidators.numeric(errorText: AppLocalizations.of(context)!.validPhoneNumber),
                            ]),
                          ),
                          const SizedBox(height: 14),

                          // --- ADDRESS ---
                          Text(
                            AppLocalizations.of(context)!.changeAddress,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          FormBuilderTextField(
                            name: 'address',
                            decoration: _buildInputDecoration(AppLocalizations.of(context)!.enterAddress),
                            // initialValue:
                            //     location["city"].isEmpty ? "" : "${location["city"]} ${location["province"]}",
                            initialValue: location["city"].isEmpty ? "" : "${location["city"]}",
                            validator: FormBuilderValidators.required(errorText: AppLocalizations.of(context)!.addressRequires),
                          ),
                          const SizedBox(height: 14),

                          // --- CITY DROPDOWN ---
                          // const Text('Choose City of Residence', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          // const SizedBox(height: 8),
                          // FormBuilderDropdown<String>(
                          //   name: 'city',
                          //   decoration: _buildInputDecoration('Select City', prefixIcon: Icons.location_on),
                          //   items: ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix']
                          //       .map((city) => DropdownMenuItem(
                          //     value: city,
                          //     child: Text(city),
                          //   ))
                          //       .toList(),
                          //   validator: FormBuilderValidators.required(errorText: 'Please select a city.'),
                          // ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        // --- CANCEL BUTTON ---
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _formKey.currentState?.reset();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        // --- SAVE CHANGES BUTTON ---
                        Expanded(
                          child: TapDebouncer(
                            cooldown: const Duration(milliseconds: 1000),
                            onTap: () async {
                              // Validate and save the form state
                              if (_formKey.currentState!.validate()) {
                                // Get the form data

                                final Map<String, dynamic> updatedData = {
                                  'username': _formKey.currentState?.fields['username']?.value,
                                  'location': {"city": _formKey.currentState?.fields['address']?.value},
                                  "phoneInfo": {
                                    "completeNumber": _formKey.currentState?.fields['phone']?.value,
                                  },
                                  // Use dot notation to update a nested field
                                  // 'phoneInfo.completeNumber': _formKey.currentState?.fields['phone']?.value,
                                };

                                if (_imageFile != null) {
                                  String? imageUrl = await _firebaseService.uploadProfileImage(_imageFile!);
                                  if (imageUrl != null) {
                                    updatedData['profileImage'] = imageUrl;
                                  }
                                }

                                try {
                                  await _firebaseService.updateUserProfile(updatedData);

                                  // Optionally navigate back after saving
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.changesSuccess),
                                        backgroundColor: onboardingColor,
                                      ),
                                    );

                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.error + ' ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }

                                // You can now process the data, e.g., send it to an API
                                // ScaffoldMessenger.of(context).showSnackBar(
                                //   const SnackBar(
                                //     content: Text('Changes saved successfully!'),
                                //     backgroundColor: onboardingColor,
                                //   ),
                                // );
                              } else {
                                print("Form data is invalid.");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!.errorsCorrection),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },

                            builder: (BuildContext context, TapDebouncerFunc? onTap) {
                              return ElevatedButton(
                                onPressed: onTap,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: onboardingColor,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.saveChanges,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}