import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:farmers_hub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CommissionScreen extends StatefulWidget {
  const CommissionScreen({super.key});

  @override
  State<CommissionScreen> createState() => _CommissionScreenState();
}

class _CommissionScreenState extends State<CommissionScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  String _totalCommission = "0"; // Initial commission
  String _selectedCurrency = '\$'; // Default currency
  final List<String> _currencies = ['ل س', '\$', '€', '₺']; // Example currencies

  // Dummy image URL for the receipt placeholder
  final String receiptPlaceholderImageUrl =
      'https://via.placeholder.com/300x200.png/E8E8E8/AAAAAA?Text=Upload+Receipt+Image';

  File? _receiptImage; // To store the selected image file
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickReceiptImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _receiptImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle any errors, e.g., permissions
      print("Error picking image: $e");
      // Optionally, show a snackbar or dialog to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: ${e.toString().substring(0, 60)}...')),
      );
    }
  }

  void _removeReceiptImage() {
    setState(() {
      _receiptImage = null;
    });
  }

  void _calculateCommission() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Access the value from FormBuilderTextField
      final String? priceString = _formKey.currentState?.fields['sale_price']?.value;
      double price = double.tryParse(priceString ?? "") ?? 0.0;
      double commissionPercentage = 0.01; // 1%
      double commission = price * commissionPercentage;
      setState(() {
        _totalCommission = commission.toStringAsFixed(0); // Assuming commission is an integer
      });
    } else {
      // If validation fails, reset commission or handle as needed
      setState(() {
        _totalCommission = "0";
      });
    }
  }

  final String mtnTextLogo = "MTN Cash";
  final String systelTextLogo = "Syriatel Cash";

  final Color receiptBackgroundColor = Color(0xFFE6E0F8);

  final FaIcon mtnLogo = FaIcon(
    FontAwesomeIcons.simCard,
    color: Color(0xFFFFCC00),
    size: 28,
  ); // Example for MTN (sim card, needs color)
  final FaIcon systelLogo = FaIcon(
    FontAwesomeIcons.moneyBillWave,
    color: Colors.blueAccent,
    size: 28,
  ); // Generic for Systel Cash
  final FaIcon stripeLogo = FaIcon(
    FontAwesomeIcons.stripe,
    color: Color(0xFF6772E5),
    size: 30,
  ); // Stripe has 'S' and full 'stripe'
  final FaIcon visaLogo = FaIcon(FontAwesomeIcons.ccVisa, color: Color(0xFF1A1F71), size: 28);
  final FaIcon mastercardLogo = FaIcon(
    FontAwesomeIcons.ccMastercard,
    color: Color(0xFFEB001B),
    size: 28,
  ); // Your UI had a generic green circle, maybe for Mobile Money generally
  final FaIcon bankLogo = FaIcon(
    FontAwesomeIcons.buildingColumns,
    color: Colors.grey.shade700,
    size: 28,
  ); // Generic bank icon

  Widget _buildPaymentLogo(dynamic logoContent, {Color? textColor}) {
    Widget contentWidget;

    if (logoContent is FaIcon) {
      contentWidget = logoContent;
    } else if (logoContent is String) {
      contentWidget = Text(
        logoContent,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 11, // Adjust font size for text logos to fit
          fontWeight: FontWeight.w700,
          color: textColor ?? Colors.black87, // Use provided color or default
        ),
      );
    } else {
      contentWidget = Icon(Icons.error); // Fallback for unexpected type
    }

    return Container(
      width: 85, // Slightly increased width for text
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6), // Adjust padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(child: contentWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = onboardingColor;
    const Color textFieldBackgroundColor = Color(0xFFF7F7F7);

    return Scaffold(
      backgroundColor: homebackgroundColor,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        backgroundColor: onboardingColor,
        automaticallyImplyLeading: true,
        title: Text(
          "Commission of Membership",
          // style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          // Wrap relevant parts with FormBuilder
          key: _formKey,
          onChanged: () {
            // Optional: recalculate on any form change
            _formKey.currentState!.save(); // Save the current state
            _calculateCommission();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // --- Informational Text (Keep as before) ---
              Text(
                'Sell your product at 1% commission\n'
                'Only at Mahsolek. The fee is a trust owed by the\n'
                'advertiser, whether the sale is made for By or\n'
                'because of the site, the value of which is\n'
                'explained as follows',
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.5),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () {
                  print("Calculate Commission tapped");
                  // If you want this to also trigger calculation:
                  // _calculateCommission();
                },
                child: Text(
                  'Calculate Commission',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                    decorationColor: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Divider(color: Colors.grey[300]),
              const SizedBox(height: 16),

              // --- Enter Sale Price ---
              Text(
                'Enter Sale Price',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.only(
                  left: 12.0,
                ), // Adjust padding for FormBuilderTextField
                decoration: BoxDecoration(
                  color: textFieldBackgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FormBuilderTextField(
                        name: 'sale_price', // Important: name to access the value
                        initialValue: '0', // Set initial value here
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'e.g., 50000',
                          border: InputBorder.none,
                          hintStyle: GoogleFonts.poppins(color: Colors.black54),
                          // Remove contentPadding if parent container handles padding
                        ),
                        keyboardType: TextInputType.number,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: 'Sale price is required'),
                          FormBuilderValidators.numeric(errorText: 'Please enter a valid number'),
                          FormBuilderValidators.min(0, errorText: 'Price cannot be negative'),
                        ]),
                        // onChanged: (value) { // Alternative to FormBuilder's onChanged
                        //   _calculateCommission();
                        // },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // You can keep the DropdownButton as is, or use FormBuilderDropdown
                    // For simplicity, keeping the stateful DropdownButton here
                    // DropdownButtonHideUnderline(
                    //   child: DropdownButton<String>(
                    //     value: _selectedCurrency,
                    //     icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[700]),
                    //     items: _currencies.map((String value) {
                    //       return DropdownMenuItem<String>(
                    //         value: value,
                    //         child: Text(
                    //           value,
                    //           style: GoogleFonts.poppins(
                    //             fontSize: 16,
                    //             fontWeight: FontWeight.w500,
                    //             color: Colors.black87,
                    //           ),
                    //         ),
                    //       );
                    //     }).toList(),
                    //     onChanged: (String? newValue) {
                    //       setState(() {
                    //         _selectedCurrency = newValue!;
                    //         _calculateCommission(); // Recalculate if currency change affects it
                    //       });
                    //     },
                    //   ),
                    // ),

                    DropdownButton2<String>(
                      underline: const SizedBox.shrink(),
                      value: _selectedCurrency,

                      items: _currencies
                          .map((String item) => DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                      ))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCurrency = newValue!;
                          _calculateCommission(); // Recalculate if currency change affects it
                        });
                      },
                      iconStyleData: IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey[700],
                        ),
                      ),
                      buttonStyleData: ButtonStyleData(
                        // padding: EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        height: 40,
                        width: 80,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        elevation: 0,
                        // offset: const Offset(-20, 0),
                        // scrollbarTheme: ScrollbarThemeData(
                        //   radius: const Radius.circular(40),
                        //   thickness: MaterialStateProperty.all<double>(6),
                        //   thumbVisibility: MaterialStateProperty.all<bool>(true),
                        // ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                      ),
                    ),
                    // const SizedBox(width: 8), // Padding for the dropdown
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Total Commission (Keep as before, but updated by _calculateCommission) ---
              Text(
                'Total Commission',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                decoration: BoxDecoration(
                  color: textFieldBackgroundColor,
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _totalCommission,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      _selectedCurrency,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Action Buttons (Keep as before) ---
              // ... (Contact and Pay Now buttons) ...
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: FaIcon(FontAwesomeIcons.whatsapp, color: onboardingColor, size: 24),
                      label: Text(
                        'Contact',
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        print("Contact button tapped");
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          print(
                            "Pay Now button tapped. Form data: ${_formKey.currentState?.value}",
                          );
                          // TODO: Implement pay now action with form data
                        } else {
                          print("Form is invalid");
                        }
                      },
                      child: Text(
                        'Pay Now',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- How to Pay (Keep as before) ---
              // ... (Payment method text and logos) ...
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'How to Pay First Method',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Online Payment',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12.0,
                  runSpacing: 12.0,
                  children: [
                    _buildPaymentLogo(mtnTextLogo, textColor: Colors.grey.shade600),
                    _buildPaymentLogo(systelTextLogo, textColor: Colors.grey.shade600),
                    _buildPaymentLogo(stripeLogo),
                    _buildPaymentLogo(visaLogo),
                    _buildPaymentLogo(mastercardLogo),
                    _buildPaymentLogo(bankLogo),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Send Copy Receipt (Keep as before, this is not part of the form builder logic) ---
              // ... (Receipt image and upload/send buttons) ...
              Text(
                'Send Copy Receipt',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: _receiptImage != null
                          ? Image.file(
                              _receiptImage!,
                              fit: BoxFit.fill, // Or BoxFit.cover
                              height: 250,
                              width: double.infinity,
                            )
                          : Container(
                              // Placeholder when no image is selected
                              height: 250,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                // color: receiptBackgroundColor, // Use the same background
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_search_outlined, // Placeholder icon
                                  size: 40,
                                  // color: Colors.grey[600],
                                  color: onboardingColor,
                                ),
                              ),
                            ),
                    ),
                    if (_receiptImage != null) // Show remove button only if image exists
                      Positioned(
                        top: 8,
                        left: 8,
                        child: InkWell(
                          onTap: _removeReceiptImage,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: primaryColor, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      onPressed: () {
                        _pickReceiptImage(ImageSource.gallery);
                      },
                      child: Text(
                        'Upload File',
                        style: GoogleFonts.poppins(
                          color: primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        elevation: 2,
                      ),
                      onPressed: (_receiptImage != null)
                          ? () {
                              // TODO: Implement send receipt action with _receiptImage
                              print("Send button tapped with image: ${_receiptImage!.path}");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Sending receipt...')),
                              );
                            }
                          : null,
                      child: Text(
                        'Send',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
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
}
