import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

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
          "Edit Profile",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: SafeArea(
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

                      const Center(
                        child: Text(
                          'Change Photo',
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
                      const Text('Change Display Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      FormBuilderTextField(
                        name: 'name',
                        decoration: _buildInputDecoration('Enter Your Name'),
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Name is required.'),
                          FormBuilderValidators.minLength(3, errorText: 'Name must be at least 3 characters.'),
                        ]),
                      ),
                      const SizedBox(height: 14),

                      // --- PHONE NUMBER ---
                      const Text('Enter Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      FormBuilderTextField(
                        name: 'phone',
                        decoration: _buildInputDecoration('Enter Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Phone number is required.'),
                          FormBuilderValidators.numeric(errorText: 'Please enter a valid number.'),
                        ]),
                      ),
                      const SizedBox(height: 14),

                      // --- ADDRESS ---
                      const Text('Change Your Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      FormBuilderTextField(
                        name: 'address',
                        decoration: _buildInputDecoration('Enter Address'),
                        validator: FormBuilderValidators.required(errorText: 'Address is required.'),
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

                const SizedBox(height: 30),

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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // --- SAVE CHANGES BUTTON ---
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Validate and save the form state
                          if (_formKey.currentState?.saveAndValidate() ?? false) {
                            // Get the form data
                            final formData = _formKey.currentState?.value;
                            print("Form data is valid: $formData");

                            // You can now process the data, e.g., send it to an API
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Changes saved successfully!'),
                                backgroundColor: onboardingColor,
                              ),
                            );
                          } else {
                            print("Form data is invalid.");
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please correct the errors in the form.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: onboardingColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
