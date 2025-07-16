import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:farmers_hub/generated/i18n/app_localizations.dart';
import 'package:farmers_hub/screens/home/home_screen.dart';
import 'package:farmers_hub/services/firebase_service.dart';
import 'package:farmers_hub/services/location_service.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tap_debouncer/tap_debouncer.dart';

extension StringExtension on String {
  String toCapitalize() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}

class AddPostScreen extends StatefulWidget {
  final String? location;

  const AddPostScreen({super.key, this.location});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final firebaseService = FirebaseService();
  final LocationService _locationService = LocationService();

  final _formKey = GlobalKey<FormBuilderState>();
  final validateMode = AutovalidateMode.onUnfocus;
  String error = '';

  final ScrollController _scrollController = ScrollController();

  String selectedCity = "Damascus";

  String? selectedCategory;
  String? selectedGender;

  String? defaultCurrency;

  bool locationSelected = false;

  late PlaceDetails placeDetails;

  bool featuredPost = false;

  bool _isLoading = false;

  // File? _image;
  List<File> _images = [];
  final picker = ImagePicker();

  Color pickerColor = Color(0xff443a49);
  Color currentColor = scaffoldBackgroundColor;

  String? defaultRentOrSale;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future<void> _pickImage() async {
    final int remainingImages = 4 - _images.length;

    // When only one spot is left, use pickImage to avoid the limit issue
    if (remainingImages == 1) {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (mounted) {
          setState(() {
            _images.add(File(pickedFile.path));
          });
        }
      }
    } else {
      // Otherwise, use pickMultiImage with the calculated limit
      final pickedFiles = await picker.pickMultiImage(limit: remainingImages);

      if (pickedFiles.isNotEmpty) {
        if (mounted) {
          setState(() {
            _images.addAll(pickedFiles.map((pickedFile) => File(pickedFile.path)).toList());
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDefaultCurrency();
  }

  Future<void> _fetchDefaultCurrency() async {
    final userDoc = await firebaseService.getCurrentUserData();
    if (userDoc != null) {
      final userData = userDoc.data() as Map<String, dynamic>?;
      setState(() {
        defaultCurrency = userData?['defaultCurrency'];
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
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
  final EdgeInsets _contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  int _selectedColorIndex = 0;

  final List<Color> _colors = [
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.purple.shade100,
  ];

  Future<void> _showConfirmationDialog() async {
    bool isCommitted = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      requestFocus: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20.0),
              // title: Center(child: const Text('Allah Your Mubarak')),
              title: Center(child: Text(AppLocalizations.of(context)!.allahMubarak)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(
                      // 'Sell your product at 1% commission Only at Mahsolek. The fee is a trust owed by the advertiser, whether the sale is made for By or because of the site, the value of which is explained as follows',
                      AppLocalizations.of(context)!.sellProduct,
                      style: TextStyle(fontSize: 13),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          // height: 10,
                          child: Checkbox(
                            activeColor: onboardingColor,
                            checkColor: Colors.white,
                            value: isCommitted,
                            onChanged: (bool? value) {
                              setState(() {
                                isCommitted = value!;
                              });
                            },
                          ),
                        ),

                        SizedBox(width: 6),
                        // const Text('I commit to that'),
                        Text(AppLocalizations.of(context)!.commitToThat),
                      ],
                    ),
                  ],
                ),
              ),
              actionsAlignment: MainAxisAlignment.center,
              actions: <Widget>[
                SizedBox(
                  width: 260,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      // padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: onboardingColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: isCommitted
                        ? () async {
                            // The existing logic from the original "Submit" button's onTap is moved here.
                            bool canPost = await firebaseService.canCreatePost();

                            if (!canPost) {
                              if (context.mounted) {
                                Navigator.of(context).pop(); // Close the confirmation dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: Colors.white,
                                    // title: const Text("Monthly Limit Reached"),
                                    title: Text(AppLocalizations.of(context)!.monthlyLimitReached),
                                    content: Text(
                                      AppLocalizations.of(context)!.monthlyLimitLabel,
                                      // "You have reached your limit of 2 posts per month. Subscribe now to post without limits.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        // child: const Text("OK"),
                                        child: Text(AppLocalizations.of(context)!.ok),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          // TODO: Navigate to subscription screen
                                          Navigator.of(context).pop();
                                        },
                                        // child: const Text("Subscribe"),
                                        child: Text(AppLocalizations.of(context)!.subscribe),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return;
                            }

                            if (_images.isEmpty) {
                              this.setState(() {
                                error = AppLocalizations.of(context)!.uploadImage;

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                }

                                _scrollController.animateTo(
                                  _scrollController.position.minScrollExtent,
                                  curve: Curves.easeOut,
                                  duration: const Duration(milliseconds: 300),
                                );
                              });

                              return;
                            }

                            if (_formKey.currentState!.validate() &&
                                selectedCategory != null &&
                                _images.isNotEmpty) {
                              List<String> imageUrls = [];

                              if (_images.isNotEmpty && _images.length <= 4) {
                                imageUrls = await firebaseService.uploadImages(_images);
                              } else {
                                this.setState(() {
                                  error = AppLocalizations.of(context)!.uploadFourImagesOnly;
                                  _scrollController.animateTo(
                                    _scrollController.position.minScrollExtent,
                                    curve: Curves.easeOut,
                                    duration: const Duration(milliseconds: 300),
                                  );
                                });

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  return;
                                }
                              }

                              final doc = await firebaseService.getCurrentUserData();
                              final userData = doc?.data() as Map<String, dynamic>?;

                              final currency = userData?["defaultCurrency"] ?? "usd";

                              firebaseService.createPost(
                                rentOrSale: defaultRentOrSale,
                                title: _formKey.currentState?.fields['title']?.value,
                                imageUrls: imageUrls,
                                category: selectedCategory!,
                                gender:
                                    selectedCategory == "Live Stock" ||
                                        selectedCategory == "Worker Services"
                                    ? selectedGender
                                    : "",
                                currency: currency,
                                averageWeight:
                                    selectedCategory != "Live Stock" ||
                                        selectedCategory != "Worker Services"
                                    ? _formKey.currentState?.fields['avg_weight']?.value ?? ""
                                    : "",
                                quantity: int.parse(
                                  _formKey.currentState?.fields['quantity']?.value,
                                ),
                                age:
                                    selectedCategory == "Live Stock" ||
                                        selectedCategory == "Worker Services"
                                    ? int.parse(_formKey.currentState?.fields['age']?.value)
                                    : 0,
                                price: int.parse(_formKey.currentState?.fields['price']?.value),
                                details: _formKey.currentState?.fields['add_details']?.value,
                                featured: true,
                                city: widget.location ?? selectedCity,
                                village: _formKey.currentState?.fields['village']?.value,
                                // postColor: "0x${currentColor.toHexString()}",
                                postColor: "0x${_colors[_selectedColorIndex].toHexString()}",
                              );

                              _formKey.currentState?.reset();
                              this.setState(() {
                                locationSelected = false;
                                error = "";
                                _images = [];
                              });

                              if (context.mounted) {
                                Navigator.of(context).pop();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => HomeScreen()),
                                );
                              }
                            }
                          }
                        : null,
                    // child: Text('Confirm'),
                    child: Text(AppLocalizations.of(context)!.confirmD),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    final List<Map<String, String>> currencyOptions = [
      {'value': 'Syria', 'label': AppLocalizations.of(context)!.syriaLabel},
      // {'value': 'Syria', 'label': 'Syria (£)'},
      // {'value': 'Usd', 'label': 'Usd (\$)'},
      {'value': 'Usd', 'label': AppLocalizations.of(context)!.usdLabel},
      {'value': 'Euro', 'label': AppLocalizations.of(context)!.euroLabel},
      // {'value': 'Euro', 'label': 'Euro (€)'},
      // {'value': 'Lira', 'label': 'Lira (₺)'},
      {'value': 'Lira', 'label': AppLocalizations.of(context)!.liraLabel},
    ];

    void showColorPickerDialog() {
      const List<Color> colors = [
        Colors.red,
        Colors.pink,
        Colors.purple,
        Colors.deepPurple,
        Colors.indigo,
        Colors.blue,
        Colors.lightBlue,
        Colors.cyan,
        Colors.teal,
        Colors.green,
        Colors.lightGreen,
        Colors.lime,
        Colors.yellow,
        Colors.amber,
        Colors.orange,
        Colors.deepOrange,
        Colors.brown,
      ];

      showDialog(
        context: context,
        // The builder is used to create the content of the dialog.
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Pick a color!'),
          content: BlockPicker(
            pickerColor: pickerColor,
            onColorChanged: changeColor,
            // Provide the list of custom colors here.
            availableColors: colors,
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Got it'),
              onPressed: () {
                // When the user confirms, update the currentColor and close the dialog.
                setState(() => currentColor = pickerColor);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    }

    Widget _buildRadioOptionContainer(String text, {bool isHorizontal = false}) {
      return Container(
        width: isHorizontal ? null : double.infinity, // Full width for vertical items
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(8.0),
          // border: Border.all(color: Colors.grey.shade300),
          // Note: To change background on selection, you'd need to listen to form changes
          // and rebuild, or use a more complex custom FormBuilderField.
          // This basic styling provides the border.
        ),
        child: Text(text, style: const TextStyle(fontSize: 14)),
      );
    }

    Widget _buildColorBox(int index) {
      bool isSelected = _selectedColorIndex == index;
      return GestureDetector(
        onTap: () {
          // Update the state to reflect the new selection
          setState(() {
            _selectedColorIndex = index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            width: 98,
            height: 50,
            decoration: BoxDecoration(
              color: _colors[index],
              borderRadius: BorderRadius.circular(8.0),
              // Add a border and a checkmark if this box is selected
              border: isSelected ? Border.all(color: Colors.black, width: 1) : null,
            ),
            child: isSelected ? const Icon(Icons.check, color: Colors.black) : null,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: false,
        title: Text(
          AppLocalizations.of(context)!.createPost,
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
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
                controller: _scrollController,
                // padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: FormBuilder(
                  key: _formKey,
                  // IMPORTANT to remove all references from dynamic field when delete
                  clearValueOnUnregister: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          AppLocalizations.of(context)!.addProducts,
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
                            DottedBorder(
                              options: RoundedRectDottedBorderOptions(
                                radius: const Radius.circular(20),
                                color: onboardingColor,
                                strokeWidth: 1,
                                // dashPattern: const [6, 6],
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(Radius.circular(12)),
                                child: Container(
                                  width: double.infinity, // Take up all available horizontal space.
                                  height: 260, // Fixed height for the container.
                                  color: Colors.white, // Background color of the container.
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 56,
                                      bottom: 10,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      // Center the content vertically.
                                      children: [
                                        // The Expanded widget allows the icon to take up available space,
                                        // pushing the button to the bottom.
                                        const Expanded(
                                          child: Center(
                                            child: Icon(
                                              Icons.image_outlined,
                                              size: 36,
                                              color: onboardingColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // This is the "Add Images" button.
                                        _images.length >= 4
                                            ? Container()
                                            : SizedBox(
                                                width: double.infinity,
                                                // Make button take full width of its parent.
                                                child: ElevatedButton.icon(
                                                  onPressed: _pickImage,
                                                  icon: const Icon(
                                                    Icons.add_photo_alternate_rounded,
                                                    color: Colors.white,
                                                  ),
                                                  label: Text(
                                                    AppLocalizations.of(context)!.addImages,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        onboardingColor, // Button background color.
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    elevation: 2, // Adds a subtle shadow.
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 10),

                            _images.length >= 4
                                ? Container()
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.info_outline, color: onboardingColor, size: 20),
                                      SizedBox(width: 8),
                                      Text(
                                        AppLocalizations.of(context)!.addUpToFour,
                                        style: TextStyle(fontSize: 14, color: Colors.black),
                                      ),
                                    ],
                                  ),

                            SizedBox(height: 6),

                            error.isNotEmpty
                                ? Text(error, style: TextStyle(color: Colors.red, fontSize: 18))
                                : Container(),

                            error.isNotEmpty ? SizedBox(height: 10) : Container(),

                            // _image == null
                            //     ? Container()
                            //     : Stack(
                            //       children: [
                            //         Image.file(_image!, fit: BoxFit.fill, width: 110, height: 120),
                            //
                            //         Positioned(
                            //           top: 2,
                            //           left: 2,
                            //           child: GestureDetector(
                            //             onTap: () {
                            //               setState(() {
                            //                 _image = null;
                            //               });
                            //             },
                            //             child: Container(
                            //               decoration: BoxDecoration(
                            //                 color: Colors.white,
                            //                 shape: BoxShape.rectangle,
                            //                 borderRadius: BorderRadius.circular(8),
                            //               ),
                            //               child: Icon(Icons.close, color: Colors.grey, size: 20),
                            //             ),
                            //           ),
                            //         ),
                            //       ],
                            //     ),

                            // if (_images.isNotEmpty && _images.length < 4) ...[
                            //   SizedBox(height: 10),
                            //   Center(
                            //     child: ElevatedButton.icon(
                            //       onPressed: _pickImage,
                            //       icon: Icon(Icons.add, color: Colors.white),
                            //       label: Text('Add More', style: TextStyle(color: Colors.white)),
                            //       style: ElevatedButton.styleFrom(backgroundColor: onboardingColor),
                            //     ),
                            //   )
                            // ],

                            // _images.isEmpty
                            //     ? Container() :
                            //     ?
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              child: GridView.builder(
                                shrinkWrap: true,
                                // Important to make GridView work inside SingleChildScrollView
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  crossAxisSpacing: 8,
                                  mainAxisSpacing: 8,
                                ),

                                // itemCount: _images.length + (_images.length < 4 ? 1 : 0),
                                itemCount: _images.length,
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.file(
                                          _images[index],
                                          fit: BoxFit.fill,
                                          width: 110,
                                          height: 120,
                                        ),
                                      ),

                                      Positioned(
                                        top: 4,
                                        left: 4,
                                        child: GestureDetector(
                                          // onTap: () => _removeImage(index),
                                          onTap: () {
                                            _removeImage(index);
                                            if (_images.length <= 4) {
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
                                },
                              ),
                            ),

                            Card(
                              color: Colors.white,
                              elevation: 1.0, // Subtle shadow
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                // padding: const EdgeInsets.all(12.0),
                                padding: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                  top: 12,
                                  bottom: 0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.addPostTitle,
                                      style: _labelStyle,
                                    ),

                                    const SizedBox(height: 8),

                                    FormBuilderTextField(
                                      name: 'title',
                                      maxLength: 120,
                                      maxLines: 2,
                                      autovalidateMode: validateMode,
                                      // inputFormatters: [
                                      //   FilteringTextInputFormatter.allow(
                                      //     RegExp(r'^[a-zA-Z0-9 ]*$'),
                                      //   ),
                                      // ],
                                      // buildCounter:
                                      //     (
                                      //       context, {
                                      //       required currentLength,
                                      //       required isFocused,
                                      //       maxLength,
                                      //     }) => null,
                                      // Hide default counter
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!.typeHere,
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
                                          errorText: AppLocalizations.of(
                                            context,
                                          )!.postTitleRequired,
                                        ),
                                        FormBuilderValidators.maxLength(120),
                                      ]),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(AppLocalizations.of(context)!.city, style: _labelStyle),
                                    const SizedBox(height: 8),

                                    Padding(
                                      // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                      padding: const EdgeInsets.only(right: 0, left: 0, bottom: 10),
                                      child: DropdownButtonFormField2<String>(
                                        autovalidateMode: validateMode,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(context)!.selectCity,
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

                                        value: widget.location ?? selectedCity,

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
                                                onTap: () {
                                                  setState(() {
                                                    selectedCity = city;
                                                    // widget.location = null;
                                                  });
                                                },
                                                value: city,
                                                child: Text(city),
                                              );
                                            }).toList(),
                                        validator: (value) {
                                          if (value == null) {
                                            return AppLocalizations.of(context)!.cityRequired;
                                          }
                                          return null;
                                        },
                                        onChanged: (String? value) {
                                          setState(() {
                                            locationSelected = true;
                                          });
                                        },
                                      ),
                                    ),

                                    Text(AppLocalizations.of(context)!.village, style: _labelStyle),
                                    const SizedBox(height: 8),

                                    FormBuilderTextField(
                                      name: 'village',
                                      maxLength: 120,
                                      autovalidateMode: validateMode,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^[a-zA-Z0-9 ]*$'),
                                        ),
                                      ],
                                      decoration: InputDecoration(
                                        hintText: AppLocalizations.of(context)!.enterVillage,
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
                                        FormBuilderValidators.required(
                                          errorText: AppLocalizations.of(context)!.villageRequired,
                                        ),
                                      ]),
                                    ),

                                    const SizedBox(height: 8),

                                    Text(
                                      AppLocalizations.of(context)!.category,
                                      style: _labelStyle,
                                    ),
                                    const SizedBox(height: 8),

                                    Padding(
                                      // padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
                                      padding: const EdgeInsets.only(right: 0, left: 0, bottom: 10),
                                      child: DropdownButtonFormField2<String>(
                                        autovalidateMode: validateMode,
                                        decoration: InputDecoration(
                                          labelText: AppLocalizations.of(context)!.selectCategory,
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
                                                  "Pomegranate",
                                                  "Apples",
                                                  "Honey",
                                                  "Cheese",
                                                  "Leafy Green",
                                                  "Others",
                                                ]
                                                .map(
                                                  (lang) => DropdownMenuItem<String>(
                                                    value: lang,
                                                    child: Text(lang),
                                                  ),
                                                )
                                                .toList(),
                                        value: selectedCategory,
                                        validator: (String? value) {
                                          if (value == null) {
                                            return AppLocalizations.of(context)!.categoryRequires;
                                          }
                                          return null;
                                        },
                                        onChanged: (String? value) {
                                          setState(() {
                                            selectedCategory = value;
                                          });
                                        },
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
                                    selectedCategory == null
                                        ? Container()
                                        : Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              selectedCategory == "Live Stock" ||
                                                      selectedCategory == "Worker Services"
                                                  ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(context)!.gender,
                                                          style: _labelStyle,
                                                        ),

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
                                                              labelText: AppLocalizations.of(
                                                                context,
                                                              )!.selectGender,
                                                              floatingLabelBehavior:
                                                                  FloatingLabelBehavior.never,
                                                              contentPadding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical: 0,
                                                                    horizontal: 6,
                                                                  ),
                                                              border: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                  color: onboardingTextColor,
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius: BorderRadius.circular(
                                                                  12,
                                                                ),
                                                              ),
                                                              enabledBorder: _inputBorder,
                                                              errorBorder: _errorInputBorder,
                                                              focusedBorder: OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                  color: onboardingTextColor,
                                                                  width: 1.0,
                                                                ),
                                                                borderRadius: BorderRadius.circular(
                                                                  12,
                                                                ),
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
                                                                borderRadius: BorderRadius.circular(
                                                                  12,
                                                                ),
                                                                color: Colors.white,
                                                              ),
                                                            ),

                                                            // value: "Damascus",
                                                            items: ['Male', 'Female']
                                                                .map(
                                                                  (gender) =>
                                                                      DropdownMenuItem<String>(
                                                                        value: gender,
                                                                        child: Text(gender),
                                                                      ),
                                                                )
                                                                .toList(),
                                                            value: selectedGender,
                                                            validator: (String? value) {
                                                              if (value == null) {
                                                                return AppLocalizations.of(
                                                                  context,
                                                                )!.genderRequires;
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
                                                    )
                                                  : Container(),

                                              selectedCategory == "Land Services" ||
                                                      selectedCategory == "Equipments" ||
                                                      selectedCategory == "Delivery"
                                                  ? Container(
                                                      padding: EdgeInsets.only(
                                                        right: 0,
                                                        top: 2,
                                                        bottom: 0,
                                                      ),
                                                      // No explicit border for dropdown, styling via DropdownButton properties
                                                      child: DropdownButtonFormField2<String>(
                                                        items: ["Rent", "Sale"]
                                                            .map(
                                                              (lang) => DropdownMenuItem<String>(
                                                                value: lang,
                                                                child: Text(lang),
                                                              ),
                                                            )
                                                            .toList(),
                                                        decoration: InputDecoration(
                                                          contentPadding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 1,
                                                                horizontal: 2,
                                                              ),
                                                          border: _inputBorder,
                                                          enabledBorder: _inputBorder,
                                                          focusedBorder: _focusedInputBorder,
                                                          errorBorder: _errorInputBorder,
                                                          focusedErrorBorder: _focusedInputBorder,
                                                          helperText: ' ',
                                                          errorStyle: const TextStyle(height: 0),
                                                        ),
                                                        iconStyleData: IconStyleData(
                                                          // Using IconStyleData for icon properties
                                                          iconEnabledColor: onboardingTextColor,
                                                        ),

                                                        dropdownStyleData: DropdownStyleData(
                                                          offset: const Offset(0, 0),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(16),
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        // value: "USD",
                                                        value: defaultRentOrSale ?? "Rent",
                                                        onChanged: (value) async {
                                                          defaultRentOrSale = value;
                                                          setState(() {});
                                                        },
                                                      ),
                                                    )
                                                  : Container(),

                                              // Average Weight (in kgs)
                                              selectedCategory == "Fruits" ||
                                                      selectedCategory == "Vegetables" ||
                                                      selectedCategory == "Olive Oil" ||
                                                      selectedCategory == "Grains & Seeds" ||
                                                      selectedCategory == "Fertilizers" ||
                                                      selectedCategory == "Tools" ||
                                                      // selectedCategory == "Land Services" ||
                                                      // selectedCategory == "Equipments" ||
                                                      // selectedCategory == "Delivery" ||
                                                      selectedCategory == "Pesticides" ||
                                                      selectedCategory == "Animal Feed" ||
                                                      selectedCategory == "Others" ||
                                                      selectedCategory == "Pomegranate" ||
                                                      selectedCategory == "Apples" ||
                                                      selectedCategory == "Honey" ||
                                                      selectedCategory == "Cheese" ||
                                                      selectedCategory == "Leafy Green"
                                                  ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(
                                                            context,
                                                          )!.averageWeight,
                                                          style: _labelStyle,
                                                        ),

                                                        const SizedBox(height: 8),

                                                        FormBuilderTextField(
                                                          name: 'avg_weight',
                                                          maxLength: 9,
                                                          autovalidateMode: validateMode,
                                                          decoration: InputDecoration(
                                                            counterText: "",
                                                            hintText: AppLocalizations.of(
                                                              context,
                                                            )!.enterAverageWeight,
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
                                                          keyboardType:
                                                              const TextInputType.numberWithOptions(
                                                                decimal: true,
                                                              ),
                                                          validator: FormBuilderValidators.compose([
                                                            FormBuilderValidators.required(
                                                              errorText: AppLocalizations.of(
                                                                context,
                                                              )!.enterAverageWeightRequires,
                                                            ),
                                                            FormBuilderValidators.numeric(
                                                              errorText: AppLocalizations.of(
                                                                context,
                                                              )!.numberMust,
                                                            ),
                                                            FormBuilderValidators.min(
                                                              0,
                                                              errorText: AppLocalizations.of(
                                                                context,
                                                              )!.weighNotNegative,
                                                            ),
                                                            // FormBuilderValidators.max(
                                                            //   10000,
                                                            //   errorText: AppLocalizations.of(
                                                            //     context,
                                                            //   )!.weighNotExceed,
                                                            // ),
                                                          ]),
                                                        ),

                                                        const SizedBox(height: 10),
                                                      ],
                                                    )
                                                  : Container(),

                                              selectedCategory == "Live Stock" ||
                                                      selectedCategory == "Worker Services"
                                                  ? Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          AppLocalizations.of(context)!.age,
                                                          style: _labelStyle,
                                                        ),

                                                        const SizedBox(height: 8),

                                                        FormBuilderTextField(
                                                          name: 'age',
                                                          maxLength: 9,
                                                          autovalidateMode: validateMode,
                                                          decoration: InputDecoration(
                                                            counterText: "",
                                                            hintText: AppLocalizations.of(
                                                              context,
                                                            )!.enterAge,
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
                                                              errorText: AppLocalizations.of(
                                                                context,
                                                              )!.ageRequires,
                                                            ),
                                                            FormBuilderValidators.numeric(
                                                              errorText: AppLocalizations.of(
                                                                context,
                                                              )!.numberMust,
                                                            ),
                                                            FormBuilderValidators.min(
                                                              0,
                                                              errorText: AppLocalizations.of(
                                                                context,
                                                              )!.ageNotNegative,
                                                            ),
                                                            // FormBuilderValidators.max(
                                                            //   999,
                                                            //   errorText: AppLocalizations.of(
                                                            //     context,
                                                            //   )!.ageNotExceed,
                                                            // ),
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
                                    // Text("Color", style: _labelStyle),
                                    //
                                    // const SizedBox(height: 8),

                                    // TODO: Make these appear based on subscribed flag
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.start,
                                    //   children: List.generate(3, (index) => _buildColorBox(index)),
                                    // ),
                                    //
                                    // const SizedBox(height: 8),

                                    // InkWell(
                                    //   onTap: showColorPickerDialog,
                                    //   child: ListTile(
                                    //     title: const Text('Select a color: '),
                                    //     trailing: ElevatedButton(
                                    //       style: ElevatedButton.styleFrom(
                                    //         backgroundColor: currentColor,
                                    //         shape: RoundedRectangleBorder(
                                    //           borderRadius: BorderRadius.circular(12),
                                    //         ),
                                    //         padding: const EdgeInsets.symmetric(horizontal: 0), // Gives it some size
                                    //       ),
                                    //       onPressed: showColorPickerDialog,
                                    //       child: Text(""),
                                    //     ),
                                    //   ),
                                    // ),

                                    // const SizedBox(height: 10),
                                    Text(
                                      AppLocalizations.of(context)!.quantity,
                                      style: _labelStyle,
                                    ),
                                    const SizedBox(height: 8),

                                    FormBuilderTextField(
                                      name: 'quantity',
                                      maxLength: 9,
                                      autovalidateMode: validateMode,
                                      decoration: InputDecoration(
                                        counterText: "",
                                        hintText: AppLocalizations.of(context)!.enterQuantity,
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
                                          errorText: AppLocalizations.of(context)!.quantityRequired,
                                        ),
                                        FormBuilderValidators.integer(
                                          errorText: AppLocalizations.of(context)!.mustWholeNumber,
                                        ),
                                        FormBuilderValidators.min(
                                          1,
                                          errorText: AppLocalizations.of(context)!.quantityLeastOne,
                                        ),
                                      ]),
                                    ),
                                    const SizedBox(height: 10),

                                    // Text("Currency", style: _labelStyle),
                                    // const SizedBox(height: 8),

                                    // Container(
                                    //   padding: EdgeInsets.only(right: 0, top: 2, bottom: 2),
                                    //   // No explicit border for dropdown, styling via DropdownButton properties
                                    //   child: DropdownButtonFormField2<String>(
                                    //     items:
                                    //         ['Syria', "Usd", "Euro", "Lira"]
                                    //             .map(
                                    //               (lang) => DropdownMenuItem<String>(
                                    //                 value: lang,
                                    //                 child: Text(lang),
                                    //               ),
                                    //             )
                                    //             .toList(),
                                    //     decoration: InputDecoration(
                                    //       contentPadding: const EdgeInsets.symmetric(
                                    //         vertical: 1,
                                    //         horizontal: 2,
                                    //       ),
                                    //       border: _inputBorder,
                                    //       enabledBorder: _inputBorder,
                                    //       focusedBorder: _focusedInputBorder,
                                    //       errorBorder: _errorInputBorder,
                                    //       focusedErrorBorder: _focusedInputBorder,
                                    //     ),
                                    //     iconStyleData: IconStyleData(
                                    //       // Using IconStyleData for icon properties
                                    //       iconEnabledColor: onboardingTextColor,
                                    //     ),
                                    //
                                    //     dropdownStyleData: DropdownStyleData(
                                    //       offset: const Offset(0, 0),
                                    //       decoration: BoxDecoration(
                                    //         borderRadius: BorderRadius.circular(16),
                                    //         color: Colors.white,
                                    //       ),
                                    //     ),
                                    //     // value: "USD",
                                    //     value: defaultCurrency?.toCapitalize() ?? "Usd",
                                    //     onChanged: (value) async {
                                    //       await firebaseService.updateCurrency(value!.toLowerCase());
                                    //       setState(() {});
                                    //     },
                                    //   ),
                                    // ),

                                    // const SizedBox(height: 10),
                                    Text(AppLocalizations.of(context)!.price, style: _labelStyle),
                                    const SizedBox(height: 8),

                                    Row(
                                      children: [
                                        // Text(defaultCurrency.toString().to),
                                        Expanded(
                                          flex: locale.languageCode == "ar" ? 5 : 3,
                                          child: Container(
                                            padding: EdgeInsets.only(right: 0, top: 2, bottom: 0),
                                            // No explicit border for dropdown, styling via DropdownButton properties
                                            child: DropdownButtonFormField2<String>(
                                              // items: ['Syria (SYP)', "Usd (\$)", "Euro (€)", "Lira"]
                                              //     .map(
                                              //       (lang) => DropdownMenuItem<String>(
                                              //     value: lang,
                                              //     child: Text(lang),
                                              //   ),
                                              // )
                                              //     .toList(),
                                              items: currencyOptions
                                                  .map(
                                                    (currency) => DropdownMenuItem<String>(
                                                      value: currency['value'],
                                                      child: Text(currency['label']!),
                                                    ),
                                                  )
                                                  .toList(),
                                              decoration: InputDecoration(
                                                contentPadding: const EdgeInsets.symmetric(
                                                  vertical: 1,
                                                  horizontal: 1,
                                                ),
                                                border: _inputBorder,
                                                enabledBorder: _inputBorder,
                                                focusedBorder: _focusedInputBorder,
                                                errorBorder: _errorInputBorder,
                                                focusedErrorBorder: _focusedInputBorder,
                                                helperText: ' ',
                                                errorStyle: const TextStyle(height: 0),
                                              ),
                                              iconStyleData: IconStyleData(
                                                // Using IconStyleData for icon properties
                                                iconEnabledColor: onboardingTextColor,
                                              ),

                                              dropdownStyleData: DropdownStyleData(
                                                offset: const Offset(0, 0),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(16),
                                                  color: Colors.white,
                                                ),
                                              ),
                                              // value: "USD",
                                              value: defaultCurrency?.toCapitalize() ?? "Usd",
                                              onChanged: (value) async {
                                                print(value);
                                                await firebaseService.updateCurrency(
                                                  value!.toLowerCase(),
                                                );
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ),

                                        SizedBox(width: 6),

                                        Expanded(
                                          flex: 3,
                                          child: FormBuilderTextField(
                                            name: 'price',
                                            maxLength: 9,
                                            autovalidateMode: validateMode,
                                            decoration: InputDecoration(
                                              hintText: AppLocalizations.of(context)!.enterPrice,
                                              counterText: "",
                                              border: _inputBorder,
                                              enabledBorder: _inputBorder,
                                              focusedBorder: _focusedInputBorder,
                                              errorBorder: _errorInputBorder,
                                              focusedErrorBorder: _focusedInputBorder,
                                              contentPadding: _contentPadding,
                                              helperText:
                                                  ' ', // This reserves the space. Note the space character.
                                              errorStyle: const TextStyle(height: 0),
                                            ),
                                            keyboardType: const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                            validator: FormBuilderValidators.compose([
                                              FormBuilderValidators.required(
                                                errorText: "",
                                                // errorText: 'Price is required.',
                                              ),
                                              FormBuilderValidators.numeric(
                                                errorText: "",
                                                // errorText: 'Must be a number.',
                                              ),
                                              FormBuilderValidators.min(
                                                0,
                                                errorText: "",
                                                // errorText: 'Price cannot be negative.',
                                              ),
                                            ]),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context)!.additionalDetails,
                                      style: _labelStyle,
                                    ),

                                    const SizedBox(height: 8),

                                    FormBuilderTextField(
                                      name: 'add_details',
                                      maxLength: 120,
                                      maxLines: 4,
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
                                        hintText: AppLocalizations.of(context)!.typeHere,
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
                              cooldown: const Duration(milliseconds: 2000),
                              onTap: () async {
                                // Check if the user can create a post.

                                // FocusScope.of(context).unfocus();

                                if (_formKey.currentState!.validate()) {
                                  _showConfirmationDialog();
                                }

                                // bool canPost = await firebaseService.canCreatePost();
                                //
                                // if (!canPost) {
                                //   if (context.mounted) {
                                //     showDialog(
                                //       context: context,
                                //       builder: (context) => AlertDialog(
                                //         backgroundColor: Colors.white,
                                //         title: const Text("Monthly Limit Reached"),
                                //         content: const Text(
                                //           "You have reached your limit of 3 posts per month. Subscribe now to post without limits.",
                                //         ),
                                //         actions: [
                                //           TextButton(
                                //             onPressed: () => Navigator.of(context).pop(),
                                //             child: const Text("OK"),
                                //           ),
                                //           // Optional: Add a button to a subscription screen
                                //           TextButton(
                                //             onPressed: () {
                                //               // TODO: Navigate to subscription screen
                                //               Navigator.of(context).pop();
                                //             },
                                //             child: const Text("Subscribe"),
                                //           ),
                                //         ],
                                //       ),
                                //     );
                                //   }
                                //   return; // Stop execution if the user cannot post.
                                // }
                                //
                                // if (_images.isEmpty) {
                                //   setState(() {
                                //     error = "Upload an image!";
                                //
                                //     _scrollController.animateTo(
                                //       _scrollController.position.minScrollExtent,
                                //       curve: Curves.easeOut,
                                //       duration: const Duration(milliseconds: 300),
                                //     );
                                //   });
                                //
                                //   return;
                                // }
                                //
                                // if (_formKey.currentState!.validate() &&
                                //     selectedCategory != null &&
                                //     _images.isNotEmpty) {
                                //   List<String> imageUrls = [];
                                //
                                //   if (_images.isNotEmpty && _images.length <= 4) {
                                //     imageUrls = await firebaseService.uploadImages(_images);
                                //   } else {
                                //     setState(() {
                                //       error = "Can't upload more than 4 images!";
                                //
                                //       _scrollController.animateTo(
                                //         _scrollController.position.minScrollExtent,
                                //         curve: Curves.easeOut,
                                //         duration: const Duration(milliseconds: 300),
                                //       );
                                //     });
                                //
                                //     return;
                                //   }
                                //
                                //   final doc = await firebaseService.getCurrentUserData();
                                //   final userData = doc?.data() as Map<String, dynamic>?;
                                //
                                //   final currency = userData?["defaultCurrency"] ?? "usd";
                                //
                                //   firebaseService.createPost(
                                //     title: _formKey.currentState?.fields['title']?.value,
                                //     // imageUrl: imageUrl.toString(),
                                //     imageUrls: imageUrls,
                                //     category: selectedCategory!,
                                //     gender:
                                //         selectedCategory == "Live Stock" ||
                                //             selectedCategory == "Worker Services"
                                //         ? selectedGender
                                //         : "",
                                //     currency: currency,
                                //     averageWeight:
                                //         selectedCategory != "Live Stock" ||
                                //             selectedCategory != "Worker Services"
                                //         ? _formKey.currentState?.fields['avg_weight']?.value ?? ""
                                //         : "",
                                //     quantity: int.parse(
                                //       _formKey.currentState?.fields['quantity']?.value,
                                //     ),
                                //     // age: int.parse(_formKey.currentState?.fields['age']?.value),
                                //     age:
                                //         selectedCategory == "Live Stock" ||
                                //             selectedCategory == "Worker Services"
                                //         ? int.parse(_formKey.currentState?.fields['age']?.value)
                                //         : 0,
                                //     price: int.parse(_formKey.currentState?.fields['price']?.value),
                                //     details: _formKey.currentState?.fields['add_details']?.value,
                                //     featured: true,
                                //     city: widget.location ?? selectedCity,
                                //     village: _formKey.currentState?.fields['village']?.value,
                                //     // postColor: '#FFFFFFFF',
                                //     postColor: "0x${currentColor.toHexString()}",
                                //     // city: selectedCity,
                                //     // city: placeDetails.city!,
                                //     // province: placeDetails.province!,
                                //     // country: placeDetails.country!,
                                //   );
                                //
                                //   _formKey.currentState?.reset();
                                //   setState(() {
                                //     locationSelected = false;
                                //     error = "";
                                //     // _image = null;
                                //     _images = [];
                                //   });
                                //
                                //   if (context.mounted) {
                                //     Navigator.pushReplacement(
                                //       context,
                                //       MaterialPageRoute(builder: (context) => HomeScreen()),
                                //     );
                                //   }
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
                                  child: Text(
                                    AppLocalizations.of(context)!.submit,
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
      ),
    );
  }
}
