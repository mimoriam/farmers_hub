import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:farmers_hub/screens/home/home_screen.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

class EditPostScreen extends StatefulWidget {
  final String postId;

  const EditPostScreen({super.key, required this.postId});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final firebaseService = FirebaseService();

  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUnfocus;
  String error = '';

  final ScrollController _scrollController = ScrollController();

  String? selectedCategory;
  String? selectedGender;

  List<dynamic> _imageUrls = [];
  List<File> _newImages = [];

  final List<String> _removedImageUrls = [];
  final picker = ImagePicker();
  bool _isLoadingImages = true;

  Future<void> _loadPostImages() async {
    final postDetails = await firebaseService.getPostDetails(widget.postId);
    if (mounted) {
      setState(() {
        if (postDetails.containsKey('imageUrls')) {
          _imageUrls = List<dynamic>.from(postDetails['imageUrls']);
        }
        _isLoadingImages = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPostImages();
  }

  Future<void> _pickImage() async {
    final int totalImages = _imageUrls.length + _newImages.length;

    if (totalImages >= 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('You can only have up to 4 images.')));
      return;
    }

    final int remaining = 4 - totalImages;

    if (remaining == 1) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _newImages.add(File(pickedFile.path));
        });
      }
    } else {
      final pickedFiles = await picker.pickMultiImage(limit: remaining);
      if (pickedFiles.isNotEmpty) {
        setState(() {
          _newImages.addAll(pickedFiles.map((file) => File(file.path)));
        });
      }
    }

    if (_imageUrls.length + _newImages.length <= 4) {
      setState(() {
        error = '';
      });
    }
  }

  // *** MODIFIED: Track URL before removing from UI ***
  void _removeExistingImage(int index) {
    setState(() {
      _removedImageUrls.add(_imageUrls[index] as String);
      _imageUrls.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  // Common style for input field borders
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
  final TextStyle _labelStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    // color: Colors.black87,
    fontSize: 16,
  );

  // Common padding for input content
  final EdgeInsets _contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          "Edit Post",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),

      body: FutureBuilder(
        future: firebaseService.getPostDetails(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // return Center(child: CircularProgressIndicator(color: onboardingColor,));
            return Skeletonizer(
              ignorePointers: true,
              ignoreContainers: true,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        radius: const Radius.circular(20),
                        color: onboardingColor,
                        strokeWidth: 1,
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(12)),
                        child: Container(
                          width: double.infinity,
                          height: 340,
                          color: Colors.white,
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 2,
                              mainAxisSpacing: 2,
                            ),
                            itemCount:
                                _imageUrls.length +
                                _newImages.length +
                                ((_imageUrls.length + _newImages.length < 4) ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index < _imageUrls.length) {
                                return Stack(
                                  children: [
                                    Image.network(
                                      _imageUrls[index],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.close, color: Colors.black, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else if (index < _imageUrls.length + _newImages.length) {
                                final newImageIndex = index - _imageUrls.length;

                                return Stack(
                                  children: [
                                    Image.file(
                                      _newImages[newImageIndex],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                    Positioned(
                                      top: 4,
                                      left: 4,
                                      child: GestureDetector(
                                        onTap: () {},
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(Icons.close, color: Colors.black, size: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return Center(
                                  child: IconButton(
                                    icon: Icon(Icons.add_a_photo, size: 40, color: onboardingColor),
                                    onPressed: _pickImage,
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    ListView.builder(
                      itemCount: 4,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            title: Text('Item number $index as title'),
                            subtitle: const Text('Subtitle here'),
                            trailing: const Icon(Icons.ac_unit),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Failed to load user data."));
          }

          final postDetails = snapshot.data;

          final postTitle = postDetails!["title"];
          var postCity = postDetails["location"]["city"];
          final postVillage = postDetails["location"]["village"];
          final postCategory = postDetails["category"];
          final postQuantity = postDetails["quantity"];
          final postPrice = postDetails["price"];
          final postGender = postDetails["gender"];
          final postWeight = postDetails["averageWeight"];
          final postAge = postDetails["age"];
          final postDetailsDetailsLolWhatAName = postDetails["details"];

          return SafeArea(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: FormBuilder(
                      key: _formKey,
                      // IMPORTANT to remove all references from dynamic field when delete
                      clearValueOnUnregister: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SizedBox(height: 2),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: _buildImagePickerSection(), // --- MODIFIED UI WIDGET ---
                          ),

                          // Center(
                          //   child: Text(
                          //     'Add pictures for your Product',
                          //     textAlign: TextAlign.center,
                          //     style: TextStyle(
                          //       fontSize: 17,
                          //       fontWeight: FontWeight.bold,
                          //       color: Colors.grey[800],
                          //     ),
                          //   ),
                          // ),
                          // SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            child: Column(
                              children: [
                                // Container(
                                //   // padding: EdgeInsets.only(bottom: 16),
                                //   decoration: BoxDecoration(
                                //     border: Border.all(
                                //       color: onboardingColor, // Mimicking the dotted line color
                                //       width: 2,
                                //       // style: BorderStyle.dotted, // This doesn't work directly, use a package or custom painter
                                //     ),
                                //     borderRadius: BorderRadius.circular(12),
                                //   ),
                                //   child: Column(
                                //     children: [
                                //       // Image preview area
                                //       Container(
                                //         height: 200, // Adjust height as needed
                                //         width: double.infinity,
                                //         decoration: BoxDecoration(
                                //           color: Colors.white,
                                //           borderRadius: BorderRadius.circular(8),
                                //         ),
                                //         child: Center(
                                //           child: Icon(Icons.image_outlined, size: 40, color: onboardingColor),
                                //         ),
                                //       ),
                                //
                                //       // SizedBox(height: 16),
                                //
                                //       // "Add Images" Button
                                //       // We will use a custom button and trigger FormBuilderImagePicker indirectly
                                //       // or manage state ourselves as FormBuilderImagePicker might not offer this exact UI.
                                //       // For this example, I'm managing the state and image picking manually.
                                //     ],
                                //   ),
                                // ),
                                //
                                // SizedBox(height: 16),

                                // Center(
                                //   child: SizedBox(
                                //     width: double.infinity,
                                //     child: ElevatedButton.icon(
                                //       icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
                                //       label: Text(
                                //         'Add Images',
                                //         style: TextStyle(fontSize: 16, color: Colors.white),
                                //       ),
                                //       onPressed: () {},
                                //       style: ElevatedButton.styleFrom(
                                //         backgroundColor: onboardingColor, // Button color
                                //         padding: EdgeInsets.symmetric(vertical: 15),
                                //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                //         elevation: 5,
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                // DottedBorder(
                                //   options: RoundedRectDottedBorderOptions(
                                //     radius: const Radius.circular(20),
                                //     color: onboardingColor,
                                //     strokeWidth: 1,
                                //     // dashPattern: const [6, 6],
                                //   ),
                                //   child: ClipRRect(
                                //     borderRadius: const BorderRadius.all(Radius.circular(12)),
                                //     child: Container(
                                //       width: double.infinity, // Take up all available horizontal space.
                                //       height: 260, // Fixed height for the container.
                                //       color: Colors.white, // Background color of the container.
                                //       child: Padding(
                                //         padding: const EdgeInsets.only(left: 10, right: 10, top: 56, bottom: 10),
                                //         child: Column(
                                //           mainAxisAlignment: MainAxisAlignment.center,
                                //           // Center the content vertically.
                                //           children: [
                                //             // The Expanded widget allows the icon to take up available space,
                                //             // pushing the button to the bottom.
                                //             const Expanded(
                                //               child: Center(
                                //                 child: Icon(
                                //                   Icons.image_outlined,
                                //                   size: 36,
                                //                   color: onboardingColor,
                                //                 ),
                                //               ),
                                //             ),
                                //             const SizedBox(height: 20),
                                //             // This is the "Add Images" button.
                                //             SizedBox(
                                //               width: double.infinity,
                                //               // Make button take full width of its parent.
                                //               child: ElevatedButton.icon(
                                //                 onPressed: () {
                                //                   // TODO: Implement image picking logic here.
                                //                 },
                                //                 icon: const Icon(
                                //                   Icons.add_photo_alternate_rounded,
                                //                   color: Colors.white,
                                //                 ),
                                //                 label: const Text(
                                //                   'Add Images',
                                //                   style: TextStyle(
                                //                     color: Colors.white,
                                //                     fontSize: 16,
                                //                     fontWeight: FontWeight.bold,
                                //                   ),
                                //                 ),
                                //                 style: ElevatedButton.styleFrom(
                                //                   backgroundColor: onboardingColor, // Button background color.
                                //                   padding: const EdgeInsets.symmetric(vertical: 16),
                                //                   shape: RoundedRectangleBorder(
                                //                     borderRadius: BorderRadius.circular(12),
                                //                   ),
                                //                   elevation: 2, // Adds a subtle shadow.
                                //                 ),
                                //               ),
                                //             ),
                                //           ],
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                //
                                // SizedBox(height: 15),
                                _imageUrls.length + _newImages.length >= 4
                                    ? Container()
                                    : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.info_outline, color: onboardingColor, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'You can add up to 4 photos.',
                                          style: TextStyle(fontSize: 14, color: Colors.black),
                                        ),
                                      ],
                                    ),

                                SizedBox(height: 4),

                                error.isNotEmpty
                                    ? Text(error, style: TextStyle(color: Colors.red, fontSize: 18))
                                    : Container(),

                                error.isNotEmpty ? SizedBox(height: 10) : Container(),

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
                                        Text("Edit Post Title", style: _labelStyle),

                                        const SizedBox(height: 8),

                                        FormBuilderTextField(
                                          name: 'title',
                                          maxLength: 120,
                                          maxLines: 2,
                                          initialValue: postTitle,
                                          autovalidateMode: validateMode,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]*$')),
                                          ],
                                          // buildCounter:
                                          //     (
                                          //       context, {
                                          //       required currentLength,
                                          //       required isFocused,
                                          //       maxLength,
                                          //     }) => null,
                                          // Hide default counter
                                          decoration: InputDecoration(
                                            hintText: 'Type here',
                                            hintStyle: TextStyle(color: loginTextFieldIconColor),
                                            counterText: "",
                                            // counter: const Align(
                                            //   alignment: Alignment.centerRight,
                                            //   child: Text(
                                            //     'Max 120 Characters',
                                            //     style: TextStyle(color: Colors.grey, fontSize: 12),
                                            //   ),
                                            // ),
                                            border: _inputBorder,
                                            enabledBorder: _inputBorder,
                                            focusedBorder: _focusedInputBorder,
                                            errorBorder: _errorInputBorder,
                                            focusedErrorBorder: _focusedInputBorder,
                                            contentPadding: _contentPadding,
                                            // helperText: 'Max 120 Characters',
                                            // helperStyle: TextStyle(color: Colors.grey[600]),
                                          ),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(
                                              errorText: 'Post title is required.',
                                            ),
                                            FormBuilderValidators.maxLength(120),
                                          ]),
                                        ),

                                        const SizedBox(height: 8),

                                        Text("City", style: _labelStyle),
                                        const SizedBox(height: 8),

                                        Padding(
                                          // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                          padding: const EdgeInsets.only(right: 0, left: 0, bottom: 10),
                                          child: DropdownButtonFormField2<String>(
                                            autovalidateMode: validateMode,
                                            decoration: InputDecoration(
                                              labelText: "Select Your City",
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              contentPadding: const EdgeInsets.symmetric(
                                                vertical: 0,
                                                horizontal: 6,
                                              ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: onboardingTextColor,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              errorBorder: _errorInputBorder,
                                              enabledBorder: _inputBorder,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: onboardingTextColor,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            iconStyleData: IconStyleData(
                                              // Using IconStyleData for icon properties
                                              iconEnabledColor: onboardingTextColor,
                                            ),

                                            value: postCity,

                                            // value: widget.location != null ? widget.location : "Damascus",
                                            dropdownStyleData: DropdownStyleData(
                                              maxHeight: 160,
                                              offset: const Offset(0, -10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.white,
                                              ),
                                            ),

                                            // value: "Damascus",
                                            items:
                                                [
                                                  'Damascus',
                                                  'Aleppo',
                                                  'Homs',
                                                  'Hama',
                                                  "Latakia",
                                                  "Tartus",
                                                  "Baniyas",
                                                  "Idlib",
                                                  "Deir ez-Zor",
                                                  "Al-Hasakah",
                                                  "Qamishli",
                                                  "Raqqa",
                                                  "Daraa",
                                                  "As-Suwayda",
                                                  "Quneitra",
                                                  "Al-Mayadin",
                                                  "Al-Bukamal",
                                                  "Rif Dimashq",
                                                  "Afrin",
                                                  'Manbij',
                                                  "Tell Abyad",
                                                  "Ras al-Ayn",
                                                  "Kobani",
                                                ].map((city) {
                                                  return DropdownMenuItem<String>(
                                                    onTap: () {},
                                                    value: city,
                                                    child: Text(city),
                                                  );
                                                }).toList(),
                                            validator: (value) {
                                              if (value == null) {
                                                return 'City is required.';
                                              }
                                              return null;
                                            },
                                            onChanged: (String? value) {
                                              postCity = value;
                                            },
                                          ),
                                        ),

                                        Text("Village", style: _labelStyle),
                                        const SizedBox(height: 8),

                                        FormBuilderTextField(
                                          name: 'village',
                                          maxLength: 120,
                                          initialValue: postVillage,
                                          autovalidateMode: validateMode,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9 ]*$')),
                                          ],
                                          decoration: InputDecoration(
                                            hintText: 'Enter Village',
                                            counterText: "",
                                            border: _inputBorder,
                                            enabledBorder: _inputBorder,
                                            focusedBorder: _focusedInputBorder,
                                            errorBorder: _errorInputBorder,
                                            focusedErrorBorder: _focusedInputBorder,
                                            contentPadding: _contentPadding,
                                            // The image shows a dropdown arrow, this is a stylistic choice.
                                            // If it's a free text field, suffixIcon is decorative.
                                            // If it's a dropdown, use FormBuilderDropdown.
                                            // suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                          ),
                                          // keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(errorText: 'Village is required.'),
                                          ]),
                                        ),

                                        const SizedBox(height: 8),

                                        Text("Category", style: _labelStyle),
                                        const SizedBox(height: 8),

                                        Padding(
                                          // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                          padding: const EdgeInsets.only(right: 0, left: 0, bottom: 10),
                                          child: DropdownButtonFormField2<String>(
                                            autovalidateMode: validateMode,
                                            decoration: InputDecoration(
                                              labelText: "Select a category",
                                              floatingLabelBehavior: FloatingLabelBehavior.never,
                                              contentPadding: const EdgeInsets.symmetric(
                                                vertical: 0,
                                                horizontal: 6,
                                              ),
                                              // enabledBorder: OutlineInputBorder(
                                              //   borderSide: BorderSide(color: onboardingTextColor, width: 1.0),
                                              //   borderRadius: BorderRadius.circular(8),
                                              // ),
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: onboardingTextColor,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              enabledBorder: _inputBorder,
                                              errorBorder: _errorInputBorder,
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: onboardingTextColor,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                            ),
                                            iconStyleData: IconStyleData(
                                              // Using IconStyleData for icon properties
                                              iconEnabledColor: onboardingTextColor,
                                            ),

                                            dropdownStyleData: DropdownStyleData(
                                              maxHeight: 160,
                                              offset: const Offset(0, -10),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                color: Colors.white,
                                              ),
                                            ),

                                            // value: "Damascus",
                                            items:
                                                [
                                                      'Fruits',
                                                      'Vegetables',
                                                      'Olive Oil',
                                                      "Live Stock",
                                                      'Grains & Seeds',
                                                      "Fertilizers",
                                                      "Tools",
                                                      "Land Services",
                                                      "Equipments",
                                                      "Delivery",
                                                      "Worker Services",
                                                      "Pesticides",
                                                      "Animal Feed",
                                                      "Others",
                                                    ]
                                                    .map(
                                                      (lang) => DropdownMenuItem<String>(
                                                        value: lang,
                                                        child: Text(lang),
                                                      ),
                                                    )
                                                    .toList(),
                                            // value: selectedCategory,
                                            // TODO FIX THIS TOO FOR EDIT
                                            value: postCategory,
                                            validator: (String? value) {
                                              if (value == null) {
                                                return 'Category is required.';
                                              }
                                              return null;
                                            },
                                            // onChanged: (String? value) {
                                            //   setState(() {
                                            //     selectedCategory = value;
                                            //   });
                                            // },
                                            onChanged: null,
                                          ),
                                        ),

                                        // FormBuilderRadioGroup<String>(
                                        //   name: 'category',
                                        //   decoration: const InputDecoration(
                                        //     border: InputBorder.none, // No border for the group itself
                                        //     contentPadding: EdgeInsets.zero,
                                        //   ),
                                        //   options: ['Goat', 'Sheep', 'Dog']
                                        //       .map(
                                        //         (category) => FormBuilderFieldOption(
                                        //           value: category,
                                        //           child: _buildRadioOptionContainer(category),
                                        //         ),
                                        //       )
                                        //       .toList(growable: false),
                                        //   orientation: OptionsOrientation.vertical,
                                        //   controlAffinity: ControlAffinity.leading,
                                        //   // Shows radio circle
                                        //   activeColor: onboardingColor,
                                        //   validator: FormBuilderValidators.required(
                                        //     errorText: 'Please select a category.',
                                        //   ),
                                        //   separator: const SizedBox(height: 3), // Spacing between options
                                        // ),
                                        // const SizedBox(height: 2),
                                        postCategory == null
                                            ? Container()
                                            : Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                postCategory != "Live Stock" ||
                                                        postCategory != "Worker Services"
                                                    ? Container()
                                                    : Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Gender", style: _labelStyle),

                                                        const SizedBox(height: 8),

                                                        Padding(
                                                          // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                                          padding: const EdgeInsets.only(
                                                            right: 0,
                                                            left: 0,
                                                            bottom: 10,
                                                          ),
                                                          child: DropdownButtonFormField2<String>(
                                                            autovalidateMode: validateMode,
                                                            decoration: InputDecoration(
                                                              labelText: "Select a Gender",
                                                              floatingLabelBehavior:
                                                                  FloatingLabelBehavior.never,
                                                              contentPadding: const EdgeInsets.symmetric(
                                                                vertical: 0,
                                                                horizontal: 6,
                                                              ),
                                                              border: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                  color: onboardingTextColor,
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                              enabledBorder: _inputBorder,
                                                              errorBorder: _errorInputBorder,
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                  color: onboardingTextColor,
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius: BorderRadius.circular(12),
                                                              ),
                                                            ),
                                                            iconStyleData: IconStyleData(
                                                              // Using IconStyleData for icon properties
                                                              iconEnabledColor: onboardingTextColor,
                                                            ),

                                                            dropdownStyleData: DropdownStyleData(
                                                              maxHeight: 160,
                                                              offset: const Offset(0, -10),
                                                              decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(12),
                                                                color: Colors.white,
                                                              ),
                                                            ),

                                                            // value: "Damascus",
                                                            items:
                                                                ['Male', 'Female']
                                                                    .map(
                                                                      (gender) => DropdownMenuItem<String>(
                                                                        value: gender,
                                                                        child: Text(gender),
                                                                      ),
                                                                    )
                                                                    .toList(),

                                                            // TODO AGAIN FIX
                                                            // value: selectedGender,
                                                            value: postGender.isEmpty ? "" : postGender,
                                                            validator: (String? value) {
                                                              if (value == null) {
                                                                return 'Gender is required.';
                                                              }
                                                              return null;
                                                            },
                                                            onChanged: (String? value) {
                                                              setState(() {
                                                                selectedGender = value;
                                                              });
                                                            },
                                                          ),
                                                        ),

                                                        const SizedBox(height: 2),
                                                      ],
                                                    ),

                                                // Average Weight (in kgs)
                                                postCategory == "Fruits" ||
                                                        postCategory == "Vegetables" ||
                                                        postCategory == "Olive Oil" ||
                                                        postCategory == "Grains & Seeds" ||
                                                        postCategory == "Fertilizers" ||
                                                        postCategory == "Tools" ||
                                                        postCategory == "Land Services" ||
                                                        postCategory == "Equipments" ||
                                                        postCategory == "Delivery" ||
                                                        postCategory == "Pesticides" ||
                                                        postCategory == "Animal Feed" ||
                                                        postCategory == "Others"
                                                    ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Average Weight (in kgs)", style: _labelStyle),

                                                        const SizedBox(height: 8),

                                                        FormBuilderTextField(
                                                          name: 'avg_weight',
                                                          maxLength: 3,
                                                          initialValue: postWeight,
                                                          autovalidateMode: validateMode,
                                                          decoration: InputDecoration(
                                                            counterText: "",
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
                                                            // suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                                          ),
                                                          keyboardType: const TextInputType.numberWithOptions(
                                                            decimal: true,
                                                          ),
                                                          validator: FormBuilderValidators.compose([
                                                            FormBuilderValidators.required(
                                                              errorText: 'Average weight is required.',
                                                            ),
                                                            FormBuilderValidators.numeric(
                                                              errorText: 'Must be a number.',
                                                            ),
                                                            FormBuilderValidators.min(
                                                              0,
                                                              errorText: 'Weight cannot be negative.',
                                                            ),
                                                            FormBuilderValidators.max(
                                                              10000,
                                                              errorText: 'Weight cannot exceed.',
                                                            ),
                                                          ]),
                                                        ),

                                                        const SizedBox(height: 10),
                                                      ],
                                                    )
                                                    : Container(),

                                                postCategory == "Live Stock" ||
                                                        postCategory == "Worker Services"
                                                    ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text("Age (in years)", style: _labelStyle),

                                                        const SizedBox(height: 8),

                                                        FormBuilderTextField(
                                                          name: 'age',
                                                          maxLength: 2,
                                                          initialValue: postAge.toString(),
                                                          autovalidateMode: validateMode,
                                                          decoration: InputDecoration(
                                                            counterText: "",
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
                                                            FormBuilderValidators.required(
                                                              errorText: 'Age is required.',
                                                            ),
                                                            FormBuilderValidators.numeric(
                                                              errorText: 'Must be a number.',
                                                            ),
                                                            FormBuilderValidators.min(
                                                              0,
                                                              errorText: 'Age cannot be negative.',
                                                            ),
                                                            FormBuilderValidators.max(
                                                              999,
                                                              errorText: 'Age cannot exceed.',
                                                            ),
                                                          ]),
                                                        ),

                                                        const SizedBox(height: 10),
                                                      ],
                                                    )
                                                    : Container(),
                                              ],
                                            ),

                                        // FormBuilderRadioGroup<String>(
                                        //   name: 'gender',
                                        //   decoration: const InputDecoration(
                                        //     border: InputBorder.none,
                                        //     contentPadding: EdgeInsets.zero,
                                        //   ),
                                        //   options: ['Male', 'Female']
                                        //       .map(
                                        //         (gender) => FormBuilderFieldOption(
                                        //           value: gender,
                                        //           child: _buildRadioOptionContainer(gender, isHorizontal: true),
                                        //         ),
                                        //       )
                                        //       .toList(growable: false),
                                        //   orientation: OptionsOrientation.horizontal,
                                        //   controlAffinity: ControlAffinity.leading,
                                        //   activeColor: onboardingColor,
                                        //   validator: FormBuilderValidators.required(
                                        //     errorText: 'Please select a gender.',
                                        //   ),
                                        //   separator: const SizedBox(width: 16), // Spacing between options
                                        // ),
                                        Text("Quantity", style: _labelStyle),
                                        const SizedBox(height: 8),

                                        FormBuilderTextField(
                                          name: 'quantity',
                                          maxLength: 3,
                                          initialValue: postQuantity.toString(),
                                          autovalidateMode: validateMode,
                                          decoration: InputDecoration(
                                            counterText: "",
                                            hintText: 'Enter Quantity',
                                            border: _inputBorder,
                                            enabledBorder: _inputBorder,
                                            focusedBorder: _focusedInputBorder,
                                            errorBorder: _errorInputBorder,
                                            focusedErrorBorder: _focusedInputBorder,
                                            contentPadding: _contentPadding,
                                            // suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                                          ),
                                          keyboardType: TextInputType.number,
                                          validator: FormBuilderValidators.compose([
                                            FormBuilderValidators.required(
                                              errorText: 'Quantity is required.',
                                            ),
                                            FormBuilderValidators.integer(
                                              errorText: 'Must be a whole number.',
                                            ),
                                            FormBuilderValidators.min(
                                              1,
                                              errorText: 'Quantity must be at least 1.',
                                            ),
                                          ]),
                                        ),
                                        const SizedBox(height: 10),

                                        Text("Price", style: _labelStyle),
                                        const SizedBox(height: 8),

                                        Row(
                                          children: [
                                            Expanded(
                                              child: FormBuilderTextField(
                                                name: 'price',
                                                maxLength: 6,
                                                initialValue: postPrice.toString(),
                                                autovalidateMode: validateMode,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter Your Price',
                                                  counterText: "",
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
                                                  FormBuilderValidators.min(
                                                    0,
                                                    errorText: 'Price cannot be negative.',
                                                  ),
                                                ]),
                                              ),
                                            ),

                                            Expanded(
                                              child: FormBuilderCheckbox(
                                                name: 'hasBeenSold',
                                                initialValue: postDetails["hasBeenSold"],
                                                title: Text("Mark as sold", style: _labelStyle),
                                                activeColor: onboardingColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        // const SizedBox(height: 30),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // const SizedBox(height: 2),

                          // Container(
                          //   alignment: Alignment.center,
                          //   padding: const EdgeInsets.all(8.9),
                          //   width: double.infinity,
                          //   color: Colors.white,
                          //   child: Text(
                          //     'Location, Contact & Delivery Details',
                          //     style: TextStyle(color: onboardingColor, fontSize: 16),
                          //     textAlign: TextAlign.center,
                          //   ),
                          // ),

                          // const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // const Text(
                                //   'Location',
                                //   style: TextStyle(
                                //     fontSize: 18,
                                //     fontWeight: FontWeight.bold,
                                //     color: Colors.black87,
                                //   ),
                                // ),
                                //
                                // const SizedBox(height: 6),

                                // ElevatedButton.icon(
                                //   icon: const Icon(Icons.location_on, color: Colors.white),
                                //   label: const Text(
                                //     'Select Location',
                                //     style: TextStyle(fontSize: 16, color: Colors.white),
                                //   ),
                                //   style: ElevatedButton.styleFrom(
                                //     backgroundColor: onboardingColor,
                                //     minimumSize: const Size(double.infinity, 50), // Full width button
                                //     shape: RoundedRectangleBorder(
                                //       borderRadius: BorderRadius.circular(12), // Rounded corners
                                //     ),
                                //     padding: const EdgeInsets.symmetric(vertical: 15),
                                //   ),
                                //   onPressed: _isLoading ? null : () async {
                                //     setState(() {
                                //       _isLoading = true;
                                //       error = "";
                                //     });
                                //
                                //     try {
                                //       final position = await _locationService.getCurrentLocation();
                                //       print(position);
                                //
                                //       final place_details = await _locationService.getPlaceDetails(position);
                                //       print(place_details);
                                //
                                //       if (context.mounted) {
                                //         setState(() {
                                //           placeDetails = place_details;
                                //           locationSelected = true;
                                //         });
                                //       }
                                //     } catch (e) {
                                //       if (e.toString().contains("Location services are disabled")) {
                                //         if (context.mounted) {
                                //           await showDialog(
                                //             context: context,
                                //             barrierDismissible: false,
                                //             builder:
                                //                 (ctx) => AlertDialog(
                                //                   title: Text("Location Services Disabled"),
                                //                   content: Text("Please enable location services in settings."),
                                //                   backgroundColor: Colors.white,
                                //                   actions: [
                                //                     TextButton(
                                //                       onPressed: () {
                                //                         Navigator.of(ctx).pop();
                                //                         Geolocator.openLocationSettings();
                                //                         // setState(() {});
                                //                       },
                                //                       child: Text("Open Settings"),
                                //                     ),
                                //                     TextButton(
                                //                       onPressed: () {
                                //                         Navigator.of(ctx).pop();
                                //                       },
                                //                       child: Text("Cancel"),
                                //                     ),
                                //                   ],
                                //                 ),
                                //           );
                                //         }
                                //       }
                                //     } finally {
                                //       setState(() {
                                //         _isLoading = false;
                                //       });
                                //     }
                                //   },
                                // ),
                                // const SizedBox(height: 10),
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
                                          maxLines: 4,
                                          initialValue: postDetailsDetailsLolWhatAName,
                                          // buildCounter:
                                          //     (
                                          //       context, {
                                          //       required currentLength,
                                          //       required isFocused,
                                          //       maxLength,
                                          //     }) => null,
                                          // Hide default counter
                                          decoration: InputDecoration(
                                            counterText: "",
                                            hintText: 'Type here',
                                            border: _inputBorder,
                                            enabledBorder: _inputBorder,
                                            focusedBorder: _focusedInputBorder,
                                            errorBorder: _errorInputBorder,
                                            focusedErrorBorder: _focusedInputBorder,
                                            contentPadding: _contentPadding,
                                          ),
                                          validator: FormBuilderValidators.compose([
                                            // FormBuilderValidators.maxLength(120),
                                          ]),
                                        ),
                                        const SizedBox(height: 2),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                TapDebouncer(
                                  cooldown: const Duration(milliseconds: 1000),
                                  onTap: () async {
                                    if (_imageUrls.isEmpty && _newImages.isEmpty) {
                                      setState(() {
                                        error = "Upload an image!";

                                        _scrollController.animateTo(
                                          _scrollController.position.minScrollExtent,
                                          curve: Curves.easeOut,
                                          duration: const Duration(milliseconds: 300),
                                        );
                                      });
                                    }
                                    // if (_formKey.currentState!.validate() && locationSelected) {

                                    if (_formKey.currentState!.validate() &&
                                        postCategory != null &&
                                        (_imageUrls.isNotEmpty || _newImages.isNotEmpty)) {
                                      if ((_imageUrls.length + _newImages.length >= 5)) {
                                        setState(() {
                                          error = "Can't upload more than 4 images!";

                                          _scrollController.animateTo(
                                            _scrollController.position.minScrollExtent,
                                            curve: Curves.easeOut,
                                            duration: const Duration(milliseconds: 300),
                                          );
                                        });

                                        return;
                                      }

                                      final doc = await firebaseService.getCurrentUserData();
                                      final userData = doc?.data() as Map<String, dynamic>?;

                                      final currency = userData?["defaultCurrency"] ?? "usd";

                                      List<String> newImageUrls = await firebaseService.uploadImages(
                                        _newImages,
                                      );

                                      List<String> finalImageUrls = [
                                        ..._imageUrls.cast<String>(),
                                        ...newImageUrls,
                                      ];

                                      firebaseService.editPost(
                                        postId: widget.postId,
                                        title: _formKey.currentState?.fields['title']?.value,
                                        imageUrls: finalImageUrls,
                                        category: postCategory,
                                        gender:
                                            postCategory == "Live Stock" || postCategory == "Worker Services"
                                                ? selectedGender
                                                : "",
                                        currency: currency,
                                        averageWeight:
                                            postCategory != "Live Stock" || postCategory != "Worker Services"
                                                ? _formKey.currentState?.fields['avg_weight']?.value ?? ""
                                                : "",
                                        quantity: int.parse(_formKey.currentState?.fields['quantity']?.value),
                                        // age: int.parse(_formKey.currentState?.fields['age']?.value),
                                        age:
                                            postCategory == "Live Stock" || postCategory == "Worker Services"
                                                ? int.parse(_formKey.currentState?.fields['age']?.value)
                                                : 0,
                                        price: int.parse(_formKey.currentState?.fields['price']?.value),
                                        details: _formKey.currentState?.fields['add_details']?.value,
                                        featured: true,
                                        city: postCity,
                                        village: _formKey.currentState?.fields['village']?.value,
                                        hasBeenSold: _formKey.currentState?.fields['hasBeenSold']?.value ?? false,
                                        // city: selectedCity,
                                        // city: placeDetails.city!,
                                        // province: placeDetails.province!,
                                        // country: placeDetails.country!,
                                      );

                                      for (String urlToDelete in _removedImageUrls) {
                                        await firebaseService.deleteImageFromUrl(urlToDelete);
                                      }

                                      _formKey.currentState?.reset();
                                      setState(() {
                                        error = "";
                                      });

                                      if (context.mounted) {
                                        // Navigator.pushReplacement(
                                        //   context,
                                        //   MaterialPageRoute(builder: (context) => HomeScreen()),
                                        // );

                                        Navigator.of(context).pop();
                                      }
                                    }
                                    // } else {
                                    // if (!locationSelected) {
                                    //   setState(() {
                                    //     error = "Location not selected";
                                    //
                                    //     _scrollController.animateTo(
                                    //       _scrollController.position.minScrollExtent,
                                    //       curve: Curves.easeOut,
                                    //       duration: const Duration(milliseconds: 300),
                                    //     );
                                    //   });
                                    // }
                                    // }
                                  },

                                  builder: (BuildContext context, TapDebouncerFunc? onTap) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: onboardingColor,
                                        minimumSize: const Size(double.infinity, 33),
                                        // Full width, slightly taller
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                      ),
                                      onPressed: onTap,
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(fontSize: 18, color: Colors.white),
                                      ),
                                    );
                                  },
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
          );
        },
      ),
    );
  }

  Widget _buildImagePickerSection() {
    return Column(
      children: [
        // if (_isLoadingImages)
        // Center(child: CircularProgressIndicator(color: Colors.red,))
        //   Center(child: Skeletonizer(
        //     ignorePointers: true,
        //     child: Column(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       children: [
        //         // CircularProgressIndicator(),
        //         SizedBox(height: 10), Text("Loading...")],
        //     ),
        //   ),)
        // else
        Skeletonizer(
          ignorePointers: true,
          enabled: _isLoadingImages,
          child: DottedBorder(
            options: RoundedRectDottedBorderOptions(
              radius: const Radius.circular(20),
              color: onboardingColor,
              strokeWidth: 1,
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Container(
                width: double.infinity,
                height: 340,
                color: Colors.white,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount:
                      _imageUrls.length +
                      _newImages.length +
                      ((_imageUrls.length + _newImages.length < 4) ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _imageUrls.length) {
                      return Stack(
                        children: [
                          Image.network(
                            _imageUrls[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: GestureDetector(
                              onTap: () {
                                _removeExistingImage(index);
                                if (_imageUrls.length + _newImages.length <= 4) {
                                  setState(() {
                                    error = '';
                                  });
                                }
                                return;
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.close, color: Colors.black, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else if (index < _imageUrls.length + _newImages.length) {
                      final newImageIndex = index - _imageUrls.length;

                      return Stack(
                        children: [
                          Image.file(
                            _newImages[newImageIndex],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                          Positioned(
                            top: 4,
                            left: 4,
                            child: GestureDetector(
                              onTap: () {
                                _removeNewImage(newImageIndex);
                                if (_imageUrls.length + _newImages.length <= 4) {
                                  setState(() {
                                    error = '';
                                  });
                                }
                                return;
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.close, color: Colors.black, size: 20),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Center(
                        child: IconButton(
                          icon: Icon(Icons.add_a_photo, size: 40, color: onboardingColor),
                          onPressed: _pickImage,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
