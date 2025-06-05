import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUserInteraction;
  String error = '';

  // Common style for input field borders
  final OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: BorderSide(color: Colors.grey.shade400),
  );
  final OutlineInputBorder _focusedInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: Colors.blue, width: 2.0),
  );
  final OutlineInputBorder _errorInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8.0),
    borderSide: const BorderSide(color: Colors.red, width: 1.0),
  );

  // Common style for labels
  final TextStyle _labelStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black87,
    fontSize: 16,
  );

  // Common padding for input content
  final EdgeInsets _contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  Widget build(BuildContext context) {
    Widget _buildRadioOptionContainer(String text, {bool isHorizontal = false}) {
      return Container(
        width: isHorizontal ? null : double.infinity, // Full width for vertical items
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade300),
          // Note: To change background on selection, you'd need to listen to form changes
          // and rebuild, or use a more complex custom FormBuilderField.
          // This basic styling provides the border.
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      );
    }

    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        // leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          "Create Post",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Add pictures for your Product',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                      SizedBox(height: 6),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Column(
                          children: [
                            Container(
                              // padding: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: onboardingColor, // Mimicking the dotted line color
                                  width: 2,
                                  // style: BorderStyle.dotted, // This doesn't work directly, use a package or custom painter
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  // Image preview area
                                  Container(
                                    height: 200, // Adjust height as needed
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Icon(Icons.image_outlined, size: 80, color: onboardingColor),
                                    ),
                                  ),

                                  // SizedBox(height: 16),

                                  // "Add Images" Button
                                  // We will use a custom button and trigger FormBuilderImagePicker indirectly
                                  // or manage state ourselves as FormBuilderImagePicker might not offer this exact UI.
                                  // For this example, I'm managing the state and image picking manually.
                                ],
                              ),
                            ),

                            SizedBox(height: 16),

                            Center(
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                                  label: Text(
                                    'Add Images',
                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                  ),
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: onboardingColor, // Button color
                                    padding: EdgeInsets.symmetric(vertical: 15),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 5,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, color: onboardingColor, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Add up to 4 photos for more views!',
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                ),
                              ],
                            ),

                            SizedBox(height: 15),

                            Card(
                              color: Colors.white,
                              elevation: 1.0, // Subtle shadow
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Add Post Title", style: _labelStyle),

                                    const SizedBox(height: 8),

                                    FormBuilderTextField(
                                      name: 'post_title',
                                      maxLength: 120,
                                      buildCounter:
                                          (
                                            context, {
                                            required currentLength,
                                            required isFocused,
                                            maxLength,
                                          }) => null,
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
                                        FormBuilderValidators.required(errorText: 'Post title is required.'),
                                        FormBuilderValidators.maxLength(120),
                                      ]),
                                    ),
                                    const SizedBox(height: 24),

                                    Text("Category", style: _labelStyle),
                                    const SizedBox(height: 8),

                                    FormBuilderRadioGroup<String>(
                                      name: 'category',
                                      decoration: const InputDecoration(
                                        border: InputBorder.none, // No border for the group itself
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      options: ['Goat', 'Sheep', 'Dog']
                                          .map(
                                            (category) => FormBuilderFieldOption(
                                              value: category,
                                              child: _buildRadioOptionContainer(category),
                                            ),
                                          )
                                          .toList(growable: false),
                                      orientation: OptionsOrientation.vertical,
                                      controlAffinity: ControlAffinity.leading,
                                      // Shows radio circle
                                      activeColor: Colors.blue,
                                      validator: FormBuilderValidators.required(
                                        errorText: 'Please select a category.',
                                      ),
                                      separator: const SizedBox(height: 10), // Spacing between options
                                    ),

                                    const SizedBox(height: 24),

                                    Text("Gender", style: _labelStyle),

                                    const SizedBox(height: 8),

                                    FormBuilderRadioGroup<String>(
                                      name: 'gender',
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      options: ['Male', 'Female']
                                          .map(
                                            (gender) => FormBuilderFieldOption(
                                              value: gender,
                                              child: _buildRadioOptionContainer(gender, isHorizontal: true),
                                            ),
                                          )
                                          .toList(growable: false),
                                      orientation: OptionsOrientation.horizontal,
                                      controlAffinity: ControlAffinity.leading,
                                      activeColor: Colors.blue,
                                      validator: FormBuilderValidators.required(
                                        errorText: 'Please select a gender.',
                                      ),
                                      separator: const SizedBox(width: 16), // Spacing between options
                                    ),

                                    const SizedBox(height: 24),

                                    // Average Weight (in kgs)
                                    Text("Average Weight (in kgs)", style: _labelStyle),
                                    const SizedBox(height: 8),
                                    FormBuilderTextField(
                                      name: 'avg_weight',
                                      decoration: InputDecoration(
                                        hintText: 'Enter Average Weight in kilograms',
                                        border: _inputBorder,
                                        enabledBorder: _inputBorder,
                                        focusedBorder: _focusedInputBorder,
                                        errorBorder: _errorInputBorder,
                                        focusedErrorBorder: _focusedInputBorder,
                                        contentPadding: _contentPadding,
                                        // The image shows a dropdown arrow, this is a stylistic choice.
                                        // If it's a free text field, suffixIcon is decorative.
                                        // If it's a dropdown, use FormBuilderDropdown.
                                        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(
                                          errorText: 'Average weight is required.',
                                        ),
                                        FormBuilderValidators.numeric(errorText: 'Must be a number.'),
                                        FormBuilderValidators.min(0, errorText: 'Weight cannot be negative.'),
                                      ]),
                                    ),

                                    const SizedBox(height: 16),

                                    Text("Quantity", style: _labelStyle),
                                    const SizedBox(height: 8),
                                    FormBuilderTextField(
                                      name: 'quantity',
                                      decoration: InputDecoration(
                                        hintText: 'Enter Quantity',
                                        border: _inputBorder,
                                        enabledBorder: _inputBorder,
                                        focusedBorder: _focusedInputBorder,
                                        errorBorder: _errorInputBorder,
                                        focusedErrorBorder: _focusedInputBorder,
                                        contentPadding: _contentPadding,
                                        suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(errorText: 'Quantity is required.'),
                                        FormBuilderValidators.integer(errorText: 'Must be a whole number.'),
                                        FormBuilderValidators.min(
                                          1,
                                          errorText: 'Quantity must be at least 1.',
                                        ),
                                      ]),
                                    ),
                                    const SizedBox(height: 16),

                                    Text("Age (in years)", style: _labelStyle),
                                    const SizedBox(height: 8),
                                    FormBuilderTextField(
                                      name: 'age',
                                      decoration: InputDecoration(
                                        hintText: 'Enter age in years',
                                        border: _inputBorder,
                                        enabledBorder: _inputBorder,
                                        focusedBorder: _focusedInputBorder,
                                        errorBorder: _errorInputBorder,
                                        focusedErrorBorder: _focusedInputBorder,
                                        contentPadding: _contentPadding,
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(errorText: 'Age is required.'),
                                        FormBuilderValidators.numeric(errorText: 'Must be a number.'),
                                        FormBuilderValidators.min(0, errorText: 'Age cannot be negative.'),
                                      ]),
                                    ),

                                    const SizedBox(height: 16),

                                    Text("Price", style: _labelStyle),
                                    const SizedBox(height: 8),
                                    FormBuilderTextField(
                                      name: 'price',
                                      decoration: InputDecoration(
                                        hintText: 'Enter Your Price',
                                        border: _inputBorder,
                                        enabledBorder: _inputBorder,
                                        focusedBorder: _focusedInputBorder,
                                        errorBorder: _errorInputBorder,
                                        focusedErrorBorder: _focusedInputBorder,
                                        contentPadding: _contentPadding,
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.required(errorText: 'Price is required.'),
                                        FormBuilderValidators.numeric(errorText: 'Must be a number.'),
                                        FormBuilderValidators.min(0, errorText: 'Price cannot be negative.'),
                                      ]),
                                    ),
                                    // const SizedBox(height: 30),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 2),

                      Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(8.9),
                        width: double.infinity,
                        color: Colors.white,
                        child: Text(
                          'Location, Contact & Delivery Details',
                          style: TextStyle(color: onboardingColor, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Location',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 6),

                            ElevatedButton.icon(
                              icon: const Icon(Icons.location_on, color: Colors.white),
                              label: const Text(
                                'Select Location',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: onboardingColor,
                                minimumSize: const Size(double.infinity, 50), // Full width button
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12), // Rounded corners
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: () {
                                // Placeholder for location selection logic
                                print('Select Location button pressed');
                                // You would typically navigate to a map screen or open a location picker
                              },
                            ),
                            const SizedBox(height: 10),

                            Card(
                              color: Colors.white,
                              elevation: 1.0, // Subtle shadow
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Additional Details", style: _labelStyle),

                                    const SizedBox(height: 8),

                                    FormBuilderTextField(
                                      name: 'add_details',
                                      maxLength: 120,
                                      buildCounter:
                                          (
                                            context, {
                                            required currentLength,
                                            required isFocused,
                                            maxLength,
                                          }) => null,
                                      // Hide default counter
                                      decoration: InputDecoration(
                                        hintText: 'Type here',
                                        border: _inputBorder,
                                        enabledBorder: _inputBorder,
                                        focusedBorder: _focusedInputBorder,
                                        errorBorder: _errorInputBorder,
                                        focusedErrorBorder: _focusedInputBorder,
                                        contentPadding: _contentPadding,
                                      ),
                                      validator: FormBuilderValidators.compose([
                                        FormBuilderValidators.maxLength(120),
                                      ]),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: onboardingColor,
                                minimumSize: const Size(double.infinity, 33), // Full width, slightly taller
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Submit',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),

                            const SizedBox(height: 24),
                          ],
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
    );
  }
}
